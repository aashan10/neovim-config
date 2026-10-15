local M = {};

M.init = function()
    return {
        { src = 'https://github.com/calvinludwig/mago.nvim' },
    }
end

M.setup = function()
    require('mago-nvim').setup({
        logging = {
            notify = true,
            write_to_log = true,
            min_level = 'INFO',
            log_file = nil,
        }
    })
end

return M;
