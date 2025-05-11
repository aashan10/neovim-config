local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        'CopilotC-Nvim/CopilotChat.nvim',
        branch = 'main',
        event = "BufEnter",
        dependencies = {
            'zbirenbaum/copilot.lua'
        }
    }
end

-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()
    local copilot = require('copilot');

    copilot.setup({
        panel = {
            auto_refresh = true,
            layout = {
                position = 'right',
                ratio = 0.4
            },
            keymap = {
                jump_prev = '<C-p>',
                jump_next = '<C-n>',
                accept = '<CR>',
                refresh = '<C-r>',
                open = '<leader>cp'
            },
        },

        suggestion = {
            auto_trigger = true,
            keymap = {
                accept = '<C-Right>',
                reject = '<C-x>',
                next = '<C-n>',
                prev = '<C-p>'
            }
        },
    });

    local chat = require('CopilotChat');
    chat.setup();



    -- Keymap to open the copilot panel
    vim.keymap.set('n', '<leader>cp', function() require("copilot.panel").open() end,
        { noremap = true, silent = true, desc = 'Copilot: Open Panel' });
    vim.keymap.set({ 'n', 'v' }, '<leader>cf',
        function()
            local actions = require('CopilotChat.actions');
            require('CopilotChat.integrations.telescope').pick(actions.prompt_actions());
        end,
        { noremap = true, silent = true, desc = 'Copilot: Open Panel (File)' }
    );
    vim.keymap.set({ 'n', 'v' }, '<leader>ch',
        function()
            local actions = require('CopilotChat.actions');
            require('CopilotChat.integrations.telescope').pick(actions.help_actions());
        end,
        { noremap = true, silent = true, desc = 'Copilot: Open Panel (File)' }
    );
end

return M;
