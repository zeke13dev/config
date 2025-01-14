require('rust-tools').setup({
  tools = {
    inlay_hints = {
      auto = false,
      show_parameter_hints = false,
      show_variable_name = false,
    },
  },
  server = {
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" },
        diagnostics = {
          ignored = { ".cargo/**" }, -- Ignore `.cargo` directory
        },
      },
    },
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

      -- Add a new BufWritePre autocmd for synchronous formatting using rustfmt
      vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            -- Attempt to format the buffer synchronously, suppressing errors
            local success, err = pcall(function()
              vim.lsp.buf.format({ async = false })
            end)
            if not success then
              -- Optionally log or handle the error silently
              -- print("Formatting error: " .. err)  -- Uncomment to log errors if needed
            end
          end,
        })
    end,
  },
})

