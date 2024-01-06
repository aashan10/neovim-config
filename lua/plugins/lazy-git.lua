local M = {};

M.init = function()
   return {
        'kdheepak/lazygit.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim'
        }
   }
end

M.setup = function()
    require('telescope').load_extension('lazygit')
    vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<CR>', { desc = 'Open LazyGIT UI' })
end

return M;
