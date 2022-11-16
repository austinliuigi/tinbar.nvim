local utils = require("tinbar.utils")

local M = {}

-- Relevant winbar colors
M.colors = function()
  return {
  left_bg   = nil,
  center_bg = utils.get_hl("Comment", "foreground"),
  right_bg   = nil,
  }
end

-- @param components table {}
M.set_highlights = function(components, background)
  for _, component in ipairs(components) do
    if string.find(component.highlight.name, "DevIcon") ~= nil then
      for _, icon_table in pairs(require("nvim-web-devicons").get_icons()) do
        vim.api.nvim_set_hl(0, "WinBarDevIcon".. icon_table.name, { fg = icon_table.color, bg = background })
      end

    -- Define a highlight group for component if attributes field is non-nil
    elseif component.highlight.attributes ~= nil then
      -- Use section's background if one was not specified for component
      local attributes = vim.tbl_deep_extend('keep', component.highlight.attributes, { bg = background })
      -- Swap fg and bg values in specified (for borders)
      if component.highlight.reverse == true then
        local prev_fg = attributes.fg
        attributes.fg = attributes.bg
        attributes.bg = prev_fg
      end
      vim.api.nvim_set_hl(0, component.highlight.name, attributes)
    end
  end
end

return M
