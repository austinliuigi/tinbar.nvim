local M = {}

-- Return highlight attribute of a specified group
-- @param group highlight group name
-- @param attribute attribute to target
-- @return string hex code
M.get_hl = function (group, attribute)
  return string.format("#%06x", vim.api.nvim_get_hl_by_name(group, true)[attribute])
end

return M
