
local wk = require('which-key');
local g = vim.g



g.translator_target_lang = 'ru'
g.translator_source_lang = 'en'

wk.register({
  t = { ':Translate ', 'Translate' }
}, { prefix = '<leader>' })
