local M = {}

local tracker = require('utils.timetracker')

M.init = function()
    return nil
end

-- Shared JIRA fetch helper. Calls callback(json, fields) on success, or notifies on error.
local function jira_fetch(ticket_id, callback)
    local dotenv = require('utils.dotenv')
    local base_url = dotenv.get('JIRA_BASE_URL')
    local token = dotenv.get('JIRA_ACCESS_TOKEN')
    local email = dotenv.get('JIRA_EMAIL')

    if not base_url or base_url == '' then
        vim.notify('JIRA_BASE_URL not set. Load .env first with <leader>le', vim.log.levels.ERROR)
        return false
    end
    if not token or token == '' then
        vim.notify('JIRA_ACCESS_TOKEN not set. Load .env first with <leader>le', vim.log.levels.ERROR)
        return false
    end
    if not email or email == '' then
        vim.notify('JIRA_EMAIL not set. Load .env first with <leader>le', vim.log.levels.ERROR)
        return false
    end

    base_url = base_url:gsub('/$', '')
    local url = base_url .. '/rest/api/3/issue/' .. ticket_id
        .. '?fields=summary,description,status,assignee,priority,issuetype,timetracking,customfield_10035'

    vim.fn.jobstart({
        'curl', '-s', '-u', email .. ':' .. token,
        '-H', 'Content-Type: application/json',
        url,
    }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data or #data == 0 then return end
            local raw = table.concat(data, '\n')
            raw = vim.trim(raw)
            if raw == '' then return end

            vim.schedule(function()
                local ok, json = pcall(vim.json.decode, raw)
                if not ok or not json then
                    vim.notify('Failed to parse JIRA response', vim.log.levels.ERROR)
                    return
                end
                if json.errorMessages then
                    vim.notify(table.concat(json.errorMessages, '\n'), vim.log.levels.ERROR)
                    return
                end
                callback(json, json.fields or {})
            end)
        end,
        on_stderr = function(_, data)
            if data and #data > 0 then
                local msg = vim.trim(table.concat(data, '\n'))
                if msg ~= '' then
                    vim.schedule(function()
                        vim.notify('JIRA request error: ' .. msg, vim.log.levels.ERROR)
                    end)
                end
            end
        end,
    })
    return true
end

