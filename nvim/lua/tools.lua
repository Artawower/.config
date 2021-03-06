local g = vim.g

require("toggleterm").setup {
    -- size can be a number or function which is passed the current terminal
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = "<number>", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = true,
    direction = "float",
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
        -- The border key is *almost* the same as 'nvim_open_win'
        -- see :h nvim_open_win for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        border = "single",
        width = 120,
        height = 30,
        winblend = 3,
        highlights = {
            border = "Normal",
            background = "Normal"
        }
    }
}

function _G.set_terminal_keymaps()
    local opts = {noremap = true}
    vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
    vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

local wk = require("which-key")

wk.register(
    {
        o = {
            name = "Terminal",
            t = {
                ":ToggleTerm size=20 direction=horizontal<CR>",
                "open horizontal terminal",
                noremap = true
            },
            T = {":ToggleTerm size=20 direction=float<CR>", "float terminal", noremap = true}
        }
    },
    {prefix = "<space>"}
)

wk.register(
    {
        name = "Translate",
        t = {
            ":TranslateW --target_lang=ru --source_lang=auto<CR>",
            "Translate line",
            mode = "v"
        },
        r = {
            ":TranslateW --target_lang=en --source_lang=ru<CR>",
            "Translate ru"
        }
    },
    {prefix = "<leader>"}
)

-- Debug
require("dapui").setup(
    {
        icons = {expanded = "???", collapsed = "???"},
        mappings = {
            -- Use a table to apply multiple mappings
            expand = {"<CR>", "<2-LeftMouse>"},
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r"
        },
        sidebar = {
            -- You can change the order of elements in the sidebar
            elements = {
                -- Provide as ID strings or tables with "id" and "size" keys
                {
                    id = "scopes",
                    size = 0.25 -- Can be float or integer > 1
                },
                {id = "breakpoints", size = 0.25},
                {id = "stacks", size = 0.25},
                {id = "watches", size = 00.25}
            },
            size = 40,
            position = "left" -- Can be "left", "right", "top", "bottom"
        },
        tray = {
            elements = {"repl"},
            size = 10,
            position = "bottom" -- Can be "left", "right", "top", "bottom"
        },
        floating = {
            max_height = nil, -- These can be integers or a float between 0 and 1.
            max_width = nil, -- Floats will be treated as percentage of your screen.
            border = "single", -- Border style. Can be "single", "double" or "rounded"
            mappings = {
                close = {"q", "<Esc>"}
            }
        },
        windows = {indent = 1}
    }
)

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
