require("nvim_comment").setup()

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
local g = vim.g

-- Treesitter
parser_config.org = {
    install_info = {
        url = "https://github.com/milisims/tree-sitter-org",
        revision = "main",
        files = {"src/parser.c", "src/scanner.cc"}
    },
    filetype = "org"
}

-- require "nvim-treesitter.configs".setup {
--     -- ensure_installed = {"org", "maintained"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
--     ensure_installed = {"org"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
--     sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
--     ignore_install = {"javascript"}, -- List of parsers to ignore installing
--     autotag = {
--         enable = true
--     },
--     highlight = {
--         enable = true, -- false will disable the whole extension
--         disable = {"c", "rust", "org"}, -- list of language that will be disabled
--         -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
--         -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
--         -- Using this option may slow down your editor, and you may see some duplicate highlights.
--         -- Instead of true it can also be a list of languages
--         raijbow = {
--             -- Setting colors
--             colors = {},
--             -- Term colors
--             termcolors = {}
--         }
--     }
-- }

require "nvim-treesitter.configs".setup {
    playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code

        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?"
        }
    }
}

-- AUTO PAIR
require("nvim-autopairs").setup(
    {
        disable_filetype = {"TelescopePrompt", "vim"}
    }
)

-- If you want insert `(` after select function or method item
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({map_char = {tex = ""}}))

require "treesitter-context".setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    throttle = true, -- Throttles plugin updates (may improve performance)
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    patterns = {
        default = {
            "class",
            "function",
            "method"
            -- 'for', -- These won't appear in the context
            -- 'while',
            -- 'if',
            -- 'switch',
            -- 'case',
        }
        -- Example for a specific filetype.
        -- If a pattern is missing, *open a PR* so everyone can benefit.
        --   rust = {
        --       'impl_item',
        --   },
    }
}

g.neoformat_javascript_prettier = {
    exe = "./node_modules/.bin/prettier",
    args = {"--write", "--config .prettierrc"},
    replace = 1
}
g.neoformat_typescript_prettier = {
    exe = "./node_modules/.bin/prettier",
    args = {"--write", "--config .prettierrc"},
    replace = 1
}

vim.api.nvim_exec(
    [[
let g:neoformat_javascript_prettier = {
      \ 'exe': './node_modules/.bin/prettier',
      \ 'args': ['--write', '--config .prettierrc'],
      \ 'replace': 1
      \ }
]],
    false
)

local wk = require("which-key")

wk.register(
    {
        g = {
            l = {
                ":lua require('logsitter').log(file_type)",
                "Log by file-type"
            }
        }
    },
    {prefix = "<space>"}
)

-- vim.api.nvim_exec(
--     [[
-- augroup Logsitter
-- 	au!
-- 	au  FileType javascript   nnoremap <space>lg :Logsitter javascript<cr>
-- 	au  FileType go           nnoremap <space>lg :Logsitter go<cr>
-- 	au  FileType lua          nnoremap <space>lg :Logsitter lua<cr>
-- augroup END
-- ]],
--     false
-- )
