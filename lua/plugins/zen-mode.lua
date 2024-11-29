local M = {};

M.init = function()
    return {
        'folke/zen-mode.nvim',
        event = "VeryLazy"
    }
end

M.setup = function()
    vim.keymap.set('n', '<leader>zz', function()
        require('zen-mode').toggle({
            window = {
                width = 0.6,
                backdrop = 1,
            },
            plugins = {
                tmux = {
                    enabled = true
                }
            }
        })
    end, { desc = "Toggle Zen Mode" })
end

return M;
