
local M = {};

M.setup = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
    local lspconfig = require('lspconfig');
    local config = require('lspconfig.configs');

    config.pxp = {
        default_config = {
            cmd = { '/Users/aashan/Projects/pxp/target/debug/pxp-ls' },
            filetypes = { 'php' },
            root_dir = lspconfig.util.root_pattern('composer.json', '.git'),
            settings = {},
        },
    }

    lspconfig.pxp.setup {
        capabilities = capabilities,
    }
end

return M;
