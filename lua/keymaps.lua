-- Movement
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Clipboard
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set('n', '<leader>Y', [["+Y]])
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])

-- Save
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- Search: clear highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Buffers
vim.keymap.set('n', '<leader>bd', ':bdel<Return>', { desc = 'Delete buffer' })

-- Windows
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>wh', '<C-w>s', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>we', '<C-w>=', { desc = 'Make splits equal size' })
vim.keymap.set('n', '<leader>wq', '<C-w>q', { desc = 'Close current window' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Close all other windows' })
vim.keymap.set('n', '<leader>wm', '<C-w>|', { desc = 'Maximize window width' })
vim.keymap.set('n', '<leader>w_', '<C-w>_', { desc = 'Maximize window height' })
vim.keymap.set('n', '<leader>ww', '<C-w>w', { desc = 'Cycle windows' })
vim.keymap.set('n', '<leader>qa', '<cmd>qa<CR>', { desc = 'Quit all' })

-- Diagnostics
vim.keymap.set('n', '[d', function() vim.diagnostic.jump { count = -1 } end, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump { count = 1 } end, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

-- Terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Neovide
if vim.g.neovide then
  local opts = { silent = true, noremap = true }
  vim.keymap.set({ 'n', 'v' }, '<D-v>', '"*p', opts)
  vim.keymap.set({ 'n', 'v' }, '<D-c>', '"*y', opts)
  vim.keymap.set({ 'n', 'v' }, '<D-x>', '"*x', opts)
  vim.keymap.set('i', '<D-v>', '<C-r>+', opts)
end
