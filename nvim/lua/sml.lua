--[[
local configs = require('lspconfig.configs')
local lspconfig = require('lspconfig')

if not configs.millet_ls then
  configs.millet_ls = {
    default_config = {
      cmd = { "millet-ls" },
      filetypes = { "sml" },
      root_dir = lspconfig.util.root_pattern("millet.toml", ".git", "."),
      single_file_support = true,
      on_attach = function(client, bufnr)
        print("Millet LSP attached to buffer " .. bufnr)
      end,
    },
  }
end

lspconfig.millet_ls.setup({})
--]]
