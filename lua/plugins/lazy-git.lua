local M = {};

M.init = function()
    return {
        { src = 'https://github.com/kdheepak/lazygit.nvim' },
        { src = 'https://github.com/nvim-lua/plenary.nvim' },
    }
end

M.setup = function()
    require('telescope').load_extension('lazygit')
    vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'Lazygit: Open UI' })
end

return M;