M.setup = function()
    vim.api.nvim_create_user_command('Start', function(opts)
        local ticket_id = opts.args
        if ticket_id == '' then
            vim.notify('Usage: :Start <TICKET_ID>', vim.log.levels.ERROR)
            return
        end
        -- If ticket already exists, reuse its HQ project
        local existing = tracker.get(ticket_id)
        if existing then
            local task, err = tracker.start(ticket_id)
            if err then
                vim.notify(ticket_id .. ': ' .. err, vim.log.levels.WARN)
            else
                vim.notify('Started entry for ' .. task.ticket_id .. ' (HQ: ' .. task.hq_project .. ')', vim.log.levels.INFO)
            end
            return
        end

        -- Try to fetch HQ project from JIRA
        vim.notify('Fetching ' .. ticket_id .. ' from JIRA...', vim.log.levels.INFO)
        local fetched = jira_fetch(ticket_id, function(_, fields)
            local hq_project = fields.customfield_10035 or ''
            local estimate = ''
            if fields.timetracking and fields.timetracking.originalEstimate then
                estimate = fields.timetracking.originalEstimate
            end

            if hq_project ~= '' then
                local task, err = tracker.start(ticket_id, hq_project)
                if err then
                    vim.notify(ticket_id .. ': ' .. err, vim.log.levels.WARN)
                else
                    local msg = 'Started tracking ' .. task.ticket_id .. ' (HQ: ' .. task.hq_project .. ')'
                    if estimate ~= '' then
                        msg = msg .. ' [Estimate: ' .. estimate .. ']'
                    end
                    vim.notify(msg, vim.log.levels.INFO)
                end
            else
                -- JIRA didn't have Jobnummer, prompt manually
                vim.ui.input({ prompt = 'HQ Project Number (not found in JIRA): ' }, function(input)
                    if not input or input == '' then
                        vim.notify('Cancelled — no HQ project provided', vim.log.levels.WARN)
                        return
                    end
                    local task, err = tracker.start(ticket_id, input)
                    if err then
                        vim.notify(ticket_id .. ': ' .. err, vim.log.levels.WARN)
                    else
                        vim.notify('Started tracking ' .. task.ticket_id .. ' (HQ: ' .. task.hq_project .. ')', vim.log.levels.INFO)
                    end
                end)
            end
        end)

        -- If JIRA env vars not set, fall back to manual prompt
        if not fetched then
            vim.ui.input({ prompt = 'HQ Project Number: ' }, function(hq_project)
                if not hq_project or hq_project == '' then
                    vim.notify('Cancelled — no HQ project provided', vim.log.levels.WARN)
                    return
                end
                local task, err = tracker.start(ticket_id, hq_project)
                if err then
                    vim.notify(ticket_id .. ': ' .. err, vim.log.levels.WARN)
                else
                    vim.notify('Started tracking ' .. task.ticket_id .. ' (HQ: ' .. task.hq_project .. ')', vim.log.levels.INFO)
                end
            end)
        end
    end, { nargs = 1, desc = 'Start time tracking for a ticket' })

    vim.api.nvim_create_user_command('End', function(opts)
        local ticket_id = opts.args
        if ticket_id == '' then
            vim.notify('Usage: :End <TICKET_ID>', vim.log.levels.ERROR)
            return
        end
        local result, err = tracker.stop(ticket_id)
        if err then
            vim.notify(ticket_id .. ': ' .. err, vim.log.levels.ERROR)
            return
        end
        vim.notify(
            string.format('%s stopped — %d min (rounded: %d min)', result.ticket_id, result.duration_minutes, result.rounded_minutes),
            vim.log.levels.INFO
        )

        -- Async description generation via claude CLI
        local start_ts = result.start_time
        local cmd = string.format(
            [[
# Gather uncommitted changes, excluding dotfiles/env/local config
dirty_diff="$(git diff --stat -- ':!.*' ':!*.env*' ':!*.local*' 2>/dev/null)"
staged_diff="$(git diff --cached --stat -- ':!.*' ':!*.env*' ':!*.local*' 2>/dev/null)"
untracked="$(git ls-files --others --exclude-standard -- ':!.*' ':!*.env*' ':!*.local*' 2>/dev/null)"

uncommitted=""
if [ -n "$dirty_diff" ] || [ -n "$staged_diff" ] || [ -n "$untracked" ]; then
    uncommitted="UNCOMMITTED CHANGES:"$'\n'
    [ -n "$staged_diff" ] && uncommitted="${uncommitted}Staged:$'\n'${staged_diff}"$'\n'
    [ -n "$dirty_diff" ] && uncommitted="${uncommitted}Unstaged:$'\n'${dirty_diff}"$'\n'
    [ -n "$untracked" ] && uncommitted="${uncommitted}Untracked:$'\n'${untracked}"$'\n'
fi

commits="$(git log --oneline --since=%d 2>/dev/null)"

if [ -n "$uncommitted" ]; then
    # WIP: uncommitted work gets priority, include commits as context
    input="${uncommitted}"
    [ -n "$commits" ] && input="${input}"$'\n'"RECENT COMMITS:"$'\n'"${commits}"
    echo "$input" | claude -p "Summarize the work in progress based on these changes. Uncommitted changes are the priority. Output ONLY a single concise sentence, no prefix, no ticket ID." 2>/dev/null | while IFS= read -r line; do echo "WIP: ${line}"; done
elif [ -n "$commits" ]; then
    echo "$commits" | claude -p "Summarize the work done based on these git commits. Output ONLY a single concise sentence, no prefix, no ticket ID." 2>/dev/null
else
    echo "No changes found"
fi
]],
            start_ts
        )
        vim.fn.jobstart({ 'bash', '-c', cmd }, {
            stdout_buffered = true,
            on_stdout = function(_, data)
                if data and #data > 0 then
                    local desc = table.concat(data, ' ')
                    desc = vim.trim(desc)
                    if desc ~= '' then
                        desc = '[' .. ticket_id .. '] - ' .. desc
                        vim.schedule(function()
                            tracker.set_description(ticket_id, desc)
                            vim.notify(ticket_id .. ' description updated', vim.log.levels.INFO)
                        end)
                    end
                end
            end,
            on_stderr = function() end,
        })
    end, { nargs = 1, desc = 'Stop time tracking for a ticket' })

    vim.api.nvim_create_user_command('TimeExport', function(opts)
        local path = opts.args
        if path == '' then
            path = vim.fn.getcwd() .. '/timetracker-export.csv'
        end
        tracker.export_csv_to_file(path)
        vim.notify('Exported to ' .. path, vim.log.levels.INFO)
    end, { nargs = '?', desc = 'Export time tracking data to CSV', complete = 'file' })

    vim.api.nvim_create_user_command('TimeArchive', function()
        local file, err = tracker.archive()
        if err then
            vim.notify('Archive: ' .. err, vim.log.levels.WARN)
        else
            vim.notify('Closed tasks archived to ' .. file, vim.log.levels.INFO)
        end
    end, { desc = 'Archive closed tasks to a separate file' })

    vim.api.nvim_create_user_command('TimeList', function()
        require('plugins.telescope.timetracker').open()
    end, { desc = 'List tracked tasks in Telescope' })

    vim.api.nvim_create_user_command('JiraView', function(opts)
        local ticket_id = opts.args
        if ticket_id == '' then
            vim.notify('Usage: :JiraView <TICKET_ID>', vim.log.levels.ERROR)
            return
        end

        vim.notify('Fetching ' .. ticket_id .. '...', vim.log.levels.INFO)
        jira_fetch(ticket_id, function(json, fields)
            local hq_project = fields.customfield_10035 or 'N/A'
            local estimate = 'N/A'
            if fields.timetracking and fields.timetracking.originalEstimate then
                estimate = fields.timetracking.originalEstimate
            end
            local time_spent = 'N/A'
            if fields.timetracking and fields.timetracking.timeSpent then
                time_spent = fields.timetracking.timeSpent
            end
            local remaining = 'N/A'
            if fields.timetracking and fields.timetracking.remainingEstimate then
                remaining = fields.timetracking.remainingEstimate
            end

            local lines = {
                '# ' .. (json.key or ticket_id) .. ': ' .. (fields.summary or ''),
                '',
                'Type:              ' .. ((fields.issuetype or {}).name or 'N/A'),
                'Status:            ' .. ((fields.status or {}).name or 'N/A'),
                'Priority:          ' .. ((fields.priority or {}).name or 'N/A'),
                'Assignee:          ' .. ((fields.assignee or {}).displayName or 'Unassigned'),
                'Jobnummer (HQ):    ' .. hq_project,
                'Original Estimate: ' .. estimate,
                'Time Spent:        ' .. time_spent,
                'Remaining:         ' .. remaining,
                '',
                '---',
                '',
            }

            -- Description: JIRA API v3 returns ADF
            local desc = fields.description or 'No description'
            if type(desc) == 'table' then
                local function extract_text(node)
                    local parts = {}
                    if node.text then
                        table.insert(parts, node.text)
                    end
                    if node.content then
                        for _, child in ipairs(node.content) do
                            local child_text = extract_text(child)
                            if child_text ~= '' then
                                table.insert(parts, child_text)
                            end
                        end
                    end
                    return table.concat(parts, '')
                end
                local adf_parts = {}
                if desc.content then
                    for _, block in ipairs(desc.content) do
                        table.insert(adf_parts, extract_text(block))
                    end
                end
                desc = table.concat(adf_parts, '\n\n')
            end

            for _, line in ipairs(vim.split(desc, '\n')) do
                table.insert(lines, line)
            end

            -- Open in a floating window
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].filetype = 'markdown'
            vim.bo[buf].modifiable = false
            vim.bo[buf].bufhidden = 'wipe'

            local width = math.min(100, vim.o.columns - 10)
            local height = math.min(#lines + 2, vim.o.lines - 10)
            local row = math.floor((vim.o.lines - height) / 2)
            local col = math.floor((vim.o.columns - width) / 2)

            vim.api.nvim_open_win(buf, true, {
                relative = 'editor',
                width = width,
                height = height,
                row = row,
                col = col,
                style = 'minimal',
                border = 'rounded',
                title = ' ' .. (json.key or ticket_id) .. ' ',
                title_pos = 'center',
            })

            -- Close with q or Esc
            vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
            vim.keymap.set('n', '<Esc>', '<cmd>close<CR>', { buffer = buf, silent = true })
        end)
    end, { nargs = 1, desc = 'View JIRA issue description' })

    -- Keymaps
    vim.keymap.set('n', '<leader>ts', ':Start ', { desc = 'TimeTracker: Start' })
    vim.keymap.set('n', '<leader>te', ':End ', { desc = 'TimeTracker: End' })
    vim.keymap.set('n', '<leader>tl', '<cmd>TimeList<CR>', { desc = 'TimeTracker: List' })
    vim.keymap.set('n', '<leader>tx', '<cmd>TimeExport<CR>', { desc = 'TimeTracker: Export CSV' })
    vim.keymap.set('n', '<leader>tj', ':JiraView ', { desc = 'TimeTracker: View JIRA issue' })
end

return M
