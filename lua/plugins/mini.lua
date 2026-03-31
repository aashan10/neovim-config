local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        { src = 'https://github.com/echasnovski/mini.starter' },
        { src = 'https://github.com/echasnovski/mini.move' },
        { src = 'https://github.com/echasnovski/mini.indentscope' },
        { src = 'https://github.com/echasnovski/mini.surround' },
        { src = 'https://github.com/echasnovski/mini.align' },
        { src = 'https://github.com/echasnovski/mini.comment' },
        { src = 'https://github.com/echasnovski/mini.cursorword' },
        { src = 'https://github.com/echasnovski/mini.splitjoin' },
    }
end


-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()
    require('plugins.mini.starter').setup();
    require('plugins.mini.move').setup();
    require('plugins.mini.indentscope').setup();
    require('plugins.mini.surround').setup();
    require('plugins.mini.align').setup();
    require('plugins.mini.comment').setup();
    require('plugins.mini.cursorword').setup();
    require('plugins.mini.splitjoin').setup();
    -- require('plugins.mini.files').setup();
end

return M;
