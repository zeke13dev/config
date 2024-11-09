-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/zeke/.cache/nvim/packer_hererocks/2.1.1713484068/share/lua/5.1/?.lua;/home/zeke/.cache/nvim/packer_hererocks/2.1.1713484068/share/lua/5.1/?/init.lua;/home/zeke/.cache/nvim/packer_hererocks/2.1.1713484068/lib/luarocks/rocks-5.1/?.lua;/home/zeke/.cache/nvim/packer_hererocks/2.1.1713484068/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/zeke/.cache/nvim/packer_hererocks/2.1.1713484068/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  catppuccin = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  ["duck.nvim"] = {
    config = { "\27LJ\2\n?\0\0\4\0\4\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0)\3\n\0B\0\3\1K\0\1\0\t🦆\nhatch\tduck\frequireE\0\0\4\0\4\1\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0*\3\0\0B\0\3\1K\0\1\0\t🐈\nhatch\tduck\frequire\1����\0031\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\tcook\tduck\frequire5\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\rcook_all\tduck\frequire�\1\1\0\6\0\f\0!6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0003\4\5\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\6\0003\4\a\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\b\0003\4\t\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\n\0003\4\v\0004\5\0\0B\0\5\1K\0\1\0\0\15<leader>da\0\15<leader>dk\0\15<leader>dc\0\15<leader>dd\6n\bset\vkeymap\bvim\0" },
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/duck.nvim",
    url = "https://github.com/tamton-aquib/duck.nvim"
  },
  nerdtree = {
    commands = { "NERDTreeToggle" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/opt/nerdtree",
    url = "https://github.com/preservim/nerdtree"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["onedarkpro.nvim"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/onedarkpro.nvim",
    url = "https://github.com/olimorris/onedarkpro.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["rust-tools.nvim"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/rust-tools.nvim",
    url = "https://github.com/simrat39/rust-tools.nvim"
  },
  ["sequoia-moonlight.nvim"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/sequoia-moonlight.nvim",
    url = "https://github.com/Hiroya-W/sequoia-moonlight.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["tokyonight.nvim"] = {
    loaded = true,
    path = "/home/zeke/.local/share/nvim/site/pack/packer/start/tokyonight.nvim",
    url = "https://github.com/folke/tokyonight.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: duck.nvim
time([[Config for duck.nvim]], true)
try_loadstring("\27LJ\2\n?\0\0\4\0\4\0\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0)\3\n\0B\0\3\1K\0\1\0\t🦆\nhatch\tduck\frequireE\0\0\4\0\4\1\b6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0*\3\0\0B\0\3\1K\0\1\0\t🐈\nhatch\tduck\frequire\1����\0031\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\tcook\tduck\frequire5\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\rcook_all\tduck\frequire�\1\1\0\6\0\f\0!6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0003\4\5\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\6\0003\4\a\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\b\0003\4\t\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\n\0003\4\v\0004\5\0\0B\0\5\1K\0\1\0\0\15<leader>da\0\15<leader>dk\0\15<leader>dc\0\15<leader>dd\6n\bset\vkeymap\bvim\0", "config", "duck.nvim")
time([[Config for duck.nvim]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.api.nvim_create_user_command, 'NERDTreeToggle', function(cmdargs)
          require('packer.load')({'nerdtree'}, { cmd = 'NERDTreeToggle', l1 = cmdargs.line1, l2 = cmdargs.line2, bang = cmdargs.bang, args = cmdargs.args, mods = cmdargs.mods }, _G.packer_plugins)
        end,
        {nargs = '*', range = true, bang = true, complete = function()
          require('packer.load')({'nerdtree'}, {}, _G.packer_plugins)
          return vim.fn.getcompletion('NERDTreeToggle ', 'cmdline')
      end})
time([[Defining lazy-load commands]], false)


_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
