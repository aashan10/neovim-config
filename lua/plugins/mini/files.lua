local M = {};

M.toggle = function()
    local MiniFiles = require('mini.files');

    if MiniFiles.open() then
        MiniFiles.close();
    else
        MiniFiles.open();
    end
end

M.setup = function()
    require('mini.files').setup({

        mappings = {
            close = '<Esc>',
            go_in = "<CR>",
            go_out = "<Left>",
            reset = "<BS>"
        },
        options = {
            use_as_default_explorer = true
        },
        windows = {
            preview = true
        }
    });


    -- vim.api.nvim_set_keymap('n', '<Leader>e', '<cmd>lua require("plugins.mini.files").toggle()<CR>',
    --     { noremap = true, silent = true });
end

return M;
