local M = {};

M.setup = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
    local lspconfig = require('lspconfig');

    local tsserver = vim.fn.stdpath('data') .. '/mason/bin/typescript-language-server';

    lspconfig.tsserver.setup {
        capabilities = capabilities,
        cmd = { tsserver, '--stdio' },
        init_options = {
            plugins = {
                {
                    name = '@vue/typescript-plugin',
                    location = vim.fn.stdpath('data') .. '/mason/packages/vue-language-server/node_modules/@vue/language-server',
                    languages = { 'vue' }
                }
            }
        },
        filetypes = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' }
    }

    lspconfig.volar.setup {
        capabilities = capabilities,
        init_options = {
            vue = {
                hybridMode = false
            }
        }
    }

end

return M;
