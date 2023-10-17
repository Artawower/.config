local wk = require("which-key")

wk.register({
  ["D"] = {
    ["."] = {"<Plug>(choosewin)", "Choose Window" },
  },
  ["-"] = {"<Plug>(choosewin)", "Choose Window" },
})

