-- General settings
vim.o.termguicolors = true  -- Enable true color support
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Enable line numbers and cursor line
vim.wo.number = true
vim.o.cursorline = true

-- Disable text wrapping
vim.o.wrap = false

-- Use system clipboard
vim.o.clipboard = 'unnamedplus'

-- Set indentation to 2 spaces for C files only
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

