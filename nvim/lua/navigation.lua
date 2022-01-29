require("hop").setup {
    options = {
        -- theme = "tokionight"
        theme = "onedark"
    }
}

local wk = require("which-key")

wk.register(
    {
        f = {":HopChar1<CR>", "Jump to char"}
    }
)

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
