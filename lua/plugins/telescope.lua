local M = {};

M.init = function()
    return {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-dap.nvim',
                config = function()
                    require('telescope').load_extension(
                        'dap')
                end
            },
            { 'nvim-telescope/telescope-fzf-native.nvim',     build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
            { 'nvim-telescope/telescope-live-grep-args.nvim', version = "^1.0.0" }
        }
    }
end


M.setup = function()
    local telescope = require('telescope');
    local lga_actions = require("telescope-live-grep-args.actions");

    local excludeDirs = {
        'node_modules',
        'vendor',
        'var',
    };

    telescope.setup({
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        extensions = {
            live_grep_args = {
                auto_quoting = true,
                mappings = {
                    i = {
                        ["<C-k>"] = lga_actions.quote_prompt(),
                        ["<C-i>"] = lga_actions.quote_prompt({ postfix = ' --iglob' }),
                        ['<C-Space>'] = lga_actions.to_fuzzy_refine,
                    }
                }
            }
        }
    });
    telescope.load_extension('dap');
    telescope.load_extension('fzf');
    telescope.load_extension('live_grep_args');

    vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = "Telescope: Find Files" });
    vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
    vim.keymap.set('n', '<leader>fs', '<cmd>Telescope live_grep<CR>', { desc = "Telescope: Live Grep" });
    vim.keymap.set('n', '<leader>fc', '<cmd>Telescope grep_string<CR>', { desc = "Telescope: Grep String" });
    vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = "Telescope: Buffers" });
end


return M;
