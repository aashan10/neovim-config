local M = {};

M.init = function()
    return {
        { src = 'https://github.com/nvim-lualine/lualine.nvim' },
        { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    }
end


M.setup = function()
    require('lualine').setup({
        options = {
            section_separators = { left = ' ', right = ' ' },
            component_separators = { left = ' ', right = ' ' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diagnostics' },
            lualine_c = {
                {
                    'filename',
                    path = 1
                },
                'searchcount',
                'selectioncount'
            },
            lualine_x = {
                {
                    function()
                        local tracker = require('utils.timetracker')
                        local open = tracker.list('open')
                        if #open == 0 then return '' end
                        local task = open[1]
                        local entry
                        for _, e in ipairs(task.entries) do
                            if e.status == 'open' then entry = e break end
                        end
                        if not entry then return '' end
                        local mins = math.floor((os.time() - entry.start_time) / 60)
                        return task.ticket_id .. ' ' .. mins .. 'm'
                    end,
                    cond = function()
                        local ok, tracker = pcall(require, 'utils.timetracker')
                        if not ok then return false end
                        return #tracker.list('open') > 0
                    end,
                    color = { fg = '#f7768e' },
                },
                'encoding',
            },
            lualine_y = { 'location' },
            lualine_z = { 'progress' },
        },
        extensions = { 'nvim-tree' }
    })
end

return M;
