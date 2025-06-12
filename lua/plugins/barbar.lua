local M = {};

M.init = function()
    return {
        'romgrk/barbar.nvim'
    }
end

M.setup = function()
    require('barbar').setup({});

    local set = vim.keymap.set;

    set('n', '[b', '<cmd>BufferPrevious<CR>', { desc = 'Previous buffer' });
    set('n', ']b', '<cmd>BufferNext<CR>', { desc = 'Next buffer' });
    set('n', 'bd', '<cmd>BufferClose<CR>', { desc = 'Close buffer' });
    set('n', '<leader>bp', '<cmd>BufferPick<CR>', { desc = 'Pick buffer' });

    -- set highlight groups

    local barbar_groups = {
        'TabLineFill',
        'BufferDefaultTabpages',
        'BufferTabpageFill',
        'BufferDefaultTabpagesSep',
    }

    for _, group in ipairs(barbar_groups) do
        vim.api.nvim_set_hl(0, group, { bg = 'NONE', ctermbg = 'NONE' });
    end

    vim.api.nvim_set_hl(0, 'BufferDefaultCurrent', { bg = '#ffffff', fg = '#000000', blend = 90 });
end

return M;
