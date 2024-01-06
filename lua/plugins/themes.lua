local M = {};

local themes = {
    'onedark',
    'darcula',
    'tokyonight',
};

local active_colorscheme = 'tokyonight'; -- 'darcula', 'onedark'

function require_theme(name)
    return require('plugins.themes.' .. name);
end


M.init = function ()

    local dependencies = {};

    for _, name in pairs(themes) do
        local theme = require_theme(name);
        table.insert(dependencies, theme.init());
    end

    return {
        'zaldih/themery.nvim',
        dependencies = dependencies
    }

end

M.setup = function()

    for _, name in pairs(themes) do
        local theme = require_theme(name);
        theme.setup();
    end

    vim.cmd('colorscheme ' .. active_colorscheme);

end



return M;
