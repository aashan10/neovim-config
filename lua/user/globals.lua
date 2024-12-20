vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.g.mapleader = " "
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.smartindent = false
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.wrap = false
vim.opt.cmdheight = 0
vim.opt.clipboard = "unnamedplus"

vim.filetype.add({
    pattern = {
        [".*%.blade%.php"] = "blade",
        [".*%.twig"] = "twig"
    }
});
