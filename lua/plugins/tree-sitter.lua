local M = {};

M.init = function()
    return { src = 'https://github.com/nvim-treesitter/nvim-treesitter' }
end

M.setup = function()
    require 'nvim-treesitter.configs'.setup {
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

    local parser_config = require "nvim-treesitter.parsers".get_parser_configs();
    parser_config.blade = {
        install_info = {
            url = "https://github.com/EmranMR/tree-sitter-blade",
            files = { "src/parser.c" },
            branch = "main"
        },
        filetype = "blade"
    }
end

return M;
