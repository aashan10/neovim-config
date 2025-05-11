local Composer = require("utils.composer")
local DotEnv = require("utils.dotenv")

local M = {}

-- Cache to avoid reprocessing the same project root repeatedly in a session
local processed_roots = {}

M.is_symfony_project = function(path)
    -- Use 'not' for boolean negation, it's clearer in Lua
    if not Composer.is_composer_project(path) then
        return false
    end

    local deps = Composer.get_deps(path)

    if not deps then
        return false
    end

    -- Check if specific Symfony/Pimcore packages exist
    local packages_to_look = { "symfony/console", "pimcore/pimcore", "symfony/framework-bundle" }

    for _, package_name in ipairs(packages_to_look) do
        -- Use the method from the Dependencies object returned by get_deps
        if deps:package_exists(package_name) then
            return true
        end
    end

    return false
end

-- Loads environment variables based on Symfony's .env pattern
-- Returns the determined APP_ENV value (e.g., "dev", "prod")
M.load_project_env = function(path)
    if not path or path == "" then return nil end

    -- Reset dotenv state before loading for a new project path
    -- Note: This assumes load_project_env is the main entry point per project.
    -- If called multiple times for the same path without reset elsewhere, it might behave unexpectedly.
    DotEnv.reset_env()

    -- 1. Load base .env file
    DotEnv.load(path .. "/.env")

    -- 2. Determine APP_ENV (check common names)
    local app_env = DotEnv.get("APP_ENV")
    if not app_env then
        app_env = DotEnv.get("APP_ENVIRONMENT")
    end
    -- Default to "dev" if not found
    if not app_env or app_env == "" then
        app_env = "dev"
    end

    -- 3. Load environment-specific .env file (e.g., .env.dev)
    DotEnv.load(path .. "/.env." .. app_env)

    -- 4. Load .env.local if it exists (overrides everything else)
    DotEnv.load(path .. "/.env.local")

    return app_env -- Return the determined environment
end

-- Main function to set up the environment for a given buffer/path
M.setup_environment = function(project_root)
    if processed_roots[project_root] then
        return
    end

    if M.is_symfony_project(project_root) then
        local app_env = M.load_project_env(project_root)
        if app_env then
            processed_roots[project_root] = true
        end
    else
        vim.notify("Currently opened directory/file is not a symfony application root", vim.log.levels.WARN)
    end
end

-- Function to clear the processed roots cache (e.g., on VimLeave?)
M.clear_cache = function()
    processed_roots = {}
end

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local cwd = vim.fn.getcwd()

        if not M.is_symfony_project(cwd) then
            vim.notify("No symfony/console package found in composer.json", vim.log.levels.WARN)
            return
        end

        M.setup_environment(cwd)

        vim.notify("Loaded Symfony environment for " .. cwd, vim.log.levels.INFO)
    end,
    desc = "Load Symfony environment on VimEnter"
})

M.get_commands = function()
    local console = DotEnv.get("CONSOLE_COMMAND")

    if nil == console then
        vim.notify("CONSOLE_COMMAND not set", vim.log.levels.WARN)
        return
    end

    local command = console .. " list --format=json"

    local json = vim.fn.system(command)

    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to execute command: " .. command, vim.log.levels.ERROR)
        return
    end

    local ok, data = pcall(vim.json.decode, json)

    if not ok then
        vim.notify("Failed to parse JSON: " .. data, vim.log.levels.ERROR)
        return
    end

    return data.commands
end

