require("telescope").setup {
    defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.45,
                results_width = 0.8
            },
            vertical = {
                mirror = false
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = {"node_modules"},
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = {"truncate"},
        winblend = 0,
        border = {},
        borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
        color_devicons = true,
        use_less = true,
        set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker
    },
    pickers = {},
    extensions = {}
}

require "telescope".load_extension("project")

local wk = require("which-key")

wk.register(
    {
        name = "completion",
        x = {":Telescope commands<CR>", "Execute commands"},
        ["<space>"] = {":Telescope find_files<CR>", "Find Files"},
        ["'"] = {":Telescope resume<CR>", "Resume last session"},
        ["/"] = {":Telescope live_grep<CR>", "Search project"},
        b = {
            b = {":Telescope buffers<CR>", "Open buffer"}
        },
        f = {
            name = "Files",
            r = {":Telescope oldfiles<CR>", "Open old files"}
        },
        p = {
            ":lua require'telescope'.extensions.project.project{}<CR>",
            "Open project manager",
            noremap = true
        },
        ["*"] = {
            ":Telescope grep_string()<CR>"
        }
    },
    {prefix = "<space>"}
)
