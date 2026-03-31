local M = {};

M.setup_lsp = function()
    local lsps = {
        'go',
        'rust',
        'lua',
        'php',
        'html',
        'ts',
        "twig"
    };

    for _, lsp in ipairs(lsps) do
        require('plugins.lsp.' .. lsp).setup();
    end
end

M.init = function()
    return {
        { src = 'https://github.com/neovim/nvim-lspconfig' },
        { src = 'https://github.com/mason-org/mason.nvim' },
        { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
    }
end

M.setup = function()
    local lsps = {
        'lua_ls',
        'gopls',
        'rust_analyzer',
        'html',
        'tsgo',
        'twiggy_language_server'
    };
    require('mason').setup();
    require('mason-lspconfig').setup({
        ensure_installed = lsps,
        automatic_enable = false
    });

    M.setup_lsp();

    vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
    });

    local keymaps = {
        ['n'] = {
            ['<leader>dd'] = function()
                local opts = { desc = 'LSP: Show Diagnostics' }
                vim.diagnostic.open_float(opts)
            end,
            ['[d'] = function()
                local opts = { desc = 'LSP: Goto Previous Diagnostics', count = -1 }
                vim.diagnostic.jump(opts)
            end,
            [']d'] = function()
                local opts = { desc = 'LSP: Goto Next Diagnostics', count = 1 }
                vim.diagnostic.jump(opts)
            end,
            ['<leader>q'] = function()
                local opts = { desc = 'LSP: Add to Local List' }
                vim.diagnostic.setloclist(opts)
            end
        }
    };

    for mode, mappings in pairs(keymaps) do
        for key, func in pairs(mappings) do
            vim.keymap.set(mode, key, func)
        end
    end


    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            local keymaps = {
                ['n'] = {
                    ['gD'] = function()
                        local opts = { desc = 'LSP: Goto Declaration' }
                        vim.lsp.buf.declaration(opts)
                    end,
                    ['gd'] = function()
                        local opts = { desc = 'LSP: Goto Definition' }
                        vim.lsp.buf.definition(opts)
                    end,
                    ['K'] = function()
                        local opts = { desc = 'LSP: Hover' }
                        vim.lsp.buf.hover(opts)
                    end,
                    ['gi'] = function()
                        local opts = { desc = 'LSP: Show Implementations' }
                        require('telescope.builtin').lsp_implementations(opts)
                    end,
                    ['<C-k>'] = function()
                        local opts = { desc = 'LSP: Signature Help' }
                        vim.lsp.buf.signature_help(opts)
                    end,
                    ['<leader>wa'] = vim.lsp.buf.add_workspace_folder,
                    ['<leader>wr'] = vim.lsp.buf.remove_workspace_folder,
                    ['<leader>wl'] = function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end,
                    ['<leader>D'] = function()
                        local opts = { desc = 'LSP: Type Definitions' }
                        vim.lsp.buf.type_definition(opts)
                    end,
                    ['<leader>rn'] = vim.lsp.buf.rename,
                    ['<leader>ca'] = function()
                        local opts = { desc = 'LSP: Code Actions' }
                        vim.lsp.buf.code_action(opts)
                    end,
                    ['gr'] = function()
                        local opts = { desc = 'LSP: References' }
                        require('telescope.builtin').lsp_references(opts)
                    end,
                    ['<leader>lf'] = function()
                        local opts = { desc = 'LSP: Format', async = true }
                        vim.lsp.buf.format(opts)
                    end
                },
            };
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            for mode, mappings in pairs(keymaps) do
                for key, func in pairs(mappings) do
                    vim.keymap.set(mode, key, func, { buffer = ev.buf })
                end
            end
        end,
    })
end

return M;
