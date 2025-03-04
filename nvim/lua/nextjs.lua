-- Configure LSP with minimal settings (no completion)
local lspconfig = require('lspconfig')

-- On attach function without completion
local on_attach = function(client, bufnr)
  -- Disable formatting for typescript language server (if you use eslint/prettier)
  if client.name == "ts_ls" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
  
  -- Key mappings - following similar style to your Rust setup
  local opts = { noremap = true, silent = true }
  
  -- Add format on save for all supported LSP clients
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      -- For ESLint
      if client.name == "eslint" then
        -- Attempt to format with ESLint, suppressing errors
        local success, err = pcall(function()
          vim.cmd("EslintFixAll")
        end)
        if not success then
          -- Optionally log or handle the error silently
          -- print("ESLint error: " .. err)  -- Uncomment to log errors if needed
        end
      end
      
      -- For general LSP formatting
      if client.server_capabilities.documentFormattingProvider then
        -- Attempt to format the buffer synchronously, suppressing errors
        local success, err = pcall(function()
          vim.lsp.buf.format({ async = false })
        end)
        if not success then
          -- Optionally log or handle the error silently
          -- print("Formatting error: " .. err)  -- Uncomment to log errors if needed
        end
      end
    end,
  })
end

-- Basic capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Setup TypeScript/JavaScript server (using typescript-language-server)
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
})

-- Setup ESLint server
lspconfig.eslint.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine"
      },
      showDocumentation = {
        enable = true
      },
    },
    codeActionOnSave = {
      enable = true,
      mode = "all"
    },
    format = true,
    packageManager = "npm",
    quiet = false,
    rulesCustomizations = {},
    run = "onType",
    useESLintClass = false,
    validate = "on",
    workingDirectory = {
      mode = "location"
    }
  },
})

-- Setup CSS server
lspconfig.cssls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Setup HTML server
lspconfig.html.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- File type specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    -- Use 2 spaces for indentation
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
    vim.bo.softtabstop = 2
    vim.bo.smartindent = true
  end
})

-- Add a global autocmd for automatic linting on save for all JavaScript/TypeScript files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
    -- Run ESLint fix all
    local eslint_success, eslint_err = pcall(function()
      vim.cmd("EslintFixAll")
    end)
    
    -- Also run general formatting (for any other formatters)
    local format_success, format_err = pcall(function()
      vim.lsp.buf.format({ async = false })
    end)
    
    -- Print success message to confirm linting happened
    if eslint_success or format_success then
      -- Uncomment the line below if you want confirmation in the command line
      -- vim.notify("Linting completed on save", vim.log.levels.INFO)
    end
  end,
})

-- Add .tsx and .jsx files to be recognized properly
vim.cmd([[
  autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
]])
local has_mason, mason = pcall(require, "mason")
local has_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")

if has_mason and has_mason_lspconfig then
  mason.setup()
  mason_lspconfig.setup({
    ensure_installed = { "ts_ls", "eslint", "cssls", "html" },
    automatic_installation = true,
  })
end

-- Configure null-ls for formatting (optional)
local has_null_ls, null_ls = pcall(require, "null-ls")
if has_null_ls then
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.diagnostics.eslint,
    },
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      
      -- Add synchronous formatting on save like in your Rust setup
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
  })
end

-- Add Telescope keybindings for better navigation (if installed)
local has_telescope = pcall(require, "telescope")
if has_telescope then
  local opts = { noremap = true, silent = true }
  vim.keymap.set('n', '<leader>ff', "<cmd>Telescope find_files<CR>", opts)
  vim.keymap.set('n', '<leader>fg', "<cmd>Telescope live_grep<CR>", opts)
  vim.keymap.set('n', '<leader>fb', "<cmd>Telescope buffers<CR>", opts)
end

-- Setup customized diagnostics display
vim.diagnostic.config({
  virtual_text = {
    prefix = "●", -- Matches your existing theme
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

return {
  -- Export functions if needed
}
