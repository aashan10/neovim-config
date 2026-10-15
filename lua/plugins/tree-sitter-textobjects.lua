local M = {}

-- This function will be used by lazy to load the module
M.init = function()
    return {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
    }
end

-- Any extra configuration goes here
-- You can do stuff like keymappings or just any general configuration
-- This method runs after all the plugins are loaded
M.setup = function()
    -- Disable built-in ftplugin mappings to avoid conflicts
    vim.g.no_plugin_maps = true

    -- Setup textobjects
    require('nvim-treesitter-textobjects').setup({
        select = {
            -- Automatically jump forward to textobj
            lookahead = true,

            -- Selection modes for different text objects
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V',  -- linewise
                ['@class.outer'] = 'V',     -- linewise
            },

            -- Don't include surrounding whitespace
            include_surrounding_whitespace = false,
        },

        move = {
            -- Set jumps in the jumplist
            set_jumps = true,
        },
    })

    -- ========================================================================
    -- TEXT OBJECT SELECTION KEYMAPS
    -- ========================================================================
    local select = require('nvim-treesitter-textobjects.select')

    -- Functions
    vim.keymap.set({ 'x', 'o' }, 'af', function()
        select.select_textobject('@function.outer', 'textobjects')
    end, { desc = 'Select outer function' })

    vim.keymap.set({ 'x', 'o' }, 'if', function()
        select.select_textobject('@function.inner', 'textobjects')
    end, { desc = 'Select inner function' })

    -- Classes
    vim.keymap.set({ 'x', 'o' }, 'ac', function()
        select.select_textobject('@class.outer', 'textobjects')
    end, { desc = 'Select outer class' })

    vim.keymap.set({ 'x', 'o' }, 'ic', function()
        select.select_textobject('@class.inner', 'textobjects')
    end, { desc = 'Select inner class' })

    -- Parameters/Arguments
    vim.keymap.set({ 'x', 'o' }, 'aa', function()
        select.select_textobject('@parameter.outer', 'textobjects')
    end, { desc = 'Select outer parameter' })

    vim.keymap.set({ 'x', 'o' }, 'ia', function()
        select.select_textobject('@parameter.inner', 'textobjects')
    end, { desc = 'Select inner parameter' })

    -- Conditionals (if/else)
    vim.keymap.set({ 'x', 'o' }, 'ai', function()
        select.select_textobject('@conditional.outer', 'textobjects')
    end, { desc = 'Select outer conditional' })

    vim.keymap.set({ 'x', 'o' }, 'ii', function()
        select.select_textobject('@conditional.inner', 'textobjects')
    end, { desc = 'Select inner conditional' })

    -- Loops (for/while)
    vim.keymap.set({ 'x', 'o' }, 'al', function()
        select.select_textobject('@loop.outer', 'textobjects')
    end, { desc = 'Select outer loop' })

    vim.keymap.set({ 'x', 'o' }, 'il', function()
        select.select_textobject('@loop.inner', 'textobjects')
    end, { desc = 'Select inner loop' })

    -- Comments
    vim.keymap.set({ 'x', 'o' }, 'a/', function()
        select.select_textobject('@comment.outer', 'textobjects')
    end, { desc = 'Select comment' })

    -- Blocks
    vim.keymap.set({ 'x', 'o' }, 'ab', function()
        select.select_textobject('@block.outer', 'textobjects')
    end, { desc = 'Select outer block' })

    vim.keymap.set({ 'x', 'o' }, 'ib', function()
        select.select_textobject('@block.inner', 'textobjects')
    end, { desc = 'Select inner block' })

    -- Calls
    vim.keymap.set({ 'x', 'o' }, 'aF', function()
        select.select_textobject('@call.outer', 'textobjects')
    end, { desc = 'Select outer call' })

    vim.keymap.set({ 'x', 'o' }, 'iF', function()
        select.select_textobject('@call.inner', 'textobjects')
    end, { desc = 'Select inner call' })

    -- ========================================================================
    -- MOVEMENT KEYMAPS
    -- ========================================================================
    local move = require('nvim-treesitter-textobjects.move')

    -- Functions
    vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
        move.goto_next_start('@function.outer', 'textobjects')
    end, { desc = 'Next function start' })

    vim.keymap.set({ 'n', 'x', 'o' }, ']F', function()
        move.goto_next_end('@function.outer', 'textobjects')
    end, { desc = 'Next function end' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
        move.goto_previous_start('@function.outer', 'textobjects')
    end, { desc = 'Previous function start' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[F', function()
        move.goto_previous_end('@function.outer', 'textobjects')
    end, { desc = 'Previous function end' })

    -- Classes
    vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
        move.goto_next_start('@class.outer', 'textobjects')
    end, { desc = 'Next class start' })

    vim.keymap.set({ 'n', 'x', 'o' }, ']C', function()
        move.goto_next_end('@class.outer', 'textobjects')
    end, { desc = 'Next class end' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
        move.goto_previous_start('@class.outer', 'textobjects')
    end, { desc = 'Previous class start' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[C', function()
        move.goto_previous_end('@class.outer', 'textobjects')
    end, { desc = 'Previous class end' })

    -- Parameters
    vim.keymap.set({ 'n', 'x', 'o' }, ']a', function()
        move.goto_next_start('@parameter.inner', 'textobjects')
    end, { desc = 'Next parameter' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[a', function()
        move.goto_previous_start('@parameter.inner', 'textobjects')
    end, { desc = 'Previous parameter' })

    -- Conditionals
    vim.keymap.set({ 'n', 'x', 'o' }, ']i', function()
        move.goto_next_start('@conditional.outer', 'textobjects')
    end, { desc = 'Next conditional' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[i', function()
        move.goto_previous_start('@conditional.outer', 'textobjects')
    end, { desc = 'Previous conditional' })

    -- Loops
    vim.keymap.set({ 'n', 'x', 'o' }, ']l', function()
        move.goto_next_start('@loop.outer', 'textobjects')
    end, { desc = 'Next loop' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[l', function()
        move.goto_previous_start('@loop.outer', 'textobjects')
    end, { desc = 'Previous loop' })

    -- Comments
    vim.keymap.set({ 'n', 'x', 'o' }, ']/', function()
        move.goto_next_start('@comment.outer', 'textobjects')
    end, { desc = 'Next comment' })

    vim.keymap.set({ 'n', 'x', 'o' }, '[/', function()
        move.goto_previous_start('@comment.outer', 'textobjects')
    end, { desc = 'Previous comment' })

    -- ========================================================================
    -- SWAP KEYMAPS
    -- ========================================================================
    local swap = require('nvim-treesitter-textobjects.swap')

    -- Swap parameters
    vim.keymap.set('n', '<leader>na', function()
        swap.swap_next('@parameter.inner')
    end, { desc = 'Swap with next parameter' })

    vim.keymap.set('n', '<leader>pa', function()
        swap.swap_previous('@parameter.inner')
    end, { desc = 'Swap with previous parameter' })

    -- Swap functions
    vim.keymap.set('n', '<leader>nf', function()
        swap.swap_next('@function.outer')
    end, { desc = 'Swap with next function' })

    vim.keymap.set('n', '<leader>pf', function()
        swap.swap_previous('@function.outer')
    end, { desc = 'Swap with previous function' })

    -- ========================================================================
    -- REPEATABLE MOVEMENTS
    -- ========================================================================
    local ts_repeat = require('nvim-treesitter-textobjects.repeatable_move')

    -- Make treesitter movements repeatable with ; and ,
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat.repeat_last_move_next)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat.repeat_last_move_previous)

    -- Make built-in f, F, t, T repeatable
    vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat.builtin_f_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat.builtin_F_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat.builtin_t_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat.builtin_T_expr, { expr = true })
end

return M
