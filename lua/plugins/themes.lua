local M = {};

local enabled_theme = 'kanagawa';

local plugins = {
    'plugins.themes.kanagawa',
};

M.init = function()
    local specs = {};

    for _, plugin in ipairs(plugins) do
        local plugin_module = require(plugin);
        if plugin_module.enabled then
            local plugin_specs = plugin_module.dependencies();
            vim.list_extend(specs, plugin_specs);
        end
    end

    return specs;
end


M.setup = function()
    for _, plugin in ipairs(plugins) do
        local plugin_module = require(plugin);
        if plugin_module.enabled then
            plugin_module.setup();
        end
    end

    if enabled_theme ~= nil then
        vim.cmd.colorscheme(enabled_theme);
    end
end

return M;
