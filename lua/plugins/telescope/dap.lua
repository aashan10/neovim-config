local M = {
    name = 'dap',
    enabled = true
};

M.dependencies = function()
    return {
        { src = 'https://github.com/nvim-telescope/telescope-dap.nvim' },
    }
end

M.config = function()
    return {};
end

M.setup = function()

end


return M;
