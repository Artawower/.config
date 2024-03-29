require("dapui").setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7"),
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
      -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
  }
})

-- Debug
-- require("dapui").setup(
--     {
--         icons = {expanded = "▾", collapsed = "▸"},
--         mappings = {
--             -- Use a table to apply multiple mappings
--             expand = {"<CR>", "<2-LeftMouse>"},
--             open = "o",
--             remove = "d",
--             edit = "e",
--             repl = "r"
--         },
--         sidebar = {
--             -- You can change the order of elements in the sidebar
--             elements = {
--                 -- Provide as ID strings or tables with "id" and "size" keys
--                 {
--                     id = "scopes",
--                     size = 0.25 -- Can be float or integer > 1
--                 },
--                 {id = "breakpoints", size = 0.25},
--                 {id = "stacks", size = 0.25},
--                 {id = "watches", size = 00.25}
--             },
--             size = 40,
--             position = "left" -- Can be "left", "right", "top", "bottom"
--         },
--         tray = {
--             elements = {"repl"},
--             size = 10,
--             position = "bottom" -- Can be "left", "right", "top", "bottom"
--         },
--         floating = {
--             max_height = nil, -- These can be integers or a float between 0 and 1.
--             max_width = nil, -- Floats will be treated as percentage of your screen.
--             border = "single", -- Border style. Can be "single", "double" or "rounded"
--             mappings = {
--                 close = {"q", "<Esc>"}
--             }
--         },
--         windows = {indent = 1}
--     }
-- )

vim.api.nvim_exec(
    [[
    nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
    nnoremap <silent> <F10> :lua require'dap'.step_over()<CR>
    nnoremap <silent> <F11> :lua require'dap'.step_into()<CR>
    nnoremap <silent> <F12> :lua require'dap'.step_out()<CR>
    nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
    nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
    nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
    nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
    nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>
]],
    false
)

local dap = require("dap")

dap.adapters.go = {
    type = "executable",
    command = "node",
    args = {os.getenv("HOME") .. "/dev/golang/vscode-go/dist/debugAdapter.js"}
}
dap.configurations.go = {
    {
        type = "go",
        name = "Debug",
        request = "launch",
        showLog = false,
        program = "${file}",
        dlvToolPath = vim.fn.exepath("dlv") -- Adjust to where delve is installed
    }
}
