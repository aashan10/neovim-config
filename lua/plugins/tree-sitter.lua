local M = {};

M.init = function()
    return {
        "nvim-treesitter/nvim-treesitter"
    }
end

M.setup = function()
    require 'nvim-treesitter.configs'.setup {
        ensure_installed = {
            "lua", "html", "php", "rust", "typescript"
        },
        auto_install = true,
        highlight = {
            enable = true,
        }
    }
end

return M;

