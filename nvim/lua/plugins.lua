require("lazy").setup({

  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup{
        open_mapping = [[<leader>t]],  -- Open with <leader>t
        direction = "float",           -- Use floating window for terminal
        shade_terminals = true,        -- Dim background for better visibility
        start_in_insert = true,        -- Start terminal in insert mode
        shell = vim.o.shell,           -- Use system default shell
      }
    end,
  },

  -- UI Enhancements
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Markdown + LaTeX Preview
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_auto_start = 1 -- Auto-start preview when opening a Markdown file
      vim.g.mkdp_browser = "firefox" -- Change this to your preferred browser
    end,
  },

  -- Themes
  "lewis6991/impatient.nvim",
  "folke/trouble.nvim",
  "folke/tokyonight.nvim",
  { "catppuccin/nvim", name = "catppuccin" },
  "marko-cerovac/material.nvim",
  "rebelot/kanagawa.nvim",
  "navarasu/onedark.nvim",
  "EdenEast/nightfox.nvim",

  -- Syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Telescope (fuzzy finder)
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- File navigation
  "preservim/nerdtree",

  -- LSP & Rust tools
  "neovim/nvim-lspconfig",
  "simrat39/rust-tools.nvim",

  -- LaTeX support
  "lervag/vimtex",

  -- Crate management for Rust
  {
    "saecki/crates.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("crates").setup() end,
  },

  -- DUCKIES 🦆
  {
    "tamton-aquib/duck.nvim",
    config = function()
      vim.keymap.set("n", "<leader>dd", function() require("duck").hatch("🦆", 10) end, {}) -- Fast duck
      vim.keymap.set("n", "<leader>dc", function() require("duck").hatch("🐈", 0.75) end, {}) -- Mellow cat
      vim.keymap.set("n", "<leader>dk", function() require("duck").cook() end, {})
      vim.keymap.set("n", "<leader>da", function() require("duck").cook_all() end, {})
    end,
  },

})
