-- Next.js Complete LSP Configuration for Neovim

local lspconfig = require('lspconfig')
local ts = lspconfig.ts_ls or lspconfig.tsserver
local null_ls_ok, null_ls = pcall(require, "null-ls")

-- On-attach function (without nvim-cmp or mason)
local on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end

  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = true })
  end, opts)
end

-- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- TypeScript/JavaScript
ts.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'literal',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    }
  }
})

-- CSS
lspconfig.cssls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    css = { validate = true, lint = { unknownAtRules = "ignore" } },
    scss = { validate = true, lint = { unknownAtRules = "ignore" } },
    less = { validate = true, lint = { unknownAtRules = "ignore" } },
  }
})

-- HTML
lspconfig.html.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "templ" }
})

-- Tailwind CSS
lspconfig.tailwindcss.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {
    "html", "css", "scss",
    "javascript", "javascriptreact",
    "typescript", "typescriptreact"
  },
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning"
      },
      validate = true
    }
  }
})

-- Format on save (null-ls OR other LSP)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function()
    local ok = pcall(function()
      vim.cmd("EslintFixAll")
    end)
    local fmt = pcall(function()
      vim.lsp.buf.format({ async = false })
    end)
  end,
})

-- Optional: null-ls (prettier + eslint)
if null_ls_ok then
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.prettier.with({
        filetypes = {
          "javascript", "javascriptreact",
          "typescript", "typescriptreact",
          "css", "scss", "html", "json", "markdown"
        },
      }),
      null_ls.builtins.diagnostics.eslint.with({
        filetypes = {
          "javascript", "javascriptreact",
          "typescript", "typescriptreact"
        },
      }),
    },
    on_attach = on_attach,
  })
end

-- Filetype-specific indent settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
    vim.bo.softtabstop = 2
    vim.bo.smartindent = true
  end,
})

-- File associations
vim.cmd([[
  autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
  autocmd BufNewFile,BufRead *.mdx set filetype=markdown
  autocmd BufNewFile,BufRead .env.* set filetype=sh
  autocmd BufNewFile,BufRead next.config.* set filetype=typescript
]])

-- Diagnostics UI
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
    severity = { min = vim.diagnostic.severity.WARN },
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

for _, sign in ipairs({
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn",  text = "" },
  { name = "DiagnosticSignHint",  text = "" },
  { name = "DiagnosticSignInfo",  text = "" },
}) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

-- Next.js commands
vim.api.nvim_create_user_command('NextBuild', function()
  vim.cmd('!npm run build')
end, { desc = 'Run Next.js build' })

vim.api.nvim_create_user_command('NextDev', function()
  vim.cmd('!npm run dev')
end, { desc = 'Start Next.js development server' })

vim.api.nvim_create_user_command('NextLint', function()
  vim.cmd('!npm run lint')
end, { desc = 'Run Next.js linting' })

-- Export hook
return {
  setup = function()
    print("✅ Next.js LSP config loaded")
  end
}

