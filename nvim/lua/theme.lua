-- better syntax highlighting
require('nvim-treesitter.configs').setup {
  ensure_installed = { "latex", "python", "rust", "lua", "c" }, -- Use a table for specific languages
  highlight = {
    enable = true, -- Enable highlighting
    additional_vim_regex_highlighting = false, -- Disable additional Vim regex highlighting
  },
}

-- A variable to track the cat's current position
local cat_position = 0

local function moving_cat()
  local width = vim.o.columns
  -- Increment position, reset if it exceeds the screen width
  cat_position = (cat_position + 1) % width
  local spaces = string.rep(" ", cat_position) -- Add spaces to move the cat
  return spaces .. "🐈" -- Return the cat at the new position
end

-- bottom bar
require('lualine').setup {
  options = {
    theme = 'carbonfox', -- Match with your colorscheme
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    icons_enabled = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = {
      moving_cat, -- Add the cat here
      'encoding',
      'fileformat',
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

vim.loop.new_timer():start(0, 100, vim.schedule_wrap(function()
  vim.cmd('redrawstatus')
end))

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

