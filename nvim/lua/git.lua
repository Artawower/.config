local neogit = require("neogit")

neogit.setup {
    disable_signs = false,
    disable_hint = false,
    disable_context_highlighting = false,
    disable_commit_confirmation = false,
    auto_refresh = true,
    disable_builtin_notifications = false,
    commit_popup = {
        kind = "split"
    },
    -- Change the default way of opening neogit
    kind = "tab",
    -- customize displayed signs
    signs = {
        -- { CLOSED, OPENED }
        section = {">", "v"},
        item = {">", "v"},
        hunk = {"", ""}
    },
    integrations = {
        -- Neogit only provides inline diffs. If you want a more traditional way to look at diffs, you can use `sindrets/diffview.nvim`.
        -- The diffview integration enables the diff popup, which is a wrapper around `sindrets/diffview.nvim`.
        --
        -- Requires you to have `sindrets/diffview.nvim` installed.
        -- use {
        --   'TimUntersberger/neogit',
        --   requires = {
        --     'nvim-lua/plenary.nvim',
        --     'sindrets/diffview.nvim'
        --   }
        -- }
        --
        diffview = false
    },
    -- Setting any section to `false` will make the section not render at all
    sections = {
        untracked = {
            folded = false
        },
        unstaged = {
            folded = false
        },
        staged = {
            folded = false
        },
        stashes = {
            folded = true
        },
        unpulled = {
            folded = true
        },
        unmerged = {
            folded = false
        },
        recent = {
            folded = true
        }
    },
    -- override/add mappings
    mappings = {
        -- modify status buffer mappings
        status = {
            -- Adds a mapping with "B" as key that does the "BranchPopup" command
            ["B"] = "BranchPopup",
            -- Removes the default mapping of "s"
            ["s"] = ""
        }
    }
}

require("gitsigns").setup {
    signs = {
        add = {hl = "GitSignsAdd", text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn"},
        change = {hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn"},
        -- add = {hl = "DiffAdd", text = "▌", numhl = "GitSignsAddNr"},
        -- change = {hl = "DiffChange", text = "▌", numhl = "GitSignsChangeNr"},
        delete = {hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn"},
        topdelete = {hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn"},
        changedelete = {hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn"}
    },
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    keymaps = {
        -- Default keymap options
        noremap = true,
        ["n ]c"] = {expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'"},
        ["n [c"] = {expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'"},
        ["n <leader>hs"] = "<cmd>Gitsigns stage_hunk<CR>",
        ["v <leader>hs"] = ":Gitsigns stage_hunk<CR>",
        ["n <leader>hu"] = "<cmd>Gitsigns undo_stage_hunk<CR>",
        ["n <leader>hr"] = "<cmd>Gitsigns reset_hunk<CR>",
        ["v <leader>hr"] = ":Gitsigns reset_hunk<CR>",
        ["n <leader>hR"] = "<cmd>Gitsigns reset_buffer<CR>",
        ["n <leader>hp"] = "<cmd>Gitsigns preview_hunk<CR>",
        ["n <leader>hb"] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
        ["n <leader>hS"] = "<cmd>Gitsigns stage_buffer<CR>",
        ["n <leader>hU"] = "<cmd>Gitsigns reset_buffer_index<CR>",
        -- Text objects
        ["o ih"] = ":<C-U>Gitsigns select_hunk<CR>",
        ["x ih"] = ":<C-U>Gitsigns select_hunk<CR>"
    },
    watch_gitdir = {
        interval = 1000,
        follow_files = true
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false
    },
    current_line_blame_formatter_opts = {
        relative_time = false
    },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
        -- Options passed to nvim_open_win
        border = "single",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1
    },
    yadm = {
        enable = false
    }
}

-- Blsmer
vim.g.blamer_enabled = 1

local wk = require("which-key")

wk.register(
    {
        g = {
            name = "Git",
            g = {":Neogit<CR>", "Open git status"}
        }
    },
    {prefix = "<space>"}
)
