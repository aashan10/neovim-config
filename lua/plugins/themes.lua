local M = {};

local enabled_theme = 'kanagawa';

local plugins = {
    'plugins.themes.kanagawa',
};

M.init = function()
    local dependencies = {};

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
