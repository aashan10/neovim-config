
local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return { src = 'https://github.com/altermo/ultimate-autopair.nvim', version = 'v0.6' }
end


-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()
    require('ultimate-autopair').setup {}
end

return M;

