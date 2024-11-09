-- lua/plugins.lua

-- Initialize Packer
vim.cmd([[packadd packer.nvim]])

require('packer').startup(function(use)
  -- Packer itself
  use 'wbthomason/packer.nvim'

  -- Themes (OnedarkPro & TokyoNight)
  use 'olimorris/onedarkpro.nvim'
  use 'folke/tokyonight.nvim'

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
end)

