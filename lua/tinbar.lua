local components = require("tinbar.components")
local highlights = require("tinbar.highlights")

local tinbar = {}

-- Set winbar highlights after changing colorschemes
vim.api.nvim_create_augroup("WinbarHighlights", {clear = true})
vim.api.nvim_create_autocmd("ColorScheme", {
  group   = "WinbarHighlights",
  pattern = {'*'},
  callback = function()
    highlights.set_highlights(tinbar.left_components(), highlights.colors().left_bg)
    highlights.set_highlights(tinbar.center_components(), highlights.colors().center_bg)
    highlights.set_highlights(tinbar.right_components(), highlights.colors().right_bg)
  end,
})

tinbar.config = {
  trunc_width     = 80,
  filepath_type   = "tail", -- "tail" | "rel" | "abs"
}

tinbar.toggle_filepath_type = function(self)
  local next_type = {
    tail = "rel",
    rel = "abs",
    abs = "tail",
  }
  self.config.filepath_type = next_type[self.config.filepath_type]
end

tinbar.left_components = function()
  return {
    components.get_left_padding(),
    components.get_showcmd(),
    components.get_macro_msg(),
    components.get_left_padding(),
  }
end

tinbar.left_center_padding = function()
  return {
    components.get_left_center_padding(),
  }
end

tinbar.center_components = function()
  return {
    components.get_centerside_left_edge(),
    components.get_devicon(),
    components.get_center_space(),
    components.get_filepath(),
    components.get_readonly(),
    components.get_modified(),
    components.get_centerside_right_edge(),
  }
end

tinbar.right_center_padding = function()
  return {
    components.get_right_center_padding(),
  }
end

tinbar.right_components = function()
  return {
    components.get_navic(),
    components.get_right_padding(),
  }
end

-- Length of left components (used to calculate right_center_padding)
tinbar.left_length = function()
  local sum = 0
  for _, component in ipairs(tinbar.left_components()) do
    sum = sum + component.length
  end
  return sum
end

-- Length of center components (used to calculate navic length)
tinbar.center_length = function()
  local sum = 0
  for _, component in ipairs(tinbar.center_components()) do
    sum = sum + component.length
  end
  return sum
end

-- Length of right components (used to calculate left_center_padding)
tinbar.right_length = function()
  local sum = 0
  for _, component in ipairs(tinbar.right_components()) do
    sum = sum + component.length
  end
  return sum
end



--[[ Set winbar options ]]

-- Return winbar expression for active winbar
tinbar.set_active = function()
  local tinbar_text = {}

  local sections = {
    tinbar.left_components(),
    tinbar.left_center_padding(),
    tinbar.center_components(),
    tinbar.right_center_padding(),
    tinbar.right_components()
  }
  for index, section in ipairs(sections) do
    for _, component in ipairs(section) do
      table.insert(tinbar_text, "%#" .. component.highlight.name .. "#" .. component.text)
    end
    -- Insert separator after first and before last sections
    local separator_locations = { [1] = true, [#sections-1] = true }
    if separator_locations[index] ~= nil then
      table.insert(tinbar_text, "%=")
    end
  end

  return table.concat(tinbar_text)
end

-- Return winbar expression for inactive winbar
tinbar.set_inactive = function()
  local tinbar_text = {}

  local sections = {
    tinbar.left_components(),
    tinbar.left_center_padding(),
    tinbar.center_components(),
    tinbar.right_center_padding(),
    tinbar.right_components()
  }
  for index, section in ipairs(sections) do
    for _, component in ipairs(section) do
      table.insert(tinbar_text, "%#" .. component.highlight.name .. "#" .. component.text)
    end
    -- Insert separator after first and before last sections
    local separator_locations = { [1] = true, [#sections-1] = true }
    if separator_locations[index] ~= nil then
      table.insert(tinbar_text, "%=")
    end
  end

  return table.concat(tinbar_text)
end

-- Metatable to set winbar option
Winbar = setmetatable(tinbar, {
  __call = function(winbar, mode)
    --[[ if vim.api.nvim_win_get_config(0).zindex then return "" end -- Disable winbar for floating windows ]] -- https://github.com/neovim/neovim/issues/18660
    if mode == "active" then return winbar:set_active() end
    if mode == "inactive" then return winbar:set_inactive() end
  end
})


-- Autocommands to set winbar options
vim.api.nvim_create_augroup("Winbar", {clear = true})
vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group   = "Winbar",
  pattern = {'*'},
  command = "if has_key(v:lua.vim.api.nvim_win_get_config(0), 'zindex') | setlocal winbar= | else | setlocal winbar=%{%v:lua.Winbar('active')%} | endif"
  --[[ command = "setlocal winbar=%{%v:lua.Winbar('active')%}" ]] -- https://github.com/neovim/neovim/issues/18660
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group   = "Winbar",
  pattern = {'*'},
  command = "if has_key(v:lua.vim.api.nvim_win_get_config(0), 'zindex') | setlocal winbar= | else | silent! setlocal winbar=%{%v:lua.Winbar('inactive')%} | endif" -- silent! needed to suppress unusual error when entering dressing.nvim window
  --[[ command = "setlocal winbar=%{%v:lua.Winbar('inactive')%}" ]] -- https://github.com/neovim/neovim/issues/18660
})

return tinbar
