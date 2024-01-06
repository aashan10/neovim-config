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
    local actions = require('telescope.actions');

    telescope.setup();
    telescope.load_extension('fzf');

    vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', {desc = "Fuzzy find files in CWD"});
    vim.keymap.set('n', '<leader>fs', '<cmd>Telescope live_grep<CR>', {desc = "Fuzzy find string in CWD"});
    vim.keymap.set('n', '<leader>fc', '<cmd>Telescope grep_string<CR>', {desc = "Fuzzy find string under the cursor"});

end


return M;