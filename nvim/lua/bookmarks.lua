local g = vim.g

g.bookmark_auto_save = 1
g.bookmark_auto_close = 1
g.bookmark_no_default_key_mappings = 1
g.bookmark_highlight_lines = 1

require("telescope").load_extension("vim_bookmarks")

local wk = require("which-key")

wk.register(
    {
        name = "Bookmarks",
        ["<enter>"] = {":BookmarkAnnotate<CR>", "Toggle bookmarks"},
        b = {
            n = {":BookmarkNext<CR>", "Next bookmarks"},
            p = {":BookmarkPrev<CR>", "Prev bookmarks"},
            t = {":BookmarkShowAll<CR>", "Toggle bookmark"},
            l = {
                ":lua require('telescope').extensions.vim_bookmarks.all({ only_annotated = true })<CR>",
                "All bookmarks"
            },
            f = {":lua require('telescope').extensions.vim_bookmarks.current_file()<CR>", "Current file bookmarks"}
        }
    },
    {prefix = "<space>"}
)
