local cmd = vim.cmd
local g = vim.g

-- NOTE: list of all languages: ftp.vim.org/vim/runtime/spell/
-- cmd "set spelllang=en_us"
-- cmd "set spellsuggest=best,9"
-- cmd "set spell!"
cmd "set nospell"


g.enable_spelunker_vim = 1
g.enable_spelunker_vim_on_readonly = 1
vim.api.nvim_exec([[
augroup spelunker
  autocmd!
  " Setting for g:spelunker_check_type = 1:
  autocmd BufWinEnter,BufWritePost *.vim,*.js,*.jsx,*.json,*.md,*lua,*ts,*org call spelunker#check()

  " Setting for g:spelunker_check_type = 2:
  autocmd CursorHold *.vim,*.js,*.jsx,*.json,*.md call spelunker#check_displayed_words()
augroup END
]], false)

