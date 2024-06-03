local M = {};

M.init = function()
    return  { 'projekt0n/github-nvim-theme' };
end

M.setup = function()
    require('github-theme').setup {}

    vim.cmd('colorscheme github_dark_dimmed');
end
 
return M;
