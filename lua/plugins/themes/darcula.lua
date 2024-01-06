local M = {};

M.name = 'Jetbrains Darcula';
M.colorscheme = 'darcula';

M.setup = function()
    -- require('darcula').setup()
end

M.on_load = function()
    return [[colorscheme darcula-solid]]
end

M.init = function()
    return {
        'doums/darcula'
    }
end

return M;
