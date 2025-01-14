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

