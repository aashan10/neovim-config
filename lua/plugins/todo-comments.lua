
local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        'folke/todo-comments.nvim'
    }
end

-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()
    require('todo-comments').setup()
end

return M;

