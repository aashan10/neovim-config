local M = {};

M.setup = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
    local lspconfig = require('lspconfig');

    lspconfig.gopls.setup {
        capabilities = capabilities,
        cmd = { 'gopls', 'serve' },
    }

end

return M;
