
local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        'github/copilot.vim'
    }
end


-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()

end

return M;

