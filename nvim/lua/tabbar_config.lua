local wk = require('which-key')


wk.register({
  b = { 
    "Buffer navigation",
    ["["] = {
      ":BufferPrevious<CR>",
      "Previous buffer"
    },
    ["]"] = {
      ":BufferNext<CR>",
      "Next buffer"
    }
  }
}, { prefix = '<space>' })
