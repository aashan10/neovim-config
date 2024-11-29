local M = {};



M.setup = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities();
    local lspconfig = require('lspconfig');


    local anyman = require('plugins.anyman');

    local phpExecutable = "php";
    local symfonyConsolePath = "bin/console";

    if anyman.is_any_project() then
        phpExecutable = "docker compose -f " .. anyman.get_anyman_path() .. "docker-compose.yml exec -it pimcore php";
        symfonyConsolePath = "/var/www/html/bin/console";
    end

    lspconfig.twiggy_language_server.setup {
        settings = {
            twiggy = {
                framework = "symfony",
                phpExecutable = phpExecutable,
                symfonyConsolePath = symfonyConsolePath
            }
        },
        capabilities = capabilities
    }
end

return M;
