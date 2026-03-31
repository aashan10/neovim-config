local M = {};

M.setup = function()
    require('mini.starter').setup({
        autoopen = true,
        items = {},
    });
end

return M;
