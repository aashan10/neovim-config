local M = {};

M.name = 'Catppuccin';
M.colorscheme = 'catppuccin-mocha';

M.setup = function()
    -- require('darcula').setup()
end

M.on_load = function()
    return [[colorscheme catppuccin-mocha]]
end

M.init = function()
    return {
        'catppuccin/nvim'
    }
end

return M;
