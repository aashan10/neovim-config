local M = {};


M.init = function()
    return { src = 'https://github.com/norcalli/nvim-colorizer.lua' }
end

M.setup = function()
    require('colorizer').setup()
end

return M;
