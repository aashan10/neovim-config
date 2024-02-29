local M = {};

M.init = function()
    return {
        'akinsho/bufferline.nvim'
    }
end

M.setup = function()
    require('bufferline').setup({
        options = {
            indicator = {
                style = 'underline'
            }
        },
    })

    vim.keymap.set('n', ']b', '<cmd>bnext<CR>', { desc = "Next Buffer -- see :h :bn" });
    vim.keymap.set('n', '[b', '<cmd>bprev<CR>', { desc = "Previous Buffer -- see :h :bp" });
end

return M;
