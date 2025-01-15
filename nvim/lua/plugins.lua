-- lua/plugins.lua


-- Initialize Packer
vim.cmd([[packadd packer.nvim]])

require('packer').startup(function(use)
  -- Packer itself
  use 'wbthomason/packer.nvim'

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }


  -- Themes
  use 'lewis6991/impatient.nvim'
  use 'folke/trouble.nvim'
  use 'folke/tokyonight.nvim'
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'marko-cerovac/material.nvim'
  use 'rebelot/kanagawa.nvim'
  use 'navarasu/onedark.nvim'
  use "EdenEast/nightfox.nvim"

  use 'nvim-treesitter/nvim-treesitter'

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

  use {
  'saecki/crates.nvim',
  requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('crates').setup()
  end,
}

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

