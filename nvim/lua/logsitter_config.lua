vim.api.nvim_create_augroup("LogSitter", {clear = true})
vim.api.nvim_create_autocmd(
    "FileType",
    {
        group = "LogSitter",
        pattern = "javascript,go,lua,vue,typescript",
        callback = function()
            vim.keymap.set(
                "n",
                "<localleader>lg",
                function()
                    require("logsitter").log()
                end
            )
        end
    }
)

local logsitter = require("logsitter")
local javascript_logger = require("logsitter.lang.javascript")

-- tell logsitter to use the javascript_logger when the filetype is svelte
logsitter.register(javascript_logger, { "vue", "typescript" })
