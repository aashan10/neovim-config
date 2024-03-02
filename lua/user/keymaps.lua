local keymap = vim.keymap.set;



keymap('n', '[d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', ']d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', '<leader>bad', '<cmd>bufdo :bdelete<CR>')
