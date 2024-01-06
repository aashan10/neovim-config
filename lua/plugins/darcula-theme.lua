local M = {};

M.init = function()
    return {
        "santos-gabriel-dario/darcula-solid.nvim",
        dependencies = {
            "rktjmp/lush.nvim"
        }
    }
end

M.setup = function()
    vim.cmd[[colorscheme darcula-solid]]
end

return M;
