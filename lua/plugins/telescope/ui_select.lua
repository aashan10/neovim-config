local M = {
    name = 'ui-select',
    enabled = true
};

M.dependencies = function()
    return {
        'nvim-telescope/telescope-ui-select.nvim',
        dependencies = { "nvim-telescope/telescope.nvim" }
    }
end

M.config = function()

end

M.setup = function()
end


return M;
