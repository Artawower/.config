local wk = require('which-key')


wk.add({
    { "<space>b", group = "Buffer navigation" },
    { "<space>b[", ":BufferPrevious<CR>", desc = "Previous buffer" },
    { "<space>b]", ":BufferNext<CR>", desc = "Next buffer" },
})

