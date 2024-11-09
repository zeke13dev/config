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

