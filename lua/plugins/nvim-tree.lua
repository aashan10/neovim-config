local M = {};

M.init = function()
    return {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        }
    }
end

M.setup = function()
    require("nvim-tree").setup({
        filters = {
            dotfiles = false,
        },
        view = {
            centralize_selection = true,
            width = 50,
        },
        update_focused_file = {
            enable = true
        }
    });

    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "NvimTree: Toggle" });
    vim.keymap.set("n", "<leader>.", "<cmd>NvimTreeFocus<CR>", { desc = "NvimTree: Focus" });
    vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFile<CR>", { desc = "NvimTree: Find File" });

    local api = require('nvim-tree.api');

    api.events.subscribe(api.events.Event.FileCreated, function(file)
        vim.cmd("edit " .. file.fname)
    end)
end

return M;
