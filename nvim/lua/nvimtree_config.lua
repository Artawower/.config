local g = vim.g

require "nvim-tree".setup {
    disable_netrw = true,
    hijack_netrw = true,
    -- auto_close = false,
    open_on_tab = true,
    hijack_cursor = false,
    update_cwd = false,
    -- update_to_buf_dir = {
    --     enable = true,
    --     auto_open = true
    -- },
    -- icons = {
    --   folder = {
    --     arrow_open = "▼",
    --     arrow_close = "🠺"
    --   }
    -- },
    diagnostics = {
        enable = false,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = ""
        }
    },
    update_focused_file = {
        enable = true,
        update_cwd = true,
        update_cwd = false,
        ignore_list = {}
    },
    system_open = {
        cmd = nil,
        args = {}
    },
    filters = {
        dotfiles = false,
        custom = {}
    },
    git = {
        enable = true,
        ignore = true,
        timeout = 500
    },
    trash = {
        cmd = "trash",
        require_confirm = true
    },

    sync_root_with_cwd = true,
    respect_buf_cwd = true
}

g.nvim_tree_icons = {
     default = '',
     symlink = '',
     git = {
       unstaged = "✗",
       staged = "✓",
       unmerged = "",
       renamed =  "➜",
       untracked = "★",
       deleted = "",
       ignored = "◌"
       },
     folder =  {
       arrow_open = "",
       arrow_closed = "",
       default = "",
       open = "",
       empty = "",
       empty_open = "",
       symlink = "",
       symlink_open = "",
       }
     }

local wk = require("which-key")

wk.register(
    {
        o = {
            name = "file tree",
            p = {":NvimTreeToggle<CR>", "Toggle file tree"},
            P = {":NvimTreeFindFile<CR>", "Focus current file", noremap = true}
        },
        ["."] = {
            ":RangerCurrentDirectory<CR>",
            "Open current directory"
        },
        [","] = {
            ":RangerWorkingDirectory<CR>",
            "Open working directory"
        }
    },
    {prefix = "<space>"}
)
