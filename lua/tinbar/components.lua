local utils = require("tinbar.utils")

local M = {}

M.should_truncate = function(_, trunc_width)
  local current_width = vim.api.nvim_win_get_width(0)
  return current_width < trunc_width
end

-- Shroom icon
M.get_shroom = function()
  return {
    text = "ﳞ",
    length = vim.fn.strchars("ﳞ"),
    highlight = {
      name = "WinBarShroom",
      attributes = {
        fg = utils.get_hl("Function", "foreground"),
      },
    },
  }
end

-- Devicon corresponding to buffer
M.get_devicon = function()
  local filename, fileext = vim.fn.expand("%:t"), vim.fn.expand("%:e")
  local icon, group = require("nvim-web-devicons").get_icon(filename, fileext, { default = true })

  return {
    text      = icon,
    length    = vim.fn.strchars(icon),
    highlight = {
      name = "WinBar" .. group,
      attributes = nil,
    },
  }
end

-- Tail, relative, or active filepath of buffer
M.get_filepath = function()
  local filepaths = { tail = "%t", rel = "%f", abs = "%F" }
  local filepath = filepaths[require("tinbar").config.filepath_type] or "%t"

  return {
    text      = filepath,
    length    = vim.fn.strchars(filepath),
    highlight = {
      name = "WinBarFilepath",
      attributes = {
        fg = utils.get_hl("Normal", "foreground"),
      },
    },
  }
end

-- Readonly indicator
M.get_readonly = function()
  local is_readonly = vim.opt.readonly:get()
  local readonly_text = is_readonly and " " or ""

  return {
    text      = readonly_text,
    length    = vim.fn.strchars(readonly_text),
    highlight = {
      name = "WinBarReadonly",
      attributes = {
        fg = "lightblue",
      }
    },
  }
end

-- Modified indicator
M.get_modified = function()
  local is_modified = vim.opt.modified:get()
  local modified_text = is_modified and " ●" or ""

  return {
    text      = modified_text,
    length    = vim.fn.strchars(modified_text),
    highlight = {
      name = "WinBarModified",
      attributes = {
        fg = "lightpink",
      },
    },
  }
end

-- Treesitter code context
M.get_navic = function()
  local max_chars = ((vim.api.nvim_win_get_width(0)/2)-(require("tinbar").center_length()/2))*3/4
  if max_chars < 0 then max_chars = 0 end

  local code_context = require("nvim-navic").get_location()                  -- Note: includes statusline/winbar highlighting
  local code_context_underwear = string.gsub(code_context, "%%%#.-%#", "")   -- Remove any highlight codes (e.g. %#Group#)
  local code_context_naked = string.gsub(code_context_underwear, "%%%*", "") -- Remove any default highlight codes (%*)

  local ellipsis = "%#NavicText#.."
  while vim.fn.strchars(code_context_naked) > max_chars do
    local next_section, _ = string.find(code_context, "%%%#NavicSeparator%#", string.len(ellipsis)+2)
    if next_section ~= nil then
      code_context = ellipsis .. string.sub(code_context, next_section, -1)
    else
      code_context = ""
    end
    code_context_underwear = string.gsub(code_context, "%%%#.-%#", "")
    code_context_naked = string.gsub(code_context_underwear, "%%%*", "")
  end

  return {
    text      = code_context,
    length    = vim.fn.strchars(code_context_naked),
    highlight = {
      name = "",
      attributes = nil,
    }
  }
end

-- Space character for separating center components
M.get_center_space = function()
  return {
    text      = " ",
    length    = 1,
    highlight = {
      name = "WinBarCenterSpace",
      attributes = {
      },
    },
  }
end



--[[ Edges ]]

M.get_leftside_left_edge = function()
  local icon =  ""

  return {
    text = icon,
    length = vim.fn.strchars(icon),
    highlight = {
      name = "WinBarLeftsideLeftEdge",
      attributes = {
      },
      reverse = true,
    },
  }
end

M.get_leftside_right_edge = function()
  local icon = ""

  return {
    text = icon,
    length = vim.fn.strchars(icon),
    highlight = {
      name = "WinBarLeftsideRightEdge",
      attributes = {
      },
      reverse = true,
    },
  }
end

-- Left edge/border of center components
M.get_centerside_left_edge = function()
  local icon =  ""

  return {
    text      = icon,
    length    = vim.fn.strchars(icon),
    highlight = {
      name = "WinBarCentersideLeftEdge",
      attributes = {
      },
      reverse = true
    },
  }
end

-- Right edge/border of center components
M.get_centerside_right_edge = function()
  local icon =  ""

  return {
    text      = icon,
    length    = vim.fn.strchars(icon),
    highlight = {
      name = "WinBarCentersideRightEdge",
      attributes = {
      },
      reverse = true,
    },
  }
end

-- M.get_showcmd = function()
--   local noice_statusline = require("noice").api.status
--   local showcmd = noice_statusline.command.has() and noice_statusline.command.get() or ""
--
--   return {
--     text = showcmd,
--     length = vim.fn.strchars(showcmd),
--     highlight = {
--       name = "WinBarShowcmd",
--       attributes = {
--         foreground = utils.get_hl("Comment", "foreground"),
--         bold = true,
--         italic = true,
--       },
--     },
--   }
-- end

-- M.get_macro_msg = function()
--   local noice_statusline = require("noice").api.status
--   local macro_msg = noice_statusline.mode.has() and "  " ..noice_statusline.mode.get() or ""
--
--   return {
--     text = macro_msg,
--     length = vim.fn.strchars(macro_msg),
--     highlight = {
--       name = "WinBarMacroMsg",
--       attributes = {
--         foreground = utils.get_hl("Comment", "foreground"),
--         italic = true,
--       },
--     },
--   }
-- end



--[[ Padding ]]

-- Padding between left screen edge and leftmost component
M.get_left_padding = function()
  return {
    text = " ",
    length = 1,
    highlight = {
      name = "Normal",
      attributes = nil,
    },
  }
end

-- Padding between right screen edge and rightmost component
M.get_right_padding = function()
  return {
    text = " ",
    length = 1,
    highlight = {
      name = "Normal",
      attributes = nil,
    },
  }
end

-- Padding to keep the center components static
M.get_left_center_padding = function()
  return {
    text = string.rep(" ", require("tinbar").right_length()),
    highlight = {
      name = "Normal",
      attributes = nil,
    },
  }
end

-- Padding to keep the center components static
M.get_right_center_padding = function()
  return {
    text = string.rep(" ", require("tinbar").left_length()),
    highlight = {
      name = "Normal",
      attributes = nil,
    },
  }
end

return M
