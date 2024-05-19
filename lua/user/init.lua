local M = {};

M.setup_globals = function()
    require("user.globals");
    require("user.keymaps");
end

M.after_plugins = function()
    require("user.theme").setup();
end

return M;
