
local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        'altermo/ultimate-autopair.nvim',
        event={'InsertEnter','CmdlineEnter'},
        branch='v0.6',
    }
end


-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()
    require('ultimate-autopair').setup {}
end

return M;

