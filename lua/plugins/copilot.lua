local M = {};

-- This function will be used by lazy to load the module
M.init = function()
    return {
        'CopilotC-Nvim/CopilotChat.nvim',
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
        server = {
            type = 'binary'
        },
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
end

return M;
