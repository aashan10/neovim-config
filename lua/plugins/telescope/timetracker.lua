local M = {
    name = 'timetracker',
    enabled = false, -- not a telescope extension, just a custom picker
}

M.dependencies = function()
    return {}
end

M.config = function()
    return {}
end

M.setup = function()
end

local function format_time(ts)
    if not ts or ts == vim.NIL then return 'N/A' end
    return os.date('%Y-%m-%d %H:%M:%S', ts)
end

local function make_entry(task)
    local info = ''
    if task.status == 'open' then
        -- Show elapsed time of the current open entry
        for _, entry in ipairs(task.entries) do
            if entry.status == 'open' then
                local mins = math.floor((os.time() - entry.start_time) / 60)
                info = string.format(' (current: %d min, total: %d min)', mins, task.total_duration + mins)
                break
            end
        end
    else
        info = string.format(' (total: %d min → %d min)', task.total_duration, task.total_rounded)
    end
    local entry_count = #task.entries
    local display = string.format('[%s] %s  HQ:%s  [%d entries]%s', task.status, task.ticket_id, task.hq_project, entry_count, info)
    -- Build ordinal from ticket ID, HQ project, and all entry descriptions
    local ordinal_parts = { task.ticket_id, task.hq_project }
    for _, entry in ipairs(task.entries) do
        if entry.description and entry.description ~= '' then
            table.insert(ordinal_parts, entry.description)
        end
    end

    return {
        value = task,
        display = display,
        ordinal = table.concat(ordinal_parts, ' '),
    }
end

local function make_previewer()
    local previewers = require('telescope.previewers')
    return previewers.new_buffer_previewer({
        title = 'Task Details',
        define_preview = function(self, entry)
            local task = entry.value
            local lines = {
                'Ticket:      ' .. (task.ticket_id or ''),
                'HQ Project:  ' .. (task.hq_project or ''),
                'Status:      ' .. (task.status or ''),
                'Entries:     ' .. tostring(#task.entries),
                'Total:       ' .. tostring(task.total_duration) .. ' min (rounded: ' .. tostring(task.total_rounded) .. ' min)',
                '',
            }
            for i, e in ipairs(task.entries) do
                table.insert(lines, string.format('--- Entry %d [%s] ---', i, e.status))
                table.insert(lines, '  Started:  ' .. format_time(e.start_time))
                if e.status == 'open' then
                    local mins = math.floor((os.time() - e.start_time) / 60)
                    table.insert(lines, '  Elapsed:  ' .. mins .. ' min')
                else
                    table.insert(lines, '  Ended:    ' .. format_time(e.end_time))
                    table.insert(lines, '  Duration: ' .. tostring(e.duration_minutes or '') .. ' min (rounded: ' .. tostring(e.rounded_minutes or '') .. ' min)')
                end
                local desc = e.description or ''
                if desc ~= '' then
                    table.insert(lines, '  Desc:     ' .. desc)
                end
                table.insert(lines, '')
            end
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        end,
    })
end

function M.open(show_all)
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local tracker = require('utils.timetracker')

    if show_all == nil then show_all = false end

    local filter = nil
    if not show_all then filter = 'open' end
    local tasks = tracker.list(filter)
    local title = show_all and 'Time Tracker (all)' or 'Time Tracker (open)'

    pickers.new({}, {
        prompt_title = title,
        finder = finders.new_table({
            results = tasks,
            entry_maker = make_entry,
        }),
        sorter = conf.generic_sorter({}),
        previewer = make_previewer(),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if entry and entry.value.status == 'open' then
                    vim.cmd('End ' .. entry.value.ticket_id)
                end
            end)

            local function toggle()
                actions.close(prompt_bufnr)
                local next_show_all = not show_all
                vim.schedule(function()
                    M.open(next_show_all)
                end)
            end

            map('i', '<Tab>', toggle)
            map('n', '<Tab>', toggle)

            return true
        end,
    }):find()
end

return M
