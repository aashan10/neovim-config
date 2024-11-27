local M = {};

M.setup_globals = function()
    require("user.globals");
    require("user.commands");
    require("user.keymaps");
end

M.after_plugins = function()
end

return M;
