local M = {};

M.setup = function()
    require('mini.move').setup({
        mappings = {
            left  = "<C-S-Left>",
            right = "<C-S-Right>",
            up    = "<C-S-Up>",
            down  = "<C-S-Down>",
        }
    });
end

return M;
