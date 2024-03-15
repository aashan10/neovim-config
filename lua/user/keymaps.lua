local keymap = vim.keymap.set;



keymap('n', '[d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', ']d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', '<leader>bad', '<cmd>bufdo :bdelete<CR>', { desc = "Delete all buffers" })
keymap('n', '<C-i>', '<cmd>Inspect<CR>', { desc = "Inspect Current Char" })
