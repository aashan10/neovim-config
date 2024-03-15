local M = {};

M.init = function()
    return {
        'neovim/nvim-lspconfig',
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        }
    }
end

M.setup = function()
    local lsps = {
        'lua_ls',
        'rust_analyzer',
        'phpactor',
        'yamlls',
        'html',
        'tsserver',
        'volar'
    };
    require('mason').setup();
    require('mason-lspconfig').setup({
        ensure_installed = lsps
    });
    local capabilities = require('cmp_nvim_lsp').default_capabilities();

    local lspconfig = require('lspconfig');
    lspconfig.lua_ls.setup {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' }
                }
            }
        },
        capabilities = capabilities
    }
    lspconfig.rust_analyzer.setup {
        capabilities = capabilities
    }
    lspconfig.phpactor.setup {
        capabilities = capabilities
    }

    lspconfig.tsserver.setup {
        capabilities = capabilities
    }

    lspconfig.html.setup = {
        capabilities = capabilities
    }

    lspconfig.bufls.setup {
        capabilities = capabilities
    }

    lspconfig.volar.setup = {
        capabilities = capabilities
    }

    vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = "LSP: Show Diagnostics" })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "LSP: Goto Previous Diagnostics" })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "LSP: Goto Next Disgnostics" })
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "LSP: Add to Local List" })


    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts, { desc = "LSP: Goto Declaration" })
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts, { desc = "LSP: Goto Definition" })
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts, { desc = "LSP: Hover" })
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts, { desc = "LSP: Show Implementations" })
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts, { desc = "LSP: Signature Help" })
            vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts, { desc = "LSP: Add Workspace Folder" })
            vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts, { desc = "LSP: Remove Workspace Folder" });
            vim.keymap.set('n', '<leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts, { desc = "LSP: List Workspace Folders" });
            vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts, { desc = "LSP: Type Definitions" });
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts, { desc = "LSP: Rename" });
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts, { desc = "LSP: Code Actions" });
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts, { desc = "LSP: References" });
            vim.keymap.set('n', '<leader>f', function()
                vim.lsp.buf.format { async = true }
            end, opts, { desc = "LSP: Format" });
        end,
    })
end

return M;
