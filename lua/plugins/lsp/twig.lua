local M = {}

M.setup = function()
    vim.filetype.add({
        extension = {
            twig = "html.twig",
        },
        pattern = {
            ["%.twig%.html$"] = "html.twig",
        }
    })

    local anyman = require('plugins.anyman')

    local phpExecutable = "php"
    local symfonyConsolePath = "bin/console"

    if anyman.is_any_project() then
        -- Create a wrapper script for Docker execution
        local wrapper_path = vim.fn.stdpath('cache') .. '/twig-php-wrapper.sh'
        local docker_compose_path = anyman.get_anyman_path() .. "docker-compose.yml"

        local wrapper_content = string.format([[#!/bin/bash
exec docker compose -f "%s" exec -T pimcore php "$@"
]], docker_compose_path)

        -- Write the wrapper script
        local file = io.open(wrapper_path, 'w')
        if file then
            file:write(wrapper_content)
            file:close()
            -- Make it executable
            vim.fn.system({ 'chmod', '+x', wrapper_path })
        end

        phpExecutable = wrapper_path
        symfonyConsolePath = "/var/www/html/bin/console"
    end

    vim.lsp.enable('twiggy_language_server')

    vim.lsp.config('twiggy_language_server', {
        settings = {
            twiggy = {
                framework = "symfony",
                phpExecutable = phpExecutable,
                symfonyConsolePath = symfonyConsolePath,
                diagnostics = {
                    twigCsFixer = false,
                },
                autoInsertSpaces = true,
            }
        }
    })
end

return M
