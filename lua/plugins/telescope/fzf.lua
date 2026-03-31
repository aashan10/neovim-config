local M = {
    name = 'fzf',
    enabled = true
};

M.dependencies = function()
    return {
        { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
        { src = 'https://github.com/nvim-telescope/telescope-fzf.nvim' },
    }
end

M.setup_build = function()
    vim.api.nvim_create_autocmd('PackChanged', {
        callback = function(ev)
            local name = ev.data.spec.name
            local kind = ev.data.kind
            if name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
                vim.system(
                    { 'cmake', '-S.', '-Bbuild', '-DCMAKE_BUILD_TYPE=Release' },
                    { cwd = ev.data.path }
                ):wait()
                vim.system(
                    { 'cmake', '--build', 'build', '--config', 'Release' },
                    { cwd = ev.data.path }
                ):wait()
            end
        end
    })
end

M.config = function()
    return {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
    }
end

M.setup = function()
    vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true });
end


return M;
