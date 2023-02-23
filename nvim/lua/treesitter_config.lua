require "nvim-treesitter.configs".setup {
    -- ensure_installed = {"org", "maintained"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    -- ensure_installed = {"org"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
    ignore_install = {"javascript"}, -- List of parsers to ignore installing
    autotag = {
        enable = true
    },
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = {"c", "rust", "org"}, -- list of language that will be disabled
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        raijbow = {
            -- Setting colors
            colors = {},
            -- Term colors
            termcolors = {}
        }
    },
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


-- Autoinstall
local ask_install = {}
function _G.ensure_treesitter_language_installed()
  local parsers = require "nvim-treesitter.parsers"
  local lang = parsers.get_buf_lang()
  if parsers.get_parser_configs()[lang] and not parsers.has_parser(lang) and ask_install[lang] ~= false then
    vim.schedule_wrap(function()
      vim.ui.select({"yes", "no"}, { prompt = "Install tree-sitter parsers for " .. lang .. "?" }, function(item)
        if item == "yes" then
          vim.cmd("TSInstall " .. lang)
        elseif item == "no" then
          ask_install[lang] = false
        end
      end)
    end)()
  end
end

vim.cmd [[autocmd FileType * :lua ensure_treesitter_language_installed()]]




local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.org = {
  install_info = {
    url = 'https://github.com/milisims/tree-sitter-org',
    revision = 'main',
    files = { '/Users/darkawower/tmp/tree-sitter-org/src/parser.c', '/Users/darkawower/tmp/tree-sitter-org/src/scanner.cc' },
  },
  filetype = 'org',
}
