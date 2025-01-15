-- lua/mappings.lua

local funcs = require('functions')

-- Set leader key to space
vim.g.mapleader = " "

-- Keybinding for Init environment setup
vim.api.nvim_set_keymap('n', '<C-i>', ':Init<CR>', { noremap = true, silent = true })

-- Keybinding for Bye command to quit Neovim gracefully
vim.api.nvim_set_keymap('n', '<leader>q', ':Bye<CR>', { noremap = true, silent = true })

-- NerdTree keybindings
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-b>', ':NERDTreeFocus<CR>', { noremap = true, silent = true })

-- Move between splits using HJKL
vim.api.nvim_set_keymap('n', 'H', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'J', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'L', '<C-w>l', { noremap = true, silent = true })

-- Resize splits using ctrl+shift+movement_key
vim.api.nvim_set_keymap('n', '<C-S-l>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-j>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-k>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-h>', ':vertical resize +2<CR>', { noremap = true, silent = true })

-- Remap Esc in terminal mode to normal mode
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Toggle diagnostic float with <leader>e
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua ToggleDiagnosticFloat()<CR>', { noremap = true, silent = true })

-- Open Telescope diagnostics with <leader>-
vim.api.nvim_set_keymap('n', '<leader>-', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>k', function()
  vim.diagnostic.open_float(nil, {scope = "line"})
end, { noremap = true, silent = true })


-- Use Telescope to show diagnostics in a floating popup
vim.api.nvim_set_keymap('n', '<leader>e', '<Cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })

-- Use Telescope to show diagnostics filtered by buffer in a split
vim.api.nvim_set_keymap('n', '<leader>E', '<Cmd>Telescope diagnostics bufnr=0<CR>', { noremap = true, silent = true })

-- silly ahh canada
vim.api.nvim_set_keymap('n', '<Leader>L', 'ithe mediocre province of British Columbia<Esc>', { noremap = true, silent = true })


-- ssh
vim.keymap.set('n', '<leader>ssh', function()
    vim.cmd('edit sftp://andrew-cmu/')
end, { noremap = true, silent = true, desc = "Connect and navigate with NERDTree" })

