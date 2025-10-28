local M = {};

M.setup = function()
    vim.lsp.enable('rust_analyzer');
end

return M;
