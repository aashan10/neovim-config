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
M.setup = function()
    require('mini.starter').setup({
        autoopen = true,
        header   = "neovim, truely yours",
        items    = {},
        footer   = ""
    });
    require('mini.move').setup({
        mappings = {
            left  = "<C-S-Left>",
            right = "<C-S-Right>",
            up    = "<C-S-Up>",
            down  = "<C-S-Down>",
        }
    });
    require('mini.indentscope').setup();
    require('mini.surround').setup();
    require('mini.align').setup();
    require('mini.comment').setup();
    require('mini.cursorword').setup();
    require('mini.splitjoin').setup();
end

return M;
