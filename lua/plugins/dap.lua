local M = {};

M.init = function()
    return {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'theHamsta/nvim-dap-virtual-text',
            'nvim-telescope/telescope-dap.nvim'
        }
    }
end

M.setup = function()
    local dap = require('dap');
    local dapui = require('dapui').setup();
    -- require('dap.nvim-dap-ui');
    require('telescope').load_extension('dap');
    -- require('dap.nvim-dap-virtual-text');
    dap.adapters.php = {
        type = 'executable',
        command = 'php-debug-adapter'
    }

    dap.configurations.php = {
        {
            type = 'php',
            request = 'launch',
            name = 'Run Current Script',
            port = 9003,
            cwd = "${fileDirname}",
            program = "${file}",
            runtimeExecutable = "php"
        },
        {
            type = "php",
            name = "Listen for Request",
            request = "launch",
            port = 9003
        }
    }

    local keymap = vim.keymap.set;
    keymap('n', '<F5>', function() require('dap').continue() end)
    keymap('n', '<F10>', function() require('dap').step_over() end)
    keymap('n', '<F11>', function() require('dap').step_into() end)
    keymap('n', '<F12>', function() require('dap').step_out() end)
    keymap('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
    keymap('n', '<Leader>B', function() require('dap').set_breakpoint() end)
    keymap('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
    keymap('n', '<Leader>dr', function() require('dap').repl.open() end)
    keymap('n', '<Leader>dl', function() require('dap').run_last() end)
    keymap({ 'n', 'v' }, '<Leader>dh', function()
        require('dap.ui.widgets').hover()
    end)
    keymap({ 'n', 'v' }, '<Leader>dp', function()
        require('dap.ui.widgets').preview()
    end)
    keymap('n', '<Leader>df', function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.frames)
    end)
    keymap('n', '<Leader>ds', function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
    end)
end

return M;
