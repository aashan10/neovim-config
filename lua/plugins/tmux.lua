local M = {};

M.init = function()

end

M.run_command = function (command)
    local handle = io.popen(command);
    if handle == nil then
        return {};
    end
    local result = handle:read("*a")
    handle:close()

    local lines = {};

    for s in result:gmatch("[^\r\n]+") do
        table.insert(lines, s);
    end

    return lines;
end



M.setup = function()
    vim.keymap.set('n', '<Leader>tm', function () M.tmux_windows() end, { desc = 'Show Active Projects' });
    vim.keymap.set('n', '<Leader>op', function () M.open_project() end, { desc = 'Open Project' });
end

M.tmux_windows = function()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values

    local tmux_windows = M.run_command("tmux list-windows -F '#{window_index} #{window_name}'");

    pickers.new({}, {
        prompt_title = "Active Projects",
        finder = finders.new_table {
            results = tmux_windows,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry,
                }
            end
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            local select_window = function()
                local selection = require("telescope.actions.state").get_selected_entry()
                local window_index = selection.value:match("^(%d+)");
                vim.cmd("silent !tmux select-window -t " .. window_index);
                require("telescope.actions").close(prompt_bufnr)
            end

            local close_window = function()
                local selection = require("telescope.actions.state").get_selected_entry()
                local window_index = selection.value:match("^(%d+)");
                vim.cmd("silent !tmux kill-window -t " .. window_index);
                require("telescope.actions").close(prompt_bufnr)
            end

            map("i", "<CR>", select_window)
            map("i", "c", close_window)
            map("n", "c", close_window)
            map("n", "<CR>", select_window)

            return true
        end
    }):find();
end

M.open_project = function ()
    -- get project name from user
    local project_name = vim.fn.input("Project Name: ");
    if project_name == nil or project_name == "" then
        return;
    end

    -- project path = ~/<project_name>
    local project_path = "~/" .. project_name;
    -- open tmux window in the project path
    vim.cmd("silent !tmux new-window -t MAIN: -n " .. project_name);
    vim.cmd("silent !tmux select-window -t MAIN:" .. project_name);
    vim.cmd("silent !tmux select-pane -t 0");
    vim.cmd("silent !tmux send-keys 'cd " .. project_path .. " && clear' Enter");
    vim.cmd("silent !tmux split-window -v");
    vim.cmd("silent !tmux select-pane -t 1");
    vim.cmd("silent !tmux send-keys 'cd " .. project_path .. " && clear' Enter");
    vim.cmd("silent !tmux split-window -h");
    vim.cmd("silent !tmux select-pane -t 2");
    vim.cmd("silent !tmux send-keys 'cd " .. project_path .. " && clear' Enter");
    vim.cmd("silent !tmux select-pane -t 0");
    vim.cmd("silent !tmux resize-pane -D 10");


end

return M;
