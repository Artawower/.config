local g = vim.g
local cmd = vim.cmd

cmd.colorscheme "catppuccin"

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
cmd "set backupdir=~/tmp/backups"
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

vim.api.nvim_exec([[
  autocmd Filetype yaml setlocal ts=2 sw=2 expandtab"
  autocmd Filetype yml setlocal ts=2 sw=2 expandtab"
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
  hi Normal guibg=NONE ctermbg=NONE
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

wk.add({
    { "<space>m", group = "Compile" },
    { "<space>meb", ':luafile %<CR>:echo "Compiled!"<CR>', desc = "Compile current lua file" },

    { "<space>b", group = "buffer" },
    { "<space>b]", ":bnext<CR>", desc = "Switch next buffer" },
    { "<space>b[", ":bprevious<CR>", desc = "Switch previous buffer" },

    { "<space>h", group = "Hot" },
    { "<space>hr", group = "Reload" },
    { "<space>hre", ":source ~/.config/nvim/lua/plugins.lua<CR>:source $MYVIMRC<CR>:Lazy sync<CR>:echo 'Reloaded!'<CR>", desc = "Reload neovim" },

    { "<space>w", group = "Split" },
    { "<space>wv", ":vsplit<CR>", desc = "Vertical split" },
    { "<space>ws", ":split<CR>", desc = "Horizontal split" },
    -- Uncomment or modify the below line if needed
    -- { "<space>s", ":SearchBoxIncSearch<CR>", desc = "Search" },
})

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


vim.api.nvim_exec(
    [[
let g:XkbSwitchIMappings = ['ru']
let g:XkbSwitchEnabled = 1

let g:XkbSwitchIMappingsTr = {
	\ 'ru':
	\ {'<': 'qwertyuiop[]asdfghjkl;''zxcvbnm,.`/'.
	\       'QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?~@#$^&|',
	\  '>': 'йцукенгшщзхъфывапролджэячсмитьбюё.'.
	\       'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,Ё"№;:?/'},
	\ 'de':
	\ {'<': 'yz-[];''/YZ{}:"<>?~@#^&*_\',
	\  '>': 'zyßü+öä-ZYÜ*ÖÄ;:_°"§&/(?#'},
	\ }
	]],
    false
)

