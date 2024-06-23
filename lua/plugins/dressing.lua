local M = {};

M.init = function()
    return {
        'stevearc/dressing.nvim'
    }
end

M.setup = function()
    require('dressing').setup({
        input = {
            enabled = true,
        },
        select = {
            enabled = true,
        }
    });
end

return M;
