local M = {};

M.name = 'Tokyo Night';
M.colorscheme = '';

M.setup = function()
    require('tokyonight').setup({
        styles = {
            comments = { italic = true }
        }
    })
end

-- this is a comment

M.on_load = function()
    return [[colorscheme tokyonight]]
end

M.init = function()
    return {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    }
end

return M;
