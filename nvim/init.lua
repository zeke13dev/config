-- Load individual configuration modules
require('theme')
require('settings')      -- Basic settings
require('plugins')       -- Plugin setup and installation
-- require('lsp')           -- LSP configuration
require('rust')    -- Rust-specific configurations
require('python') -- Python-specific configurations

-- Load custom functions (defines `Init` and `Bye` commands)
require('functions')

-- Load key mappings
require('mappings')

-- Automatically call Init on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd('Init')
  end,
})
