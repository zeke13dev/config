-- Create an autocommand to set filetype for .c0 and .c1 files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.c0", "*.c1" },
  callback = function()
    vim.bo.filetype = "c0_syntax"
  end,
})

-- Optionally print a message when the syntax file is loaded (for debugging)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c0_syntax",
  callback = function()
    print("Loaded c0_syntax for .c0/.c1 files")
  end,
})

