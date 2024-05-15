local M = {};

M.init = function()
    return {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets'
        }
    }
end


M.setup = function()
    local cmp = require('cmp');
    local luasnip = require('luasnip');

    require('luasnip.loaders.from_vscode').lazy_load()

    cmp.setup({
        snippet = {
            expand = function(args)
                luasnip.luasnip._expand(args.body)
            end
        },

        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'buffer' },
        }, {
            { name = 'path' },
        }),
        formatting = {
            fields = { 'menu', 'abbr', 'kind' },
            format = function(entry, item)
                local menu_icon = {
                    nvim_lsp = 'λ',
                    luasnip = '⋗',
                    buffer = 'Ω',
                    path = '🖫',
                }

                item.menu = menu_icon[entry.source.name]
                return item
            end,
        },
        mapping = {
            ['<Up>'] = cmp.mapping.select_prev_item(),
            ['<Down>'] = cmp.mapping.select_next_item(),

            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),

            ['<C-e>'] = cmp.mapping.abort(),
            ['<C-y>'] = cmp.mapping.confirm({ select = true }),
            ['<CR>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    if luasnip.expandable() then
                        luasnip.expand()
                    else
                        cmp.confirm({ select = true })
                    end
                else
                    fallback()
                end
            end),
       },


    })

    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        })
    })


    vim.keymap.set({ "i", "s" }, "<C-k>", function()
        if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        end
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-j>", function()
        if luasnip.jumpable(-1) then
            luasnip.jump(-1)
        end
    end, { silent = true })

    vim.keymap.set("i", "<C-l>", function()
        if luasnip.choice_active() then
            luasnip.change_choice(1)
        end
    end)
end

return M;
