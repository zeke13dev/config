require('rust-tools').setup({
  tools = {
    inlay_hints = {
      auto = false,
      show_parameter_hints = false,
      show_variable_name = false,
    },
  },
  server = {
    on_attach = function(_, bufnr)
      local opts = { noremap=true, silent=true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

      -- Enable linting on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = true })  -- Auto-format on save
          vim.lsp.buf.code_action({  -- Run code actions, such as clippy warnings
            context = { only = { "source.fixAll" } },
            apply = true,
          })
        end,
      })
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy", -- Use `clippy` to lint on save
        },
      },
    },
  },
})

