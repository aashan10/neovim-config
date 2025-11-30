-- lua/utils/passbolt.lua
-- Utility module for interacting with the Passbolt CLI and providing a Telescope picker.
-- Requires plenary.nvim (https://github.com/nvim-lua/plenary.nvim)
-- Requires nvim-telescope/telescope.nvim

local Job = require('plenary.job')
local trim = vim.fn.trim -- Helper for trimming strings

-- Internal state and configuration
local H = {
    config = {
        cli_name = "passbolt",                                          -- Default CLI command name
        config_file = "~/.config/go-passbolt-cli/go-passbolt-cli.toml", -- Path to a potential config file (currently not used by passbolt CLI directly in this script)
    }
}

-- Telescope specific requires
local telescope_ok, telescope = pcall(require, 'telescope')
local finders_ok, finders -- Defer requiring until telescope_ok is confirmed
local pickers_ok, pickers
local actions_ok, actions
local action_state_ok, action_state
local previewers_ok, previewers
local sorters_ok, sorters
local conf_ok, conf

if telescope_ok then
    finders_ok, finders = pcall(require, 'telescope.finders')
    pickers_ok, pickers = pcall(require, 'telescope.pickers')
    actions_ok, actions = pcall(require, 'telescope.actions')
    action_state_ok, action_state = pcall(require, 'telescope.actions.state')
    previewers_ok, previewers = pcall(require, 'telescope.previewers')
    sorters_ok, sorters = pcall(require, 'telescope.sorters')
    conf_ok, conf = pcall(require, 'telescope.config')
    if conf_ok then
        conf = conf.values -- telescope.config returns a table, .values is the actual config
    end
else
    vim.notify("Telescope plugin is not available. Passbolt picker functionality will be disabled.", vim.log.levels.WARN)
end

--- Internal helper function to copy text to the system clipboard.
-- Tries common clipboard tools for Linux, macOS, and Windows.
-- Falls back to Neovim's '+' register if available.
-- @param text_to_copy (string) The text to be copied.
-- @param item_name (string) The name of the item being copied (for notifications).
-- @param item_type (string) The type of item being copied, e.g., "Username", "Password" (for notifications).
-- @return (boolean) true if copying was successful, false otherwise.
local function copy_to_clipboard(text_to_copy, item_name, item_type)
    if not text_to_copy or text_to_copy == "" then
        vim.notify("Passbolt: No " .. item_type .. " to copy for '" .. item_name .. "'.", vim.log.levels.WARN)
        return false
    end

    local success = false
    local clipboard_tool_used = nil
    local os_type = ""

    if vim.fn.has("macunix") == 1 or vim.fn.has("macos") == 1 then
        os_type = "macOS"
        if vim.fn.executable("pbcopy") == 1 then
            clipboard_tool_used = "pbcopy"
            local job = Job:new({ command = "pbcopy" })
            job:sync({ stdin = text_to_copy })
            if job.code == 0 then success = true end
        end
    elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        os_type = "Windows"
        if vim.fn.executable("clip") == 1 then
            clipboard_tool_used = "clip.exe"
            local job = Job:new({ command = "clip.exe" })
            job:sync({ stdin = text_to_copy })
            if job.code == 0 then success = true end
        end
    else -- Assume Linux/other Unix-like
        os_type = "Linux/Unix"
        if vim.fn.executable("xclip") == 1 then
            clipboard_tool_used = "xclip"
            local job = Job:new({ command = "xclip", args = { "-selection", "clipboard" } })
            job:sync({ stdin = text_to_copy })
            if job.code == 0 then success = true end
        elseif vim.fn.executable("xsel") == 1 then
            clipboard_tool_used = "xsel"
            local job = Job:new({ command = "xsel", args = { "--clipboard", "--input" } })
            job:sync({ stdin = text_to_copy })
            if job.code == 0 then success = true end
        end
    end

    if success then
        vim.notify(
            item_type ..
            " for '" .. item_name .. "' copied to clipboard (using " .. clipboard_tool_used .. " on " .. os_type .. ").",
            vim.log.levels.INFO)
        return true
    else
        if vim.fn.has('clipboard') == 1 then
            vim.fn.setreg('+', text_to_copy)
            vim.notify(item_type .. " for '" .. item_name .. "' copied to clipboard (+ register).", vim.log.levels.INFO)
            return true
        else
            local msg = "Passbolt: Failed to copy " .. item_type .. " to clipboard. "
            if clipboard_tool_used then
                msg = msg .. "Attempted with " .. clipboard_tool_used .. " but failed. "
            else
                msg = msg .. "No suitable clipboard tool (pbcopy, clip, xclip, xsel) found for " .. os_type .. ". "
            end
            msg = msg .. "Neovim clipboard support ('+'' register) also unavailable or failed."
            vim.notify(msg, vim.log.levels.ERROR)
            return false
        end
    end
end


-- Internal helper function to run shell commands synchronously
-- @param cmd_args (table) A list of strings representing the command and its arguments.
-- @return (table|nil) result_lines: table of output lines, or nil on error
-- @return (table|nil) error_lines: table of stderr lines, or nil if no error output or command success
-- @return (number|nil) exit_code: command exit code, or nil on job error
local function run_command(cmd_args_without_cli_name)
    -- Prepend the configured CLI name
    local full_cmd_args = vim.deepcopy(cmd_args_without_cli_name)
    table.insert(full_cmd_args, 1, H.config.cli_name)
    table.insert(full_cmd_args, "--config")
    table.insert(full_cmd_args, H.config.config_file)

    if vim.fn.executable(full_cmd_args[1]) == 0 then
        vim.notify(
            "Passbolt CLI command '" .. full_cmd_args[1] .. "' not found. Please ensure it's installed and in your PATH.",
            vim.log.levels.ERROR)
        return nil, { "Passbolt CLI '" .. full_cmd_args[1] .. "' not found" }, -1
    end

    local output, err_output, code
    local job = Job:new({
        command = full_cmd_args[1],
        args = vim.list_slice(full_cmd_args, 2),
        -- Consider adding H.config.config_file to args if the CLI supports it
        -- e.g., if H.config.config_file then table.insert(args, "--config-file"); table.insert(args, H.config.config_file) end
    })
    job:sync() -- Run synchronously

    -- Plenary job:result() and job:stderr_result() return tables of lines
    output = job:result()
    err_output = job:stderr_result()
    code = job.code -- Access exit code directly from job object

    return output, err_output, code
end

local M = {}

--- Sets up the Passbolt utility module.
-- @param custom_config (table, optional) A table with configuration options.
--   - cli_name (string, optional): The name of the Passbolt CLI executable. Defaults to "passbolt".
--   - config_file (string, optional): Path to a custom config file (if supported/needed). Defaults to nil.
function M.setup(custom_config)
    custom_config = custom_config or {}
    if custom_config.cli_name and type(custom_config.cli_name) == "string" then
        H.config.cli_name = custom_config.cli_name
    end
    if custom_config.config_file and type(custom_config.config_file) == "string" then
        H.config.config_file = custom_config.config_file
    end
    -- You could add more specific config options here
    vim.notify("Passbolt utility configured. CLI: " .. H.config.cli_name, vim.log.levels.INFO)
end

--- Lists resources from Passbolt.
-- Executes "<cli_name> ls resources -c ID -c Username -C Name"
-- @return (table|nil) A list of resource tables, e.g., {{id="...", username="...", name="..."}, ...},
--                     or nil if an error occurred or no resources found.
function M.list_resources()
    -- Note: run_command now prepends H.config.cli_name
    local cmd_args = { "list", "resources", "-c", "ID", "-c", "Username", "-c", "Name" }
    local output_lines, err_lines, exit_code = run_command(cmd_args)

    if exit_code ~= 0 or not output_lines then
        local err_msg = "Error listing Passbolt resources (using " .. H.config.cli_name .. ")."
        if err_lines and #err_lines > 0 then
            err_msg = err_msg .. " Details: " .. table.concat(err_lines, " ")
        elseif exit_code ~= 0 then
            err_msg = err_msg .. " Exit code: " .. tostring(exit_code)
        end
        vim.notify(err_msg, vim.log.levels.WARN)
        return nil
    end

    local resources = {}
    for i = 2, #output_lines do -- Skip header line
        local line = output_lines[i]
        if line and line ~= "" then
            local parts = {}
            for part in vim.gsplit(line, "|", true) do
                table.insert(parts, trim(part))
            end

            if #parts == 3 then
                table.insert(resources, {
                    id = parts[1],
                    username = parts[2],
                    name = parts[3],
                })
            else
                vim.notify("Passbolt: Malformed line in ls output: " .. line, vim.log.levels.WARN)
            end
        end
    end

    if #resources == 0 then
        vim.notify("Passbolt: No resources found.", vim.log.levels.INFO)
        return {}
    end

    return resources
end

--- Gets details for a specific Passbolt resource.
-- Executes "<cli_name> get resource --id <resource_id>"
-- @param resource_id (string) The ID of the resource.
-- @return (table|nil) A table mapping detail keys to values (e.g., {Name="...", Username="...", ...}),
--                     or nil if an error occurred.
function M.get_resource_details(resource_id)
    if not resource_id or resource_id == "" then
        vim.notify("Passbolt: Resource ID is required for get_resource_details.", vim.log.levels.ERROR)
        return nil
    end

    local cmd_args = { "get", "resource", "--id", resource_id }
    local output_lines, err_lines, exit_code = run_command(cmd_args)

    if exit_code ~= 0 or not output_lines then
        local err_msg = "Error getting Passbolt resource details for ID: " .. resource_id
        if err_lines and #err_lines > 0 then
            err_msg = err_msg .. " Details: " .. table.concat(err_lines, " ")
        elseif exit_code ~= 0 then
            err_msg = err_msg .. " Exit code: " .. tostring(exit_code)
        end
        vim.notify(err_msg, vim.log.levels.WARN)
        return nil
    end

    local details = {}
    for _, line in ipairs(output_lines) do
        if line and line ~= "" then
            local key, value = line:match("^([^:]+):%s*(.*)$")
            if key and value then
                details[trim(key)] = trim(value)
            elseif key then
                details[trim(key)] = ""
            end
        end
    end
    return details
end

--- Gets the password for a specific Passbolt resource.
-- Executes "<cli_name> get resource --id <resource_id> -f Password"
-- @param resource_id (string) The ID of the resource.
-- @return (string|nil) The password string, or nil if an error occurred or password not found/empty.
function M.get_password(resource_id)
    if not resource_id or resource_id == "" then
        vim.notify("Passbolt: Resource ID is required for get_password.", vim.log.levels.ERROR)
        return nil
    end

    local cmd_args = { "get", "resource", "--id", resource_id, "-f", "Password" }
    local output_lines, err_lines, exit_code = run_command(cmd_args)

    if exit_code ~= 0 or not output_lines then
        local err_msg = "Error getting Passbolt password for ID: " .. resource_id
        if err_lines and #err_lines > 0 then
            err_msg = err_msg .. " Details: " .. table.concat(err_lines, " ")
        elseif exit_code ~= 0 then
            err_msg = err_msg .. " Exit code: " .. tostring(exit_code)
        end
        vim.notify(err_msg, vim.log.levels.WARN)
        return nil
    end

    if #output_lines > 0 and output_lines[1] ~= "" then
        return output_lines[1]
    else
        vim.notify("Passbolt: Password not found or is empty for resource ID: " .. resource_id, vim.log.levels.INFO)
        return nil
    end
end

--- Opens a Telescope picker for Passbolt resources.
-- @param opts (table, optional) Telescope options.
function M.open_picker(opts)
    if not telescope_ok or not finders_ok or not pickers_ok or not actions_ok or not action_state_ok or not previewers_ok or not sorters_ok or not conf_ok then
        vim.notify("Telescope or its submodules are not properly loaded. Cannot open Passbolt picker.",
            vim.log.levels.ERROR)
        return
    end

    opts = opts or {}
    local resources = M.list_resources()
    if not resources then
        vim.notify("Passbolt: Could not load resources for Telescope.", vim.log.levels.WARN)
        return
    end
    if #resources == 0 then
        return
    end

    pickers.new(opts, {
        prompt_title = "Passbolt Resources (" .. H.config.cli_name .. ")", -- Show configured CLI name
        finder = finders.new_table({
            results = resources,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format("%s  (%s)", entry.name, entry.username),
                    ordinal = entry.name .. " " .. entry.username,
                    id = entry.id,
                    name = entry.name,
                    username = entry.username,
                }
            end,
        }),
        sorter = sorters.get_generic_fuzzy_sorter(opts),
        previewer = previewers.new_buffer_previewer({
            title = "Resource Details",
            define_preview = function(self, entry, status)
                if not entry.value or not entry.value.id then
                    vim.api.nvim_buf_set_lines(self.state.preview_bufnr, 0, -1, false, { "Invalid entry or missing ID." })
                    return
                end

                vim.defer_fn(function()
                    local details_map = M.get_resource_details(entry.value.id)
                    if not details_map then
                        if vim.api.nvim_buf_is_valid(self.state.preview_bufnr) then
                            vim.api.nvim_buf_set_lines(self.state.preview_bufnr, 0, -1, false,
                                { "Error fetching details." })
                        end
                        return
                    end

                    local display_lines = {}
                    local preferred_order = { "Name", "Username", "URI", "FolderParentID", "Description" }
                    local seen_keys = {}

                    for _, key in ipairs(preferred_order) do
                        if details_map[key] ~= nil then
                            table.insert(display_lines, string.format("%s: %s", key, details_map[key]))
                            seen_keys[key] = true
                        end
                    end

                    local other_keys = {}
                    for key, _ in pairs(details_map) do
                        if not seen_keys[key] then
                            table.insert(other_keys, key)
                        end
                    end
                    table.sort(other_keys)
                    for _, key in ipairs(other_keys) do
                        table.insert(display_lines, string.format("%s: %s", key, details_map[key]))
                    end

                    if vim.api.nvim_buf_is_valid(self.state.preview_bufnr) then
                        vim.api.nvim_buf_set_lines(self.state.preview_bufnr, 0, -1, false, display_lines)
                    end
                end, 0)
            end,
        }),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if not selection or not selection.value or not selection.value.id then
                    vim.notify("Passbolt: No valid selection to get password.", vim.log.levels.WARN)
                    return
                end
                local password = M.get_password(selection.value.id)
                if copy_to_clipboard(password, selection.value.name, "Password") then
                    actions.close(prompt_bufnr)
                end
            end)

            local function copy_username_action()
                local selection = action_state.get_selected_entry()
                if not selection or not selection.value or not selection.value.username then
                    vim.notify("Passbolt: No username to copy for selected item.", vim.log.levels.WARN)
                    return
                end
                copy_to_clipboard(selection.value.username, selection.value.name, "Username")
            end
            map("i", "<C-u>", copy_username_action)
            map("n", "<C-u>", copy_username_action)

            local function copy_password_action()
                local selection = action_state.get_selected_entry()
                if not selection or not selection.value or not selection.value.id then
                    vim.notify("Passbolt: No valid selection to get password.", vim.log.levels.WARN)
                    return
                end
                local password = M.get_password(selection.value.id)
                copy_to_clipboard(password, selection.value.name, "Password")
            end
            map("i", "<C-p>", copy_password_action)
            map("n", "<C-p>", copy_password_action)

            return true
        end,
    }):find()
end

return M
