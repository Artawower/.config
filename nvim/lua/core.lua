require "plugins"
require "theme"
require "filemanager"
require "navigation"
require "editing"
require "completion"
require "search"
require "lsp"
require "git"
require "autoformat"
require "bookmarks"
require "tools"
require "spellcheck"

local g = vim.g
local cmd = vim.cmd

g.rooter_patterns = {
    "lua",
    ".git",
    "Makefile",
    "*.sln",
    "build/env.sh",
    "package.json",
    ".gitignore",
    "nvim",
    ".config"
}

cmd "hi clear CursorLine"
cmd "hi cursorlinenr guibg=NONE guifg=#abb2bf"

cmd "set nobackup"
cmd "set nowritebackup"
cmd "set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"
cmd "hi LineNr guifg=#42464e guibg=NONE"
cmd "hi Comment guifg=#42464e"

cmd "hi SignColumn guibg=NONE"
cmd "hi VertSplit guibg=NONE guifg=#2a2e36"
cmd "hi EndOfBuffer guifg=#1e222a"
cmd "hi PmenuSel guibg=#98c379"
cmd "hi Pmenu  guibg=#282c34"

vim.api.nvim_exec(
    [[
  set tabstop=2
  set shiftwidth=2
  set expandtab
  set smartindent
  ]], false)

vim.api.nvim_exec(
[[
  set undodir=~/.vim/undodir
  if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
  endif
  set undodir=/tmp/.vim-undo-dir
  set undofile
]], false)

vim.api.nvim_exec([[
  set foldmethod=indent
  set foldnestmax=10
  set nofoldenable
  set foldlevel=2
  set foldcolumn=0
  highlight foldcolumn guibg=none
]], false)

vim.api.nvim_exec([[
  :nmap <c-s> :w<CR>
  :imap <c-s> <Esc>:w<CR>a
]], false)

-- Common keybindings
local wk = require("which-key")

wk.register(
    {
        m = {
            name = "Compile",
            e = {
                b = {':luafile %<CR>:echo "Compiled!"<CR>', "Compile current lua file"}
            }
        },
        b = {
            name = "buffer",
            ["]"] = {":bnext<CR>", "Switch next buffer"},
            ["["] = {":bprevious<CR>", "Switch previous buffer"}
        },
        h = {
            name = "Hot",
            r = {
                name = "Reload",
                e = {
                    ":source ~/.config/nvim/lua/plugins.lua<CR>:source $MYVIMRC<CR>:PackerSync<CR>:echo 'Reloaded!'<CR>",
                    "Reload neovim"
                }
            }
        },
        s = {":SearchBoxIncSearch<CR>", "Search"}
    },
    { prefix = "<space>" }
)

g.floaterm_keymap_new = "<F7>"
g.floaterm_keymap_prev = "<F8>"
g.floaterm_keymap_next = "<F9>"
g.floaterm_keymap_toggle = "<F12>"

-- vim/evil binding
vim.api.nvim_set_keymap(
    "n",
    "<S-l>",
    ":vertical resize -5<CR>",
    {
        noremap = true,
        silent = true
    }
)
vim.api.nvim_set_keymap(
    "n",
    "<S-h>",
    ":vertical resize +5<CR>",
    {
        noremap = true,
        silent = true
    }
)

vim.api.nvim_set_keymap(
    "n",
    "<S-j>",
    ":resize +5<CR>",
    {
        noremap = true,
        silent = true
    }
)

vim.api.nvim_set_keymap(
    "n",
    "<S-k>",
    ":resize -5<CR>",
    {
        noremap = true,
        silent = true
    }
)

vim.api.nvim_set_keymap(
    "n",
    "<Leader>q",
    ":bp<bar>sp<bar>bn<bar>bd<CR>",
    {
        noremap = true,
        silent = true
    }
)

cmd 'noremap <Leader>y "+y'
cmd 'noremap <Leader>p "+p'
-- 
-- vim.api.nvim_exec([[
--   xnoremap <expr> p 'pgv"'.v:register.'y`>'
--   xnoremap <expr> P 'Pgv"'.v:register.'y`>'
-- ]], false) -- multiple past without buffer trash
