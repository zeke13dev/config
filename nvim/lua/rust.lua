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
        procMacro = { enable = true},
        diagnostics = {
          ignored = { ".cargo/**" },  -- Ignore `.cargo` directory
          enable = true,
        },
      },
    },
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

      -- Custom diagnostics handler to filter out specific error
      client.handlers["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
        if result.diagnostics == nil then return end
        -- Filter out the specific error (tokio proc-macro error)
        result.diagnostics = vim.tbl_filter(function(diagnostic)
          return not diagnostic.message:match("cannot find proc%-macro server")
        end, result.diagnostics)
        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
      end

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

