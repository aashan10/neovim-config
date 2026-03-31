local M = {};

M.setup = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities();

    capabilities.textDocument.prepareTypeHierarchy = {
        dynamicRegistration = true
    };
    capabilities.textDocument.typeHierarchy = {
        dynamicRegistration = true
    };

    vim.lsp.config('phpantom', {
        cmd = { '~/.local/bin/phpantom_lsp' },
        filetypes = { 'php' },
        capabilities = capabilities,
    });
    vim.lsp.enable('phpantom');

    vim.lsp.config('twiggy_language_server', {
        filetypes = { 'twig.html', 'html.twig', 'twig' },
    });

    vim.lsp.enable('twiggy_language_server');
end

return M;
