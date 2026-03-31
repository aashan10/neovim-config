local M = {};

M.init = function()
    return { src = 'https://github.com/folke/which-key.nvim' }
end

M.setup = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    require('which-key').setup {}
end
return M;