M.show_commands = function()
    local commands = M.get_commands()
    if not commands then
        vim.notify("No commands found", vim.log.levels.WARN)
        return
    end

    local telescope = require('telescope')
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local previewers = require('telescope.previewers')

    -- Format command details for preview
    local function format_command_preview(command_data)
        local lines = {}

        table.insert(lines, "## " .. command_data.name)
        table.insert(lines, "")
        table.insert(lines, command_data.description)
        table.insert(lines, "")

        if command_data.help then
            table.insert(lines, command_data.help)
            table.insert(lines, "")
        end

        -- Add usage
        if command_data.usage then
            table.insert(lines, "## Usage")
            if type(command_data.usage) == "table" then
                for _, usage in ipairs(command_data.usage) do
                    table.insert(lines, usage)
                end
            else
                table.insert(lines, command_data.usage)
            end
            table.insert(lines, "")
        end

        -- Add arguments
        if command_data.definition and command_data.definition.arguments then
            local has_arguments = false
            for _ in pairs(command_data.definition.arguments) do
                has_arguments = true
                break
            end

            if has_arguments then
                table.insert(lines, "## Arguments")
                for arg_name, arg_data in pairs(command_data.definition.arguments) do
                    table.insert(lines, "  " .. arg_name .. ": " .. arg_data.description)
                    if arg_data.default then
                        table.insert(lines, "    Default: " .. tostring(arg_data.default))
                    end
                    table.insert(lines, "")
                end
            end
        end

        -- Add options
        if command_data.definition and command_data.definition.options then
            table.insert(lines, "## Options")
            for opt_name, opt_data in pairs(command_data.definition.options) do
                local display_name = "--" .. opt_name
                if opt_data.shortcut and opt_data.shortcut ~= "" then
                    display_name = opt_data.shortcut .. ", " .. display_name
                end

                table.insert(lines, "  " .. display_name .. ": " .. opt_data.description)
                if opt_data.default ~= nil and opt_data.default ~= false then
                    table.insert(lines, "    Default: " .. tostring(opt_data.default))
                end
                table.insert(lines, "")
            end
        end

        return table.concat(lines, "\n")
    end

    -- Create a new buffer for command output
    local function create_output_buffer(command)
        -- Create new buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(buf, 'swapfile', false)
        vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
        vim.api.nvim_buf_set_name(buf, "Symfony: " .. command)

        -- Open buffer in a new window
        vim.cmd('vsplit')
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)

        return buf
    end

    -- Execute command and stream output to buffer
    local function stream_command_to_buffer(cmd, buf)
        local job_id = vim.fn.jobstart(cmd, {
            on_stdout = function(_, data)
                if data then
                    vim.schedule(function()
                        vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                    end)
                end
            end,
            on_stderr = function(_, data)
                if data then
                    vim.schedule(function()
                        -- Add stderr output in red (requires nvim_buf_add_highlight)
                        local start_line = vim.api.nvim_buf_line_count(buf)
                        vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                        local end_line = vim.api.nvim_buf_line_count(buf)
                        for i = start_line, end_line - 1 do
                            vim.api.nvim_buf_add_highlight(buf, -1, "Error", i, 0, -1)
                        end
                    end)
                end
            end,
            stdout_buffered = false,
            stderr_buffered = false
        })
        return job_id
    end

    -- Get user input for each argument and option
    local function execute_command_guided(command_name, command_data)
        local console = DotEnv.get("CONSOLE_COMMAND")
        if not console then
            vim.notify("CONSOLE_COMMAND not set", vim.log.levels.ERROR)
            return
        end

        local cmd_parts = { console, command_name }

        -- Function to ask for user input
        local function ask_input(prompt, default)
            local default_text = default and (" [" .. default .. "]") or ""
            local input = vim.fn.input(prompt .. default_text .. ": ")
            if input == "" and default then
                return default
            end
            return input
        end

        -- Process arguments if they exist
        if command_data.definition and command_data.definition.arguments then
            local has_arguments = false
            for _ in pairs(command_data.definition.arguments) do
                has_arguments = true
                break
            end

            if has_arguments then
                vim.api.nvim_echo({ { "Arguments for " .. command_name .. ":", "Title" } }, true, {})

                for arg_name, arg_data in pairs(command_data.definition.arguments) do
                    local prompt = arg_name
                    if arg_data.description then
                        prompt = prompt .. " (" .. arg_data.description .. ")"
                    end

                    local value = ask_input(prompt, arg_data.default)
                    if value ~= "" then
                        table.insert(cmd_parts, value)
                    end
                end
            end
        end

        -- Process options
        if command_data.definition and command_data.definition.options then
            vim.api.nvim_echo({ { "Options for " .. command_name .. ":", "Title" } }, true, {})

            for opt_name, opt_data in pairs(command_data.definition.options) do
                -- Skip help, quiet, verbose etc. options
                if opt_name == "help" or opt_name == "quiet" or opt_name == "verbose" then
                    goto continue
                end

                local prompt = "--" .. opt_name
                if opt_data.shortcut and opt_data.shortcut ~= "" then
                    prompt = opt_data.shortcut .. " / " .. prompt
                end

                if opt_data.description then
                    prompt = prompt .. " (" .. opt_data.description .. ")"
                end

                -- For boolean options (no value required)
                if not opt_data.accept_value or not opt_data.is_value_required then
                    local yes_no = ask_input(prompt .. " (y/n)", "n")
                    if yes_no:lower() == "y" or yes_no:lower() == "yes" then
                        table.insert(cmd_parts, "--" .. opt_name)
                    end
                else
                    -- For options with values
                    local default = opt_data.default
                    if default == nil then default = "" end

                    local value = ask_input(prompt, default)
                    if value ~= "" then
                        table.insert(cmd_parts, "--" .. opt_name .. "=" .. value)
                    end
                end

                ::continue::
            end
        end

        -- Build and execute the command
        local cmd_string = table.concat(cmd_parts, " ")
        local buf = create_output_buffer(command_name)

        -- Show command that's being executed
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Executing: " .. cmd_string, "", "" })

        -- Execute and stream output
        stream_command_to_buffer(cmd_string, buf)
    end

    -- Execute command with manual input
    local function execute_command_manual(command_name)
        local console = DotEnv.get("CONSOLE_COMMAND")
        if not console then
            vim.notify("CONSOLE_COMMAND not set", vim.log.levels.ERROR)
            return
        end

        local base_cmd = console .. " " .. command_name
        local args = vim.fn.input("Command arguments: ")
        local cmd_string = base_cmd .. " " .. args

        local buf = create_output_buffer(command_name)

        -- Show command that's being executed
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Executing: " .. cmd_string, "", "" })

        -- Execute and stream output
        stream_command_to_buffer(cmd_string, buf)
    end

    -- Format each command as "command.name (command.description)"
    local items = {}
    for _, cmd_data in ipairs(commands) do
        table.insert(items, {
            value = cmd_data.name,
            display = cmd_data.name .. " (" .. cmd_data.description .. ")",
            data = cmd_data, -- Store the full command data
        })
    end

    -- Create and display the picker
    pickers.new({}, {
        prompt_title = "Symfony Commands",
        finder = finders.new_table({
            results = items,
            entry_maker = function(entry)
                return {
                    value = entry.value,
                    display = entry.display,
                    ordinal = entry.value, -- For sorting and filtering
                    data = entry.data,     -- Command data for preview and execution
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
            title = "Command Details",
            define_preview = function(self, entry, status)
                local preview_text = format_command_preview(entry.data)
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(preview_text, "\n"))

                -- Apply syntax highlighting
                vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
            end,
        }),
        attach_mappings = function(prompt_bufnr, map)
            -- Execute the selected command in guided mode (Enter)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                execute_command_guided(selection.value, selection.data)
            end)

            -- Execute command with manual input (Ctrl+e)
            map("i", "<C-e>", function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                execute_command_manual(selection.value)
            end)

            -- Show keybindings help (?)
            map("i", "?", function()
                vim.api.nvim_echo({
                    { "Symfony Commands Keybindings:", "Title" }, { "\n" },
                    { "Enter",                         "Special" }, { " - Execute command with guided input\n" },
                    { "Ctrl+e", "Special" }, { " - Execute command with manual input\n" },
                    { "?",      "Special" }, { " - Show this help\n" },
                }, true, {})
            end)

            return true
        end,
    }):find()
end
return M
