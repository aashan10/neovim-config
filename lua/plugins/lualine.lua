local M = {};

M.init = function()
    return {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        }
    };
end


M.setup = function()
    local colors = require('user.theme').colors;

    local highlighted = {
        bg = colors.comments,
        fg = colors.bg,
        gui = 'bold'
    }

    local normal = {
        bg = colors.gray,
        fg = colors.fg,
    }

    local group = {
        a = highlighted,
        b = normal,
        c = normal,
        x = normal,
        y = normal,
        z = normal,
    }

    local theme = {
        normal = group,
        insert = group,
        visual = group,
        replace = group,
        command = group,
        inactive = group,
    };

    require('lualine').setup({
        options = {
            theme = theme,
            section_separators = { left = ' ', right = ' ' },
            component_separators = { left = ' ', right = ' ' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diagnostics' },
            lualine_c = {
                {
                    'filename',
                    path = 1
                },
                'searchcount',
                'selectioncount'
            },
            lualine_x = { 'encoding' },
            lualine_y = { 'location' },
            lualine_z = { 'progress' },
        },
        extensions = { 'nvim-tree' }
    })
end

return M;
