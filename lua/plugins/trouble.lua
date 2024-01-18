local M = {};

M.init = function()
    return {
        'folke/trouble.nvim',
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        }
    }
end


M.setup = function()
    require('trouble').setup {}
end
return M;
