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
    local theme = {
        normal = {
            a = { bg = '#393939', fg = '#cccccc', gui = 'bold' },
            b = { bg = '', fg = '' },
            c = { bg = '', fg = '' },
            x = { bg = '', fg = '' },
            y = { bg = '', fg = '' },
            z = { bg = '', fg = '' },
        },
        insert = {
            a = { bg = '#393939', fg = '#cccccc', gui = 'bold' },
            b = { bg = '', fg = '' },
            c = { bg = '', fg = '' },
            x = { bg = '', fg = '' },
            y = { bg = '', fg = '' },
            z = { bg = '', fg = '' },
        },
        visual = {
            a = { bg = '#393939', fg = '#cccccc', gui = 'bold' },
            b = { bg = '', fg = '' },
            c = { bg = '', fg = '' },
            x = { bg = '', fg = '' },
            y = { bg = '', fg = '' },
            z = { bg = '', fg = '' },
        },
        replace = {
            a = { bg = '#393939', fg = '#cccccc', gui = 'bold' },
            b = { bg = '', fg = '' },
            c = { bg = '', fg = '' },
            x = { bg = '', fg = '' },
            y = { bg = '', fg = '' },
            z = { bg = '', fg = '' },
        },
        command = {
            a = { bg = '#393939', fg = '#cccccc', gui = 'bold' },
            b = { bg = '', fg = '' },
            c = { bg = '', fg = '' },
            x = { bg = '', fg = '' },
            y = { bg = '', fg = '' },
            z = { bg = '', fg = '' },
        },
        inactive = {
            a = { bg = '#393939', fg = '#cccccc', gui = 'bold' },
            b = { bg = '', fg = '' },
            c = { bg = '', fg = '' },
            x = { bg = '', fg = '' },
            y = { bg = '', fg = '' },
            z = { bg = '', fg = '' },
        }
    };


    require('lualine').setup({
        options = {
            theme = theme,
            section_separators = { left = ' ', right = ' ' },
            component_separators = { left = ' ', right = ' ' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch' },
            lualine_c = { 'searchcount', 'selectioncount' },
            lualine_x = { 'encoding', 'filetype' },
            lualine_y = { 'location' },
            lualine_z = { 'progress' },
        }
    })
end

return M;
