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
            left  = "<C-h>",
            right = "<C-l>",
            up    = "<C-k>",
            down  = "<C-j>",
        }
    });
    require('mini.indentscope').setup();
    require('mini.surround').setup();
    require('mini.align').setup();
    require('mini.comment').setup();
end

return M;
