local M = {
    name = 'media_files',
    enabled = true
};

M.dependencies = function()
    return {
        { src = 'https://github.com/nvim-telescope/telescope-media-files.nvim' },
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
