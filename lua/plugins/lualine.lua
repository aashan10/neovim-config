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
    local colors = {
        text = '#cccccc',
        darkGray = '#393939',
        lightGray = '#4d4d4d',
    }

    local highlighted = {
        bg = colors.darkGray,
        fg = colors.text,
        gui = 'bold'
    }

    local normal = {
        bg = colors.darkGray,
        fg = colors.text,
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
        inactive = group 
    };

    require('lualine').setup({
        options = {
            theme = theme,
            section_separators = { left = ' ', right = ' ' },
            component_separators = { left = ' ', right = ' ' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { 'searchcount', 'selectioncount' },
            lualine_x = { 'encoding', 'filetype' },
            lualine_y = { 'location' },
            lualine_z = { 'progress' },
        },
        extensions = { 'nvim-tree' }
    })
end

return M;
