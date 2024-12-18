local M = {};

M.setup = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
    local lspconfig = require('lspconfig');

    lspconfig.phpactor.setup {
        capabilities = capabilities,
        init_options = {
            ['symfony.enabled'] = true,
        },
        filetypes = {
            'php',
            'blade',
        }
    }
    local twiggy = vim.fn.stdpath('data') .. '/mason/bin/twiggy-language-server';
    local psalm = vim.fn.stdpath('data') .. '/mason/packages/psalm/vendor/bin/psalm-language-server';

    lspconfig.twiggy_language_server.setup {
        capabilities = capabilities,
        cmd = { twiggy, '--stdio' },
    }

    lspconfig.psalm.setup {
        capabilities = capabilities,
        cmd = { psalm }
    }
end

return M;
