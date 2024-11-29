local M = {};

M.init = function()
    return {
        'lewis6991/gitsigns.nvim',
        event = "BufEnter"
    }
end


M.setup = function()
    require('gitsigns').setup({
        current_line_blame = true,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol',
            delay = 10,
            ignore_whitespace = false,
            virt_text_priority = 100
        },
        current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>'
    })
end

return M;
