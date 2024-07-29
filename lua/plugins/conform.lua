---@diagnostic disable: trailing-space

local M = {};

M.init = function()
    return {
        'stevearc/conform.nvim',
        lazy = true,
        event = { "BufReadPre", "BufNewFile" },
    }
end


M.setup = function()

    local conform = require('conform');
    conform.setup({ 
        formatters_by_ft = { 
            php = { "php" }, 
        }, 
        format_on_save = { 
            lsp_fallback = true, 
            async = false, 
            timeout_ms = 1000, 
        }, 
        notify_on_error = true, 
        formatters = { 
            php = { 
                command = "php-cs-fixer", 
                args = { 
                    "fix", 
                    "--rules=@Symfony",
                    "$FILENAME",
                }, 
                stdin = false,
            }
        }
    })

    vim.keymap.set('n', '<leader>f', conform.format, { desc = "Format" });

end

return M;

