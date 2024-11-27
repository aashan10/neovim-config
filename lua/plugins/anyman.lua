local M = {};

M.init = function()

end


M.setup = function()
    vim.keymap.set('n', '<Leader>am', function() M.anyman() end, { desc = 'Anyman Toolkit' });
end

M.is_any_project = function()
    local path = vim.fn.getcwd();
    local f = io.open(path .. "/../../any", "r");
    if f ~= nil then
        io.close(f);
        return true;
    end
    return false;
end

M.get_anyman_path = function()
    return vim.fn.getcwd() .. "/../../";
end

M.anyman = function()
    if not M.is_any_project() then
        print("Not an Anyman project");
        return;
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local execute = require('plugins.tmux').run_command;
    local path = vim.fn.getcwd();

    local result = execute("cd " .. path .. "/../../ && any commands");



    pickers.new({}, {
        prompt_title = "Anyman Toolkit",
        finder = finders.new_table {
            results = result,
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
            local select_anyman = function()
                local selection = require("telescope.actions.state").get_selected_entry()
                local line = selection.value;
                local command = line:match("^(.-) --");

                if command == nil then
                    print("No command found");
                    return;
                end
                if command:find("%[args]") then
                    local args = vim.fn.input("Arguments: ");
                    command = command:gsub("%[args]", args);
                end

                vim.cmd("!tmux split-window -h -c " .. path .. "/../../ -p 50 'any " .. command .. " && read'");
                -- require("telescope.actions").close(prompt_bufnr)
            end

            map('i', '<CR>', select_anyman)
            map('n', '<CR>', select_anyman)

            return true
        end
    }):find()
end

return M;
