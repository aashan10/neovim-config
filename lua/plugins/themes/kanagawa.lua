local M = {
    name = 'kangawa',
    enabled = true
};

M.dependencies = function()
    return {
        'rebelot/kanagawa.nvim',
    }
end

M.setup = function()
    require('kanagawa').setup({
        compile = true,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = { italic = true },
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = { italic = true },
        variablebuiltinStyle = { italic = true },
        specialReturn = true,
        specialException = true,
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        colors = {
            theme = {
                all = {
                    ui = {
                        bg_gutter = "none",
                    },
                },
            },
        },
        overrides = function(colors)
            local theme = colors.theme
            return {
                CursorLineNr = { fg = theme.ui.special1, bg = "none", bold = true },
                LineNr = { fg = theme.ui.fg_dim, bg = "none" },
            }
        end,
    })
end


return M;
