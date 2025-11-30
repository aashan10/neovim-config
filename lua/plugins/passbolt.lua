local M = {};

M.init = function()
    return {
        "aashan10/passbolt.nvim"
    }
end

M.setup = function()
    require("passbolt").setup({
        config_file = "/Users/aashan/.config/go-passbolt-cli/go-passbolt-cli.toml",
    })

    vim.keymap.set('n', '<leader>pb', function() end, { desc = "Passbolt: Open Passbolt" })
end

return M;
