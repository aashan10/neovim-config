local keymap = vim.keymap.set;



keymap('n', '[d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', ']d', '<cmd>bd<CR>', { desc = 'Destroy current buffer' });
keymap('n', '<leader>gi<CR>', function() vim.lsp.buf.go_to_implementation() end, { desc = "Go to implementation" })
