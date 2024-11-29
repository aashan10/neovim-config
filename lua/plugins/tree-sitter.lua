local M = {};

M.init = function()
    return {
        "nvim-treesitter/nvim-treesitter",
        event = "BufEnter"
    }
end

M.setup = function()
    require 'nvim-treesitter.configs'.setup {
        ensure_installed = {
            "lua", "html", "phpdoc", "rust", "typescript", "twig"
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
