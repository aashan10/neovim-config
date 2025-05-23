local M = {};

local plugins = {
    'plugins.telescope.dap',
    'plugins.telescope.fzf',
    'plugins.telescope.live_grep_args',
    'plugins.telescope.file_browser',
    'plugins.telescope.frecency',
    'plugins.telescope.ui_select',
    'plugins.telescope.media',
};

M.init = function()
    local dependencies = {
        'nvim-telescope/telescope.nvim',
    };

    for _, plugin in ipairs(plugins) do
        local plugin_module = require(plugin);
        if plugin_module.enabled then
            local plugin_dependencies = plugin_module.dependencies();
            for _, dependency in ipairs(plugin_dependencies) do
                table.insert(dependencies, dependency);
            end
        end
    end

    return dependencies;
end


M.setup = function()
    local telescope = require('telescope');
    local actions = require("telescope.actions");
    local action_state = require("telescope.actions.state");

    local plugin_configs = {};
    local plugin_names = {};

    for _, plugin in ipairs(plugins) do
        local plugin_module = require(plugin);
        if plugin_module.enabled then
            plugin_configs[plugin_module.name] = plugin_module.config();
            table.insert(plugin_names, plugin_module.name);
        end
    end


    local function copy_file_path(bufnr, relative)
        local entry = action_state.get_selected_entry()
        if entry then
            local path = entry.path or entry.filename
            if path then
                local final_path = relative and vim.fn.fnamemodify(path, ":.") or vim.fn.fnamemodify(path, ":p")
                vim.fn.setreg("+", final_path) -- Copy to system clipboard
                print("Copied (" .. (relative and "relative" or "absolute") .. "): " .. final_path)
            end
        end
        actions.close(bufnr)
    end

    telescope.setup({
        extensions = plugin_configs,
        defaults = {
            mappings = {
                i = {
                    ["<C-y>"] = function(bufnr) copy_file_path(bufnr, true) end,
                    ["<C-S-y>"] = function(bufnr) copy_file_path(bufnr, false) end,
                },
                n = {
                    ["<C-y>"] = function(bufnr) copy_file_path(bufnr, true) end,
                    ["<C-S-y>"] = function(bufnr) copy_file_path(bufnr, false) end,
                }
            }
        }
    });

    for _, plugin_name in ipairs(plugin_names) do
        telescope.load_extension(plugin_name);
    end

    vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = "Telescope: Find Files" });
    vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
    vim.keymap.set('n', '<leader>fs', '<cmd>Telescope live_grep<CR>', { desc = "Telescope: Live Grep" });
    vim.keymap.set('n', '<leader>fc', '<cmd>Telescope grep_string<CR>', { desc = "Telescope: Grep String" });
    vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = "Telescope: Buffers" });

    for _, plugin in ipairs(plugins) do
        local plugin_module = require(plugin);
        if plugin_module.enabled then
            plugin_module.setup();
        end
    end
end


return M;
