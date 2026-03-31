local M = {};

M.setup = function()
    vim.lsp.config('phpantom', {
        cmd = { 'phpantom_lsp' },
        filetypes = { 'php' },
        root_markers = { 'composer.json', '.phpantom.toml' }
    });
    vim.lsp.enable('phpantom');

    vim.lsp.config('twiggy_language_server', {
        filetypes = { 'twig.html', 'html.twig', 'twig' },
    });

    vim.lsp.enable('twiggy_language_server');
end

return M;
