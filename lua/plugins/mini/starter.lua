local M = {};

M.setup = function()
    require('mini.starter').setup({
        autoopen = true,
        header   = "neovim, truely yours",
        items    = {},
        footer   = ""
    });
end

return M;
