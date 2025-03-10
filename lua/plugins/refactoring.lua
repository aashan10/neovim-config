local M = {};

M.init = function()
    return {
        'ThePrimeagen/refactoring.nvim',
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        }
    }
end


M.setup = function()
    require("refactoring").setup()
end

return M;
