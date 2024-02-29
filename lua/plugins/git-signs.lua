local M = {};

M.init = function()
    return {
        'lewis6991/gitsigns.nvim'
    }
end


M.setup = function()
    require('gitsigns').setup()
end

return M;

