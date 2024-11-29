local M = {};



M.init = function()
    return {
        'hedyhli/outline.nvim',
        event = "BufEnter"
    }
end

M.setup = function()
    require('outline').setup({
    });
    vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Outline -- see :h :Outline" });
end

return M;
