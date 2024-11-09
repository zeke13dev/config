require('lspconfig').pyright.setup({
  on_attach = function(_, bufnr)
    local opts = { noremap = true, silent = true }
    -- Keymaps for LSP actions
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- Auto-format and lint on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        -- Run flake8 asynchronously
        vim.fn.jobstart("flake8 " .. vim.fn.expand("%"), {
          stdout_buffered = true,
          stderr_buffered = true,
          on_exit = function(_, exit_code)
            if exit_code == 0 then
              -- If no linting errors, format with black asynchronously
              vim.fn.jobstart("black " .. vim.fn.expand("%"), {
                stdout_buffered = true,
                stderr_buffered = true,
                on_exit = function(_, black_exit_code)
                  if black_exit_code ~= 0 then
                    print("Black formatting failed.")
                  end
                end,
              })
            else
              print("flake8 detected issues. Skipping black formatting.")
            end
          end,
        })
        -- Use LSP to apply code fixes asynchronously (if available)
        vim.lsp.buf.code_action({
          context = { only = { "source.fixAll" } },
          apply = true,
        })
        -- Format with LSP as well (non-blocking)
        vim.lsp.buf.format({ async = true })
      end,
    })
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",  -- Options: off, basic, strict
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
      pythonPath = (function()
        -- Automatically find the Python interpreter from the virtual environment
        local venv_path = vim.fn.getcwd() .. "/venv/bin/python3"
        if vim.fn.executable(venv_path) == 1 then
          return venv_path
        else
          -- Fallback to system Python if no virtual environment is found
          return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
        end
      end)()
    },
  },
})
