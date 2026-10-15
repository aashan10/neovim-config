local M = {}

M.init = function()
    return {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter',
        lazy = false,       -- Important: plugin does not support lazy-loading
        build = ':TSUpdate' -- Auto-update parsers on plugin update
    }
end

M.setup = function()
    -- ========================================================================
    -- SETUP (Optional - works with defaults if not called)
    -- ========================================================================
    require('nvim-treesitter').setup({
        -- Directory to install parsers and queries
        install_dir = vim.fn.stdpath('data') .. '/site'
    })

    -- ========================================================================
    -- INSTALL PARSERS
    -- ========================================================================
    -- This replaces the old ensure_installed config
    require('nvim-treesitter').install({
        -- Web
        'html',
        'css',
        'scss',
        'javascript',
        'typescript',
        'tsx',
        'vue',

        -- PHP ecosystem
        'php',
        'phpdoc',
        'twig',

        -- Systems
        'rust',
        'go',
        'lua',
    })

    -- ========================================================================
    -- ENABLE HIGHLIGHTING
    -- ========================================================================
    -- The new API requires explicit vim.treesitter.start() calls
    -- Put this in ftplugin files OR use autocmd

    local highlight_filetypes = {
        'php',
        'html',
        'css',
        'scss',
        'javascript',
        'typescript',
        'typescriptreact',
        'tsx',
        'vue',
        'rust',
        'go',
        'lua',
        'twig',
        'blade',
    }

    vim.api.nvim_create_autocmd('FileType', {
        pattern = highlight_filetypes,
        callback = function()
            vim.treesitter.start()
        end,
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = highlight_filetypes,
        callback = function()
            vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo[0][0].foldmethod = 'expr'
        end,
    })

    -- ========================================================================
    -- ENABLE INDENTATION (Experimental - Optional)
    -- ========================================================================
    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'javascript', 'typescript', 'tsx', 'rust', 'go', 'lua', 'php', 'html', 'css', 'scss', 'vue', 'twig', 'blade' },
        callback = function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })

    -- Detect .blade.php files
    vim.filetype.add({
        pattern = {
            ['.*%.blade%.php'] = 'blade',
        },
    })
end

return M
