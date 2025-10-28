local M = {};

M.setup = function()
    vim.lsp.enable('phpactor')
    vim.lsp.config('phpactor', {
        tiletypes = { 'php', 'blade', 'cigg' }
    });


    vim.lsp.enable('twiggy_language_server');
    vim.lsp.enable('psalm')
end

return M;
