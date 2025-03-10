local M = {
    name = 'dap',
    enabled = true
};

M.dependencies = function()
    return {
        'nvim-telescope/telescope-dap.nvim',
        dependencies = {

        }
    }
end

M.config = function()
    return {};
end

M.setup = function()

end


return M;
