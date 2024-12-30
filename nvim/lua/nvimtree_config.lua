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

wk.add({
    { "<space>", group = "completion" },
    { "<space>'", ":Telescope resume<CR>", desc = "Resume last session" },
    { "<space>*", ":Telescope grep_string<CR>", desc = "Search word under cursor" },
    { "<space>/", ":Telescope live_grep<CR>", desc = "Search project" },
    { "<space><space>", ":Telescope find_files<CR>", desc = "Find Files" },
    { "<space>bb", ":Telescope buffers<CR>", desc = "Open buffer" },
    { "<space>f", group = "Files" },
    { "<space>fr", ":Telescope oldfiles<CR>", desc = "Open old files" },
    { "<space>p", ":lua require'telescope'.extensions.projects.projects{}<CR>", desc = "Open project manager", remap = false },
    { "<space>s", ":Telescope current_buffer_fuzzy_find<CR>", desc = "Search current buffer" },
    { "<space>x", ":Telescope commands<CR>", desc = "Execute commands" },
})

