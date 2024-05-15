local M = {};

M.setup = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
    local lspconfig = require('lspconfig');

    local html = vim.fn.stdpath('data') .. '/mason/bin/vscode-html-language-server';

    lspconfig.tsserver.setup {
        capabilities = capabilities,
        cmd = { html, '--stdio' },
    }
end

return M;
