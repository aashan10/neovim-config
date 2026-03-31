local M = {};


M.init = function()
    return { src = 'https://github.com/catgoose/nvim-colorizer.lua' }
end

M.setup = function()
    require('colorizer').setup()
end

return M;
