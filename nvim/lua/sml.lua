local lspconfig = require('lspconfig')

lspconfig.millet.setup({
  cmd = { "millet", "." }, -- Use explicit command
  filetypes = { "sml" },
  root_dir = lspconfig.util.root_pattern("millet.toml") or lspconfig.util.find_git_ancestor,
  single_file_support = true,
})

-- Auto-detect .sml files and apply syntax highlighting
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.sml",
  callback = function()
    vim.bo.filetype = "sml"
  end,
})

-- Keybindings for LSP features (rename, hover, definition, etc.)
vim.api.nvim_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ca', '<Cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })

-- Set up autoformatting when saving .sml files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.sml",
  callback = function()
    vim.lsp.buf.format({ async = true })
  end,
})

vim.lsp.set_log_level("debug")
