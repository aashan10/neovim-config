local M = {};

M.init = function()
    return { 'projekt0n/github-nvim-theme' };
end

M.setup = function()
    require('github-theme').setup({
        options = {
            transparent = true,
        }
    })

    vim.cmd('colorscheme github_dark_default');
end

return M;
