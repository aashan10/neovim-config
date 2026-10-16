
require("user").setup_globals();

require("plugins").setup();

require("user").after_plugins()

-- Auto-load .env if present
local env_path = vim.fn.stdpath('config') .. '/.env'
if vim.fn.filereadable(env_path) == 1 then
    require('utils.dotenv').load(env_path)
end
