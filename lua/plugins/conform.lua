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
            blade = { "blade-formatter" },
            twig = { "twig" }
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
            },
            twig = {
                command = "twig-cs-fixer",
                args = {
                    "$FILENAME",
                    "--profile=nunjucks",
                    "--reformat"
                }
            }
        },
        format_on_save = function(bufnr)
            if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
                return
            end
            return {
                timeout_ms = 1000,
                async = false,
                lsp_fallback = true,
            }
        end
    })

    vim.keymap.set('n', '<leader>f', conform.format, { desc = "Format" });
end

return M;
