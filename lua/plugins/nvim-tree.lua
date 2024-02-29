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
    require("nvim-tree").setup();

    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>");
    vim.keymap.set("n", "<leader>.", "<cmd>NvimTreeFocus<CR>");
end

return M;

