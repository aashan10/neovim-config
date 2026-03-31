local M = {
    name = 'file_browser',
    enabled = true
};

M.dependencies = function()
    return {
        { src = 'https://github.com/nvim-telescope/telescope-frecency.nvim' },
    }
end

M.config = function()

end

M.setup = function()
    vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>Telescope frecency<CR>', { noremap = true, silent = true });
end


return M;
