-- Load individual configuration modules
require('settings')      -- Basic settings
require('plugins')       -- Plugin setup and installation
require('lsp')           -- LSP configuration
require('rust')    -- Rust-specific configurations
require('python')
require('sml')
require('c0')
require('theme')
require('latex')

-- Load custom functions (defines `Init` and `Bye` commands)
require('functions')

-- Load key mappings
require('mappings')

-- Automatically call Init on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    --vim.cmd('Init')
  end,
})

-- File: lua//c0.lua --

-- Create an autocommand to set filetype for .c0 and .c1 files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.c0", "*.c1" },
  callback = function()
    vim.bo.filetype = "c0_syntax"
  end,
})

-- Optionally print a message when the syntax file is loaded (for debugging)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c0_syntax",
  callback = function()
    print("Loaded c0_syntax for .c0/.c1 files")
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
local function init_environment_old()
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

local function init_environment()
  vim.cmd('split')
  vim.cmd('vsplit')
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

-- Resize splits using ctrl+shift+movement_key
vim.api.nvim_set_keymap('n', '<C-S-l>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-j>', ':resize +2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-k>', ':resize -2<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-S-h>', ':vertical resize +2<CR>', { noremap = true, silent = true })

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

-- silly ahh canada
vim.api.nvim_set_keymap('n', '<Leader>L', 'ithe mediocre province of British Columbia<Esc>', { noremap = true, silent = true })



-- File: lua//plugins.lua --

-- lua/plugins.lua


-- Initialize Packer
vim.cmd([[packadd packer.nvim]])

require('packer').startup(function(use)
  -- Packer itself
  use 'wbthomason/packer.nvim'

  -- Themes
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


-- File: lua//python.lua --

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
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" },
        diagnostics = {
          ignored = { ".cargo/**" }, -- Ignore `.cargo` directory
        },
      },
    },
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

      -- Add a new BufWritePre autocmd for synchronous formatting using rustfmt
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

-- File: lua//sml.lua --

local lspconfig = require('lspconfig')

lspconfig.millet.setup {
    cmd = { "millet-ls" },
    filetypes = { "sml" },
    -- Use current working directory when no project file is detected
    root_dir = function(fname)
        return lspconfig.util.root_pattern(".millet.toml", ".git")(fname) or vim.loop.cwd()
    end,
    on_attach = function(client, bufnr)
        print("Millet attached to buffer " .. bufnr)
    end,
}


-- File: lua//theme.lua --

-- better syntax highlighting
require('nvim-treesitter.configs').setup {
  ensure_installed = "all", -- use "all" for all languages or list specific languages
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- lua/theme.lua
local allowed_theme_prefixes = {
    "onedark", "tokyonight", "catppuccin",
    "everforest", "gruvbox", "nord", "solarized", "material", "kanagawa", "nightfox", "carbonfox", "duskfox"
}

-- List of specific blacklisted themes (variations you want to exclude)
local blacklisted_variations = {
    "onedark_dark", "tokyonight-day", "catppuccin-latte", "catppuccin", "catppuccin-mocha", "gruvbox-material", "tokyonight", "tokyonight-night", "tokyonight-moon",
    "material", "material-lighter", "material-oceanic", "kanagawa-lighter", "kanagawa-dragon"
}

-- Function to get only allowed colorschemes based on prefixes and blacklist
local function get_allowed_colorschemes()
    local colors = vim.fn.getcompletion('', 'color')
    local filtered_colors = {}
    for _, color in ipairs(colors) do
        local is_allowed = false
        -- Check if color matches any allowed prefix
        for _, prefix in ipairs(allowed_theme_prefixes) do
            if color:match("^" .. prefix) then
                is_allowed = true
                break
            end
        end
        -- Only add to filtered_colors if allowed and not blacklisted
        if is_allowed and not vim.tbl_contains(blacklisted_variations, color) then
            table.insert(filtered_colors, color)
        end
    end
    return filtered_colors
end

-- Redefine the colorscheme command with completion
vim.api.nvim_create_user_command('Theme', function(args)
    vim.cmd('colorscheme ' .. args.args)
    vim.cmd('highlight! Cursor guifg=NONE guibg=#c792ea')
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

-- Load the Material Palenight colorscheme
vim.cmd([[colorscheme carbonfox]])

-- Fix the cursor color
vim.cmd([[
  highlight! Cursor guifg=NONE guibg=#c792ea
]])

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

