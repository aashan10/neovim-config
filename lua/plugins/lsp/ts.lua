local M = {};

M.setup = function()
    vim.filetype.add({
        extension = {
            js = "javascript",
            ts = "typescript",
        }
    })

    vim.lsp.enable('tsgo');
end

return M;
