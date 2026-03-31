local M = {
    name = 'live_grep_args',
    enabled = false
};

M.dependencies = function()
    return {
        { src = 'https://github.com/nvim-telescope/telescope-live-grep-args.nvim' },
    }
end

M.config = function()
    return {
    }
end

M.setup = function()
end


return M;
