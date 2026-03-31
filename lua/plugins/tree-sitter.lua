local M = {};

M.init = function()
    return { src = 'https://github.com/nvim-treesitter/nvim-treesitter' }
end

M.setup = function()
    require 'nvim-treesitter.config'.setup {
        ensure_installed = {
        },
        auto_install = true,
        highlight = {
            enable = true,
        },
        indent = {
            enable = true
        }
    }

    require "nvim-treesitter.parsers".blade = {
        install_info = {
            url = "https://github.com/EmranMR/tree-sitter-blade",
            files = { "src/parser.c" },
            branch = "main"
        },
        filetype = "blade"

    };
end

return M;
