local M = {};

M.init = function()
    return {
        'mfussenegger/nvim-dap',
        dependencies = {
            {
                'rcarriga/nvim-dap-ui',
                dependencies = {
                    'nvim-neotest/nvim-nio'
                }
            },
        },
        event = "VimEnter"
    }
end

M.load_dap_config = function()
    local dap = require('dap');
    local json_file_path = vim.fn.getcwd() .. '/.xdebug.json';
    -- check if file exists and if so, parse json file to lua table

    local file = io.open(json_file_path, 'r');

    if file ~= nil then
        dap.configurations.php = nil;
        dap.configurations.starter = nil;
        local json = file:read('*all');
        local config = vim.fn.json_decode(json);
        if config ~= nil then
            -- dap.adapters.php = config.adapters

            local starters = {};

            for _, conf in pairs(config.configurations) do
                -- push config to starters
                conf.pathMappings = {
                    ['/var/www/html'] = vim.fn.getcwd()
                }
                table.insert(starters, conf);
            end

            dap.configurations.php = starters;
            if starters ~= nil then
                dap.configurations.starter = starters;
            end
        end
        file:close();
    end
end

M.setup = function()
    local dap = require('dap');
    local dap_ui = require('dapui');
    dap_ui.setup();

    -- Keymaps
    vim.keymap.set('n', '<leader>b', function()
        dap.toggle_breakpoint();
    end, { desc = "DAP: Toggle Breakpoint" });

    vim.keymap.set('n', '<leader>do', function()
        -- toggle dap ui
        dap_ui.toggle();
    end, { desc = "DAP: Toggle UI" }
    )

    vim.keymap.set('n', '<leader>dr', function()
        M.load_dap_config();
    end, { desc = "DAP: Reload Config" }
    )
    vim.keymap.set('n', '<leader>dbg', function()
        dap.continue();
    end, { desc = "DAP: Start Debugging" });
    -- Event Listeners
    dap.listeners.before.launch.dapui_config = function()
        dap_ui.open();
    end

    dap.listeners.before.attach.dapui_config = function()
        dap_ui.open();
    end

    dap.listeners.before.event_terminated.dapui_config = function()
        dap_ui.close();
    end

    dap.listeners.before.event_exited.dapui_config = function()
        dap_ui.close();
    end

    -- Breakpoing Signs
    vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = ' →', texthl = 'DapStopped', linehl = '', numhl = '' })


    -- Adapters and Configurations

    dap.adapters.php = {
        type = 'executable',
        command = vim.fn.stdpath('data') .. '/mason/bin/php-debug-adapter',
        args = {}
    }
    M.load_dap_config();
end

return M;
