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

    local php_cs_fixer_config_files = {
        ".php-cs-fixer.conf.php",
        ".php-cs-fixer.dist.php",
        ".php_cs",
        ".php_cs.dist",
        ".php_cs.dist.php",
        ".php_cs.php",
    }

    local php_cs_fixer_config_file = nil;

    for _, file in ipairs(php_cs_fixer_config_files) do
        -- check if one of the php-cs-fixer config files exists
        if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. file) == 1 then -- check if the file exists in the current directory
            php_cs_fixer_config_file = vim.fn.getcwd() .. "/" .. file;
            break;
        end

        if vim.fn.filereadable(vim.fn.getcwd() .. "/pimcore/" .. file) == 1 then
            php_cs_fixer_config_file = vim.fn.getcwd() .. "/pimcore/" .. file;
            break;
        end
    end

    if php_cs_fixer_config_file == nil then
        php_cs_fixer_config_file = vim.fn.stdpath('config') .. "/third-party/php-cs-fixer/.php-cs-fixer.conf.php";
    end

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
                    "--config=" .. php_cs_fixer_config_file,
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
