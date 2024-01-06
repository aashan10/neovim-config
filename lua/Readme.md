### Installing a Nvim Plugin

This configuration uses lazy.nvim for managing plugins

Each Plugin must be a lua module that returns two functions `init` and `setup`.
The init must return a table that is used by lazy and the configure function must keep all the code required for instiating the plugin.

```lua

local M = {};

M.init = function()

end

M.setup = function()

end

return M;
```

There is a template provided [here](./plugins/plugin-template.lua) which you can copy paste.

Finally, you'll need to register the plugin module inside `plugins/init.lua` like this:

```lua

local plugins = {
    "plugins.your-plugin-file-name"
}

```

