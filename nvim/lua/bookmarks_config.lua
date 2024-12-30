local g = vim.g

g.bookmark_auto_save = 1
g.bookmark_auto_close = 1
g.bookmark_no_default_key_mappings = 1
g.bookmark_highlight_lines = 1

require("telescope").load_extension("vim_bookmarks")

local wk = require("which-key")

wk.add({
    { "<space>", group = "Bookmarks" },
    { "<space><enter>", ":BookmarkAnnotate<CR>", desc = "Toggle bookmarks" },
    { "<space>bn", ":BookmarkNext<CR>", desc = "Next bookmarks" },
    { "<space>bp", ":BookmarkPrev<CR>", desc = "Prev bookmarks" },
    { "<space>bt", ":BookmarkShowAll<CR>", desc = "Toggle bookmark" },
    { "<space>bl", ":lua require('telescope').extensions.vim_bookmarks.all({ only_annotated = true })<CR>", desc = "All bookmarks" },
    { "<space>bf", ":lua require('telescope').extensions.vim_bookmarks.current_file()<CR>", desc = "Current file bookmarks" },
})

