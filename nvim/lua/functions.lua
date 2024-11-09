-- lua/functions.lua

local function ToggleDiagnosticFloat()
  if vim.diagnostic.is_open() then
    vim.cmd('echo')  -- Close float by clearing message
  else
    vim.diagnostic.open_float(nil, { focusable = true, border = "rounded" })
  end
end

-- Initialize environment function
local function init_environment()
  vim.cmd('colorscheme tokyonight-storm')
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

