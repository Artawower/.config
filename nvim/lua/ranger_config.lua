local wk = require("which-key")

wk.add({
    { "<space>.", ":RangerCurrentDirectory<CR>", desc = "Open current directory" },
    { "<space>,", ":RangerWorkingDirectory<CR>", desc = "Open working directory" },
})

