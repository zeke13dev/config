-- better syntax highlighting
require('nvim-treesitter.configs').setup {
  ensure_installed = { "latex", "python", "rust", "lua", "c", "javascript",
    "typescript", 
    "tsx", 
    "html", 
    "css", 
    "json" 
},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Allowed theme configurations
local allowed_theme_prefixes = {
    "onedark", "tokyonight", "catppuccin",
    "everforest", "gruvbox", "nord", "solarized", "material", "kanagawa", "nightfox", "carbonfox", "duskfox"
}

-- List of specific blacklisted themes
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
        for _, prefix in ipairs(allowed_theme_prefixes) do
            if color:match("^" .. prefix) then
                is_allowed = true
                break
            end
        end
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

-- Shortcut for opening the allowed colorscheme list
vim.api.nvim_set_keymap('n', '<leader>cs', ':Theme ', { noremap = true, silent = false })

-- TokyoNight Configuration
vim.g.tokyonight_style = "storm"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = { "qf", "terminal" }

-- Ensure true color support
vim.o.termguicolors = true

vim.cmd([[colorscheme catppuccin-macchiato]])

-- Fix the cursor color
vim.cmd([[
  highlight! Cursor guifg=NONE guibg=#c792ea
]])

-- Use TokyoNight's diagnostic highlights for LSP
vim.fn.sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚠", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "ℹ", texthl = "DiagnosticInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "💡", texthl = "DiagnosticHint" })

-- Customize LSP hover window
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

-- Customize virtual text diagnostics (in-line text)
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
  },
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
})


local cat_position = 25
local cat_speed = 0.05 -- Fractional movement for smoother animation
local cat_direction = 1 -- 1 for right, -1 for left
local last_meow_time = 0 -- Track when the cat last meowed

-- Function to play a meow sound
local function play_meow()
  -- Check if we're in a GUI Neovim that supports system commands
  if vim.fn.has('gui_running') == 1 or vim.fn.has('nvim') == 1 then
    -- Different commands based on operating system
    local cmd = ""
    if vim.fn.has('mac') == 1 then
      -- macOS with your specific MP3 file
      -- cmd = "afplay /Users/zeke/.config/nvim/sounds/meow.mp3 &"
    elseif vim.fn.has('unix') == 1 then
      -- Linux (assumes you have 'aplay' and a sound file)
      cmd = "aplay ~/.config/nvim/sounds/meow.wav &>/dev/null &"
    elseif vim.fn.has('win32') == 1 then
      -- Windows
      cmd = "powershell -c (New-Object Media.SoundPlayer \"$env:USERPROFILE\\.config\\nvim\\sounds\\meow.wav\").PlaySync();"
    end
    
    -- Only try to play if we set a command
    if cmd ~= "" then
      vim.fn.system(cmd)
    end
  end
end

local function moving_cat()
  local line_width = vim.o.columns
  local left_width = 25  -- Approximate width of left section
  local right_width = 30 -- Approximate width of right section
  local track_width = line_width - (left_width + right_width)
  
  -- Ensure minimum track width
  if track_width < 20 then track_width = 20 end
  
  -- Randomly change direction every few seconds
  if math.random() < 0.02 then  -- 2% chance per frame to reverse direction
    cat_direction = -cat_direction
  end
  
  -- Move in the current direction
  local step = cat_speed * cat_direction
  cat_position = cat_position + step
  
  -- If cat hits the edges, reverse direction
  if cat_position <= 1 then
    cat_position = 1
    cat_direction = 1
  elseif cat_position >= track_width then
    cat_position = track_width
    cat_direction = -1
  end
  
  -- Random meowing logic
  local current_time = os.time()
  if current_time - last_meow_time > 10 then -- Only consider meowing after 10 seconds since last meow
    if math.random() < 0.005 then -- 0.5% chance per frame to meow (adjustable)
      play_meow()
      last_meow_time = current_time
    end
  end
  
  -- Convert fractional position to integer for rendering
  local cat_index = math.floor(cat_position)
  
  -- Generate empty track and insert cat
  local track = string.rep(" ", track_width)
  return track:sub(1, cat_index - 1) .. "🐈" .. track:sub(cat_index + 1)
end

require('lualine').setup {
  options = {
    theme = 'catppuccin',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    icons_enabled = true,
    refresh = {
      statusline = 50, -- Faster refresh for smoother animation
    }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { { 'filename', path = 1 }, 'diagnostics' },
    lualine_c = {
      { function() return moving_cat() end, padding = 0 },
    },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

-- Faster timer for smooth movement
local cat_timer = vim.loop.new_timer()
cat_timer:start(0, 10, vim.schedule_wrap(function() -- Updates every 10ms
  require("lualine").refresh()
  vim.cmd('redrawstatus')
end))

return {
    moving_cat = moving_cat,
    play_meow = play_meow -- Export the function in case you want to use it elsewhere
}
