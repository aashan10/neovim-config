local M = {
    name = 'media_files',
    enabled = true
};

M.dependencies = function()
    return {
        'nvim-telescope/telescope-media-files.nvim',
        dependencies = { "nvim-telescope/telescope.nvim" }
    }
end

M.config = function()
    return {
        filetypes = { "png", "jpg", "jpeg", "webp", "svg" },
        find_cmd = "rg"
    }
end

M.setup = function()
end


return M;
