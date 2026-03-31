local M = {};



M.init = function()
    return { src = 'https://github.com/hedyhli/outline.nvim' }
end

M.setup = function()
    require('outline').setup({
    });
    vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Outline -- see :h :Outline" });
end

return M;
