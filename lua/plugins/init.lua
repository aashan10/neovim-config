local M = {};

-- Register Your Plugins Here
local plugins = {
    'plugins.mini',
    'plugins.barbar',
    'plugins.tree-sitter',
    'plugins.telescope',
    'plugins.git-signs',
    'plugins.lazy-git',
    'plugins.nvim-cmp',
    'plugins.lsp',
    'plugins.harpoon',
    'plugins.whichkey',
    'plugins.ultimate-autopairs',
    'plugins.lualine',
    'plugins.todo-comments',
    'plugins.copilot',
    'plugins.tmux',
    'plugins.anyman',
    'plugins.outline',
    'plugins.colorizer',
    'plugins.conform',
    'plugins.refactoring',
    'plugins.themes',
};

local function get_plugins()
    local p = {};
    for _, plugin in pairs(plugins) do
        table.insert(p, require(plugin))
    end
    return p;
end

local function collect_specs()
    local specs = {};
    for _, plugin in pairs(get_plugins()) do
        local plugin_specs = plugin.init();
        if plugin_specs == nil then goto continue end
        if vim.islist(plugin_specs) then
            vim.list_extend(specs, plugin_specs);
        else
            table.insert(specs, plugin_specs);
        end
        ::continue::
    end
    return specs;
end

local function setup_plugins()
    for _, plugin in pairs(get_plugins()) do
        plugin.setup();
    end
end

M.setup = function()
    vim.pack.add(collect_specs());
    setup_plugins();
end

return M;
