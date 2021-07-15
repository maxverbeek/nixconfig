local gl = require("galaxyline")
local gls = gl.section

gl.short_line_list = {" "} -- keeping this table { } as empty will show inactive statuslines

local ayucolors = require'ayu.colors'

--  accent = "#FFCC66",
--  bg = "#1F2430",
--  black = "#000000",
--  comment = "#5C6773",
--  constant = "#D4BFFF",
--  entity = "#73D0FF",
--  error = "#FF3333",
--  fg = "#CBCCC6",
--  fg_idle = "#607080",
--  func = "#FFD580",
--  guide_active = "#576070",
--  guide_normal = "#383E4C",
--  gutter_active = "#5F687A",
--  gutter_normal = "#404755",
--  keyword = "#FFA759",
--  line = "#191E2A",
--  markup = "#F28779",
--  operator = "#F29E74",
--  panel_bg = "#232834",
--  panel_border = "#101521",
--  panel_shadow = "#141925",
--  regexp = "#95E6CB",
--  selection_bg = "#33415E",
--  selection_border = "#232A4C",
--  selection_inactive = "#323A4C",
--  special = "#FFE6B3",
--  string = "#BAE67E",
--  tag = "#5CCFE6",
--  ui = "#707A8C",
--  vcs_added = "#A6CC70",
--  vcs_added_bg = "#313D37",
--  vcs_diff_text = "#465742",
--  vcs_modified = "#77A8D9",
--  vcs_modified_bg = "#323A4C",
--  vcs_removed = "#F27983",
--  vcs_removed_bg = "#3E373A",
--  warning = "#FFA759",
--  white = "#FFFFFF"

-- local colors = {
--   bg = "#2e303e",
--   line_bg = "#2e303e",
--   fg = "#e3e6ee",
--   green = "#29d398",
--   orange = "#efb993",
--   red = "#e95678",
--   lightbg = "#2e303e",
--   lightbasdfg = "#393b4d",
--   nord = "#9699b7",
--   greenYel = "#efb993"
-- }

local colors = {
    bg = ayucolors.bg,
    line_bg = ayucolors.bg,
    fg = ayucolors.fg,
    green = ayucolors.string,
    orange = ayucolors.warning,
    red = ayucolors.vcs_removed,
    yellow = ayucolors.accent,
    lightbg = ayucolors.bg,
    nord = ayucolors.constant,
    greenYel = ayucolors.vcs_added,
}

gls.left[1] = {
    leftRounded = {
        provider = function()
            return " "
        end,
        highlight = {colors.nord, colors.bg}
    }
}

gls.left[2] = {
    statusIcon = {
        provider = function()
            return "  "
        end,
        highlight = {colors.fg, colors.bg},
        separator = " ",
        separator_highlight = {colors.lightbg, colors.lightbg}
    }
}

gls.left[3] = {
    FileIcon = {
        provider = "FileIcon",
        condition = buffer_not_empty,
        highlight = {require("galaxyline.provider_fileinfo").get_file_icon_color, colors.lightbg}
    }
}

gls.left[4] = {
    FileName = {
        provider = {"FileName", "FileSize"},
        condition = buffer_not_empty,
        highlight = {colors.fg, colors.lightbg},
        separator = " ",
        separator_highlight = {colors.line_bg, colors.line_bg}
    }
}

gls.left[5] = {
    teech = {
        provider = function()
            return " "
        end,
        separator = " ",
        highlight = {colors.lightbg, colors.bg}
    }
}

local checkwidth = function()
    local squeeze_width = vim.fn.winwidth(0) / 2
    if squeeze_width > 40 then
        return true
    end
    return false
end

gls.left[6] = {
    DiffAdd = {
        provider = "DiffAdd",
        condition = checkwidth,
        icon = "   ",
        highlight = {colors.greenYel, colors.line_bg}
    }
}

gls.left[7] = {
    DiffModified = {
        provider = "DiffModified",
        condition = checkwidth,
        icon = " ",
        highlight = {colors.orange, colors.line_bg}
    }
}

gls.left[8] = {
    DiffRemove = {
        provider = "DiffRemove",
        condition = checkwidth,
        icon = " ",
        highlight = {colors.red, colors.line_bg}
    }
}

gls.left[9] = {
    LeftEnd = {
        provider = function()
            return " "
        end,
        separator = " ",
        separator_highlight = {colors.line_bg, colors.line_bg},
        highlight = {colors.line_bg, colors.line_bg}
    }
}

gls.left[10] = {
    DiagnosticError = {
        provider = "DiagnosticError",
        icon = "  ",
        highlight = {colors.orange, colors.bg}
    }
}

gls.left[11] = {
    Space = {
        provider = function()
            return " "
        end,
        highlight = {colors.line_bg, colors.line_bg}
    }
}

gls.left[12] = {
    DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "  ",
        highlight = {colors.yellow, colors.bg}
    }
}

gls.right[1] = {
    GitIcon = {
        provider = function()
            return "   "
        end,
        condition = require("galaxyline.provider_vcs").check_git_workspace,
        highlight = {colors.green, colors.line_bg}
    }
}

gls.right[2] = {
    GitBranch = {
        provider = "GitBranch",
        condition = require("galaxyline.provider_vcs").check_git_workspace,
        highlight = {colors.green, colors.line_bg}
    }
}

gls.right[3] = {
    right_LeftRounded = {
        provider = function()
            return " " 
        end,
        separator = " ",
        separator_highlight = {colors.bg, colors.bg},
        highlight = {colors.lightbg, colors.bg}
    }
}

gls.right[4] = {
    ViMode = {
        provider = function()
            local alias = {
                n = "NORMAL",
                i = "INSERT",
                c = "COMMAND",
                V = "VISUAL",
                [""] = "VISUAL",
                v = "VISUAL",
                R = "REPLACE"
            }
            return alias[vim.fn.mode()]
        end,
        highlight = {colors.fg, colors.lightbg}
    }
}

gls.right[5] = {
    PerCent = {
        provider = "LinePercent",
        separator = " ",
        separator_highlight = {colors.lightbg, colors.lightbg},
        highlight = {colors.fg, colors.lightbg}
    }
}

gls.right[6] = {
    rightRounded = {
        provider = function()
            return " "
        end,
        highlight = {colors.lightbg, colors.bg}
    }
}
