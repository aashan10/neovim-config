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

keymap('n', '<leader>gs', ':lua GotoMacroSource()<CR>', { noremap = true, silent = true })



keymap('n', '[d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', ']d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', '<leader>bad', '<cmd>bufdo :bdelete<CR>', { desc = "Delete all buffers" })
keymap('n', '<C-i>', '<cmd>Inspect<CR>', { desc = "Inspect Current Char" })
