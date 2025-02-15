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
end, {})

require('lspconfig').texlab.setup({
    settings = {
        texlab = {
            build = {
                executable = "latexmk",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = true,
            },
            forwardSearch = {
                executable = "zathura",
                args = { "--synctex-forward", "%l:1:%f", "%p" },
            },
        },
    },
})

-- Enable line wrapping for LaTeX files
vim.cmd([[
  augroup LaTeXLineWrap
    autocmd!
    autocmd FileType tex setlocal wrap
  augroup END
]])


