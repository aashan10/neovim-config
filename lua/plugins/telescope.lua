local M = {};

M.init = function()
    return {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-dap.nvim', config = function() require('telescope').load_extension('dap') end },
        }
    }
end


M.setup = function()
    local telescope = require('telescope');

    telescope.setup({
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    });
    telescope.load_extension('dap');

    vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = "Telescope: Find Files" });
    vim.keymap.set('n', '<leader>fs', '<cmd>Telescope live_grep<CR>', { desc = "Telescope: Live Grep" });
    vim.keymap.set('n', '<leader>fc', '<cmd>Telescope grep_string<CR>', { desc = "Telescope: Grep String" });
end


return M;

