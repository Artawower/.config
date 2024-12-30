require("telescope").setup {
    defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
            -- horizontal = {
            --     prompt_position = "top",
            --     preview_width = 0.45,
            --     preview_height = 0.35,
            --     results_width = 0.8
            -- },
            vertical = {
                -- mirror = false
                width = 0.9
            },
            -- width = 0.87,
            height = 0.85,
            preview_cutoff = 20
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

