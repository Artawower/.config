local wk = require("which-key")
wk.register(
    {
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
