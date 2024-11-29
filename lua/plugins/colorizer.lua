local M = {};


M.init = function()
    return {
        'norcalli/nvim-colorizer.lua',
        event = "BufEnter"
    }
end

M.setup = function()
    require('colorizer').setup()
end

return M;
