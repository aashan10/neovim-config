local M = {};

M.init = function()
    return {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                build = 'make'
            }
        }
    }
end


M.setup = function()
    local telescope = require('telescope');

    telescope.setup();
    telescope.load_extension('fzf');

    vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = "Telescope: Find Files" });
    vim.keymap.set('n', '<leader>fs', '<cmd>Telescope live_grep<CR>', { desc = "Telescope: Live Grep" });
    vim.keymap.set('n', '<leader>fc', '<cmd>Telescope grep_string<CR>', { desc = "Telescope: Grep String" });
end


return M;

