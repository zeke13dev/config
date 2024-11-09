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

