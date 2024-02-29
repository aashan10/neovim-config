local M = {};

M.init = function()
    return {
        'f-person/git-blame.nvim'
    }
end


M.setup = function()
    require('gitblame').setup()
end

return M;

