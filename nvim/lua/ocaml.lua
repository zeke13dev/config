return {
  -- OCaml LSP setup
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Initialize Mason and ensure ocamllsp is installed
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "ocamllsp" },
      })

      -- Basic LSP setup for ocamllsp
      local lspconfig = require("lspconfig")
      lspconfig.ocamllsp.setup({
        cmd = { vim.fn.expand("~/.opam/5.1.1/bin/ocamllsp") }, -- adjust to your switch
      })

      -- Enable inline diagnostics
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },

  -- Treesitter syntax highlighting for OCaml
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "ocaml",
        "ocaml_interface",
      },
    },
  },
}

