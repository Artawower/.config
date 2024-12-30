
local wk = require('which-key');
local g = vim.g



g.translator_target_lang = 'ru'
g.translator_source_lang = 'en'

wk.add({
    { "<leader>t", ":Translate ", desc = "Translate" },
})

