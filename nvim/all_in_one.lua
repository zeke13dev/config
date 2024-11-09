-- Load individual configuration modules
require('settings')      -- Basic settings
require('plugins')       -- Plugin setup and installation
require('lsp')           -- LSP configuration
require('rust')    -- Rust-specific configurations
require('theme')
require('latex')

-- Load custom functions (defines `Init` and `Bye` commands)
require('functions')

-- Load key mappings
require('mappings')

-- Automatically call Init on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd('Init')
  end,
})

-- File: lua//functions.lua --

-- lua/functions.lua

-- Toggle diagnostic float
local diagnostic_open = false  -- Track if the float is open

local function ToggleDiagnosticFloat()
  if diagnostic_open then
    vim.cmd('echo')  -- Clear the message and close the float
    diagnostic_open = false
  else
    vim.diagnostic.open_float(nil, { focusable = true, border = "rounded" })
    diagnostic_open = true
  end
end

-- Initialize environment function
local function init_environment()
  vim.cmd('NERDTreeToggle')
  vim.cmd('wincmd h')
  vim.cmd('vertical resize 20')
  vim.cmd('wincmd l')
  vim.cmd('split')
  vim.cmd('wincmd j')
  vim.cmd('terminal')
  vim.cmd('resize 8')
  vim.cmd('wincmd k')
end

-- Custom quit command to close terminals and exit Neovim
local function bye()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      local job_id = vim.b[buf].terminal_job_id
      if job_id then
        vim.fn.jobstop(job_id)  -- Gracefully stop terminal job
      end
      vim.cmd('bdelete! ' .. buf)  -- Close terminal buffer
    end
  end
  vim.cmd('wqa')  -- Save and quit all files
end

-- Register custom commands
vim.api.nvim_create_user_command('Init', init_environment, {})
vim.api.nvim_create_user_command('Bye', bye, {})

-- Export functions for use in other files
return {
  init_environment = init_environment,
  bye = bye,
  ToggleDiagnosticFloat = ToggleDiagnosticFloat,
}


-- File: lua//latex.lua --

vim.api.nvim_create_user_command('TexSplitCompile', function()
  -- Step 1: Compile the current LaTeX file
  local current_file = vim.fn.expand('%:p')
  local compile_cmd = 'latexmk -pdf -silent ' .. current_file
  vim.fn.system(compile_cmd)
  print("Compiled " .. current_file)
  
  -- Step 2: Open Zathura if not running
  local zathura_running = vim.fn.system("pgrep -x zathura")
  if zathura_running == "" then
    local pdf_path = current_file:gsub("%.tex", ".pdf")
    local open_pdf_cmd = "zathura " .. pdf_path .. " &"
    vim.fn.system(open_pdf_cmd)
    print("Opening Zathura with " .. pdf_path)
  else
    print("Zathura is already running.")
  end

  -- Step 3: Use Yabai to tile the windows
  vim.fn.system("yabai -m window --focus $(pgrep -x zathura)")
  vim.fn.system("yabai -m window --display 1 --space 1")
  vim.fn.system("yabai -m window --focus $(pgrep -x nvim)")
  vim.fn.system("yabai -m window --display 1 --space 2")

end, {})


-- File: lua//lsp.lua --

-- Basic LSP setup
require('lspconfig').rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
    }
  },
  on_attach = function(_, bufnr)
    local opts = { noremap=true, silent=true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  end
})


-- File: lua//mappings.lua --

-- lua/mappings.lua

local funcs = require('functions')

-- Set leader key to space
vim.g.mapleader = " "

-- Keybinding for Init environment setup
vim.api.nvim_set_keymap('n', '<C-i>', ':Init<CR>', { noremap = true, silent = true })

-- Keybinding for Bye command to quit Neovim gracefully
vim.api.nvim_set_keymap('n', '<leader>q', ':Bye<CR>', { noremap = true, silent = true })

-- NerdTree keybindings
vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-b>', ':NERDTreeFocus<CR>', { noremap = true, silent = true })

-- Move between splits using HJKL
vim.api.nvim_set_keymap('n', 'H', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'J', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'L', '<C-w>l', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<C-H>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-J>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-K>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-L>', ':vertical resize +2<CR>', { noremap = true, silent = true })

-- Remap Esc in terminal mode to normal mode
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Toggle diagnostic float with <leader>e
vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua ToggleDiagnosticFloat()<CR>', { noremap = true, silent = true })

-- Open Telescope diagnostics with <leader>-
vim.api.nvim_set_keymap('n', '<leader>-', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>k', function()
  vim.diagnostic.open_float(nil, {scope = "line"})
end, { noremap = true, silent = true })


-- Use Telescope to show diagnostics in a floating popup
vim.api.nvim_set_keymap('n', '<leader>e', '<Cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })

-- Use Telescope to show diagnostics filtered by buffer in a split
vim.api.nvim_set_keymap('n', '<leader>E', '<Cmd>Telescope diagnostics bufnr=0<CR>', { noremap = true, silent = true })


-- File: lua//plugins.lua --

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


-- File: lua//rust.lua --

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


-- File: lua//settings.lua --

-- General settings
vim.o.termguicolors = true  -- Enable true color support
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Enable line numbers and cursor line
vim.wo.number = true
vim.o.cursorline = true

-- Disable text wrapping
vim.o.wrap = false

-- Use system clipboard
vim.o.clipboard = 'unnamedplus'

-- File: lua//theme.lua --

-- lua/theme.lua

-- List of allowed themes
local allowed_themes = {
    "onedark", "tokyonight", "tokyonight-storm"
}

-- Function to get only allowed colorschemes
local function get_allowed_colorschemes()
    local colors = vim.fn.getcompletion('', 'color')
    local filtered_colors = {}
    for _, color in ipairs(colors) do
        if vim.tbl_contains(allowed_themes, color) then
            table.insert(filtered_colors, color)
        end
    end
    return filtered_colors
end

-- Redefine the colorscheme command with completion
vim.api.nvim_create_user_command('Theme', function(args)
    vim.cmd('colorscheme ' .. args.args)
end, {
    nargs = 1,
    complete = function()
        return get_allowed_colorschemes()
    end
})

-- Optional: Shortcut for opening the allowed colorscheme list
vim.api.nvim_set_keymap('n', '<leader>cs', ':Theme ', { noremap = true, silent = false })

-- TokyoNight Configuration
vim.g.tokyonight_style = "storm"  -- Choose the storm style
vim.g.tokyonight_italic_functions = true  -- Make functions italic
vim.g.tokyonight_sidebars = { "qf", "terminal" }  -- Sidebar settings

-- Ensure true color support
vim.o.termguicolors = true

-- Load the TokyoNight colorscheme
vim.cmd([[colorscheme tokyonight]])

-- Use TokyoNight's diagnostic highlights for LSP
vim.fn.sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚠", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticHint" })

-- Optional: Customize how the LSP hover window looks
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",  -- Adds a rounded border to the hover window
})

-- Optional: Customize virtual text diagnostics (in-line text)
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",  -- Could be ❗, ●, or ▸ based on your preference
    spacing = 4,
  },
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
})

