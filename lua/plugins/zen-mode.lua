
local M = {};

M.init = function()
    return {
        'folke/zen-mode.nvim'
    }
end

M.setup = function()

    vim.keymap.set('n', '<leader>zz', function() 
        require('zen-mode').toggle({
            window = {
                width = .70
            }
        })
    end, { desc = "Toggle Zen Mode" })
end

return M;
