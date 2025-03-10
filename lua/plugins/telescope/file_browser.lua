local M = {
    name = 'file_browser',
    enabled = true
};

M.dependencies = function()
    return {
        'nvim-telescope/telescope-file-browser.nvim',
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    }
end

M.config = function()
    local telescope = require('telescope');
    local fb_actions = telescope.extensions.file_browser.actions;
    return {
        hijack_netrw = true,
        grouped = true,
        respect_gitignore = false,
        mappings = {
            ['n'] = {
                --  map delete to 'Del' key
                ['<leader>d'] = fb_actions.remove

            }
        }
    }
end

M.setup = function()
    vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>Telescope file_browser<CR>', { noremap = true, silent = true });
    vim.api.nvim_set_keymap('n', '<leader>E', '<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>',
        { noremap = true, silent = true });
end


return M;
