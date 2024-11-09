-- lua/plugins.lua

-- Initialize Packer
vim.cmd([[packadd packer.nvim]])

require('packer').startup(function(use)
  -- Packer itself
  use 'wbthomason/packer.nvim'

  -- Themes
  use 'olimorris/onedarkpro.nvim'
  use 'folke/tokyonight.nvim'
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'Hiroya-W/sequoia-moonlight.nvim'

  -- Telescope for fuzzy finding
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }

  -- NerdTree
  use 'preservim/nerdtree'

  -- LSP configurations and Rust tools
  use 'neovim/nvim-lspconfig'
  use 'simrat39/rust-tools.nvim'
  use 'lervag/vimtex'

  -- DUCKIES
  use {
    'tamton-aquib/duck.nvim',
    config = function()
        vim.keymap.set('n', '<leader>dd', function() require("duck").hatch("🦆", 10) end, {}) -- Fast duck
        vim.keymap.set('n', '<leader>dc', function() require("duck").hatch("🐈", 0.75) end, {}) -- Mellow cat
        vim.keymap.set('n', '<leader>dk', function() require("duck").cook() end, {})
        vim.keymap.set('n', '<leader>da', function() require("duck").cook_all() end, {})
    end
  }
end)

