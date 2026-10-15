local M = {};

M.setup = function()
    vim.lsp.config['vue_ls'] = {
        cmd = { 'vue-language-server', '--stdio' },
        filetypes = { 'vue' },
        root_markers = { 'package.json', 'tsconfig.json' },
    };

    vim.lsp.enable('vue_ls');
end

return M;
