local M = {};

-- Register Your Plugins Here
local plugins = {
    'plugins.mini',
    'plugins.nvim-tree',
    'plugins.tree-sitter',
    'plugins.telescope',
    'plugins.git-signs',
    'plugins.lazy-git',
    'plugins.zen-mode',
    'plugins.themes',
    'plugins.nvim-cmp',
    'plugins.lsp',
    'plugins.harpoon',
    'plugins.whichkey',
    'plugins.dap',
    'plugins.ultimate-autopairs',
    'plugins.dressing',
    'plugins.lualine',
    'plugins.todo-comments',
    'plugins.copilot',
    'plugins.tmux',
    'plugins.anyman',
    'plugins.outline',
};



local function get_plugins()
    local p = {};
    for _, plugin in pairs(plugins) do
        table.insert(p, require(plugin))
    end
    return p;
end

local function get_plugin_configs()
    local configs = {};
    for _, plugin in pairs(get_plugins()) do
        local plugin_config = plugin.init();

        if plugin_config ~= nil then
            table.insert(configs, plugin.init());
        end
    end
    return configs;
end

local function setup_plugins()
    for _, plugin in pairs(get_plugins()) do
        plugin.setup();
    end
end

local function initialize_lazy()
    local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not vim.loop.fs_stat(lazy_path) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazy_path
        });
    end

    vim.opt.rtp:prepend(lazy_path);
end

local function setup_lazy(options)
    require("lazy").setup(options)
end

M.setup = function()
    initialize_lazy();
    setup_lazy(get_plugin_configs());
    setup_plugins();
end

return M;
