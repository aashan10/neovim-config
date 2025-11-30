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
    require('lualine').setup({
        options = {
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
