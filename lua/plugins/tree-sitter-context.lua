local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
    }
end


-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()
    require('treesitter-context').setup({
        enable = true,
        multiwindow = true,
        max_lines = 0,
        max_window_height = 0,
        line_numbers = true,
        multiline_threshold = 10,
        trim_scope = 'outer',
        mode = 'cursor',
        zindex = 20,
        on_attach = nil,
    })

    vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true })
end

return M;
