local M = {};

M.setup = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
    local lspconfig = require('lspconfig');

    lspconfig.zls.setup {
        capabilities = capabilities,
        init_options = {
        }
    }
end

return M;
