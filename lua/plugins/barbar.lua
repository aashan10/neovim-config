
local M = {};

M.init = function()
    return {
        'romgrk/barbar.nvim'
    }
end

M.setup = function()
    require('barbar').setup({
        sidebar_filetypes = {
            NvimTree = true,
        }
    });

    local set = vim.keymap.set;

    set('n', '[b', '<cmd>BufferPrevious<CR>', { desc = 'Previous buffer' });
    set('n', ']b', '<cmd>BufferNext<CR>', { desc = 'Next buffer' });
    set('n', 'bd', '<cmd>BufferClose<CR>', { desc = 'Close buffer' });
    set('n', '<leader>bp', '<cmd>BufferPick<CR>', { desc = 'Pick buffer' });

end

return M;

