local M = {};

M.init = function()
    return {
        { src = 'https://github.com/ThePrimeagen/refactoring.nvim' },
        { src = 'https://github.com/nvim-lua/plenary.nvim' },
        { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    }
end


M.setup = function()
    require("refactoring").setup()
end

return M;
