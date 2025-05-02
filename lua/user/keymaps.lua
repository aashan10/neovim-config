local keymap = vim.keymap.set;

-- Custom function to navigate to @see annotation (file:line or class::method)
function GotoMacroSource()
    local api = vim.api
    local current_line = api.nvim_get_current_line()

    -- Case 1: File path and line number
    local file, line = current_line:match("@see%s+(%S+):(%d+)")
    if file and line then
        -- Expand relative path to full path
        local full_path = vim.fn.fnamemodify(file, ":p") -- Expand path to absolute
        -- Open file and jump to the specified line
        vim.cmd("e " .. full_path)
        vim.cmd(":" .. line)
        return
    end

    -- Case 2: Fully qualified class and method
    local class, method = current_line:match("@see%s+([%w\\_]+)::(%w+)")
    if class and method then
        -- Use LSP to find the definition
        vim.lsp.buf_request(0, 'textDocument/definition', {
            textDocument = vim.lsp.util.make_text_document_params(),
            position = vim.lsp.util.make_position_params().position
        }, function(_, result)
            if not result or vim.tbl_isempty(result) then
                print("Could not find definition for " .. class .. "::" .. method)
                return
            end

            -- Jump to the first result from LSP response
            local target = result[1]
            local uri = target.uri:sub(8) -- Strip 'file://' prefix
            local line_num = target.range.start.line + 1
            vim.cmd("e " .. uri)
            vim.cmd(":" .. line_num)
        end)
        return
    end

    -- Fallback if no valid @see pattern is found
    print("No valid @see annotation found on this line.")
end

-- Define the function to be called by the keymap
local function load_dotenv_file()
    local dotenv_path = 'utils.dotenv'

    -- Prompt the user for the .env file name (relative to current directory)
    vim.ui.input({ prompt = "Enter .env filename:", default = ".env" }, function(filename)
        -- Check if the user provided a filename (didn't cancel)
        if not filename then
            vim.notify("Dotenv load cancelled.", vim.log.levels.INFO)
            return
        end

        -- Construct the full path relative to the current working directory
        local file_path = vim.fn.getcwd() .. "/" .. filename

        -- Attempt to load the dotenv module
        local status, dotenv = pcall(require, dotenv_path)
        if not status then
            vim.notify("Failed to load dotenv module from: " .. dotenv_path, vim.log.levels.ERROR)
            return
        end

        -- Call the load function from the dotenv module
        -- Use pcall in case the load function itself errors unexpectedly
        local load_status, success = pcall(dotenv.load, file_path)

        if not load_status then
            -- Error occurred within the dotenv.load function itself (e.g., error operator ':?')
            vim.notify("Error during dotenv.load: " .. tostring(success), vim.log.levels.ERROR)
        elseif success then
            -- Success reported by dotenv.load
            vim.notify("Successfully loaded environment from: " .. filename, vim.log.levels.INFO)
        else
            -- Failure reported by dotenv.load (e.g., file not found, parse errors, expansion errors)
            vim.notify("Failed to load environment from: " .. filename .. ". Check messages.", vim.log.levels.WARN)
            -- Specific errors/warnings should have been notified by the dotenv module itself
        end
    end)
end

-- Set the keymap for <leader>le in normal mode
-- '<leader>le' stands for 'load environment'
vim.keymap.set('n', '<leader>le', load_dotenv_file, {
    noremap = true,                                              -- Non-recursive mapping
    silent = true,                                               -- Don't echo the command
    desc = "Load environment variables from specified .env file" -- Description for which-key etc.
})

keymap('n', '<leader>gs', ':lua GotoMacroSource()<CR>', { noremap = true, silent = true })



keymap('n', '[d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', ']d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', '<leader>bad', '<cmd>bufdo :bdelete<CR>', { desc = "Delete all buffers" })
keymap('n', '<C-i>', '<cmd>Inspect<CR>', { desc = "Inspect Current Char" })
keymap('n', '<leader>bc', function()
    local symfony = require("utils.symfony")
    local cwd = vim.fn.getcwd();

    if not symfony.is_symfony_project(cwd) then
        vim.notify("No symfony/console package found in composer.json", vim.log.levels.WARN)
        return
    end
    symfony.show_commands()
end, { desc = "Bring artisan|bin/console" })
