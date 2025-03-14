vim.api.nvim_create_user_command("FormatDisable", function(args)
    if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
    else
        vim.g.disable_autoformat = true
    end
end, {
    desc = "Disable autoformat-on-save",
    bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
end, {
    desc = "Re-enable autoformat-on-save",
})


vim.api.nvim_create_user_command("SearchIncludeVendor", function()
    vim.g.telescope_find_vendor = true
end, {
    desc = "Enable telescope search for vendor files"
});

vim.api.nvim_create_user_command("SearchExcludeVendor", function()
    vim.g.telescope_find_vendor = false
end, {
    desc = "Disable telescope search for vendor files"
})
