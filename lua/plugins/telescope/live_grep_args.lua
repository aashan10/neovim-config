local M = {
    name = 'live_grep_args',
    enabled = false
};

M.dependencies = function()
    return {
        'nvim-telescope/telescope_live_grep_args.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release',
    }
end

M.config = function()
    return {
    }
end

M.setup = function()
end


return M;
