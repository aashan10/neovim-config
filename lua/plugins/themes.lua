local M = {};


local active_colorscheme = 'habamax-custom'; -- this theme is inside ROOT/colors/habamax-custom.vim


M.init = function()
    return nil;
end

M.setup = function()
    vim.cmd('colorscheme ' .. active_colorscheme);

    -- PHP Specific Highlighting --


    -- Intellij Default Theme Colorscheme
    -- vim.api.nvim_set_hl(0, '@keyword', { fg = '#CA7832' });
    -- vim.api.nvim_set_hl(0, 'Type', { fg = '#A9B7C5' });
    -- vim.api.nvim_set_hl(0, '@module', { fg = '#A9B7C5' });

    -- vim.api.nvim_set_hl(0, '@type.qualifier.php', { fg = '#CA7832' });
    -- vim.api.nvim_set_hl(0, '@function.method.php', { fg = '#FFC66D' });
    -- vim.api.nvim_set_hl(0, '@function.method.call.php', { fg = '#FFC66D' });
    -- vim.api.nvim_set_hl(0, '@punctuation.bracket.php', { fg = '#CA7832' });
    -- vim.api.nvim_set_hl(0, '@variable.php', { fg = '#9876AA' });
    -- vim.api.nvim_set_hl(0, '@variable.parameter.phpdoc', { fg = '#9876AA' });
    -- vim.api.nvim_set_hl(0, '@keyword.phpdoc', { fg = '#9876AA' });
    -- vim.api.nvim_set_hl(0, '@operator.php', { fg = '#A9B7C5' });
    -- vim.api.nvim_set_hl(0, '@constructor.php', { fg = '#A9B7C5' });
    -- vim.api.nvim_set_hl(0, '@number.php', { fg = '#6897BB' });
    -- vim.api.nvim_set_hl(0, '@spell.phpdoc', { fg = '#629755' });
    -- vim.api.nvim_set_hl(0, '@string.php', { fg = '#6A8759' });
    -- vim.api.nvim_set_hl(0, '@attribute.phpdoc', { fg = '#629755', bold = true, italic = true, underline = true });
    -- vim.api.nvim_set_hl(0, '@comment.php', { fg = '#808080' });
    -- vim.api.nvim_set_hl(0, "@punctuation.bracket.php", { fg = "#A9B7C5" });
end



return M;
