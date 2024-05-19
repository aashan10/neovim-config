local M = {};


M.init = function()
    return { 'norcalli/nvim-colorizer.lua' }
end

M.setup = function()
    require('colorizer').setup()
end

return M;
