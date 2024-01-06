local M = {};

M.init = function()
    return {
        'stevearc/dressing.nvim'
    }
end

M.setup = function()
    require('dressing').setup()
end

return M;


