local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        'echasnovski/mini.nvim'
    }
end


-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
-- TODO: Something to be done here 
M.setup = function()
    require('mini.starter').setup();
    require('mini.indentscope').setup();
end

return M;
