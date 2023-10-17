local nvim_lsp = require("lspconfig")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    local opts = {noremap = true, silent = true}

    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    buf_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    buf_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

-- Setup lspconfig.
-- local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {"tsserver", "stylelint_lsp", "cssls", "pyright", "vuels", "gopls"}
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150
        }
    }
end

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require'lspconfig'.lua_ls.setup {
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

require "lspconfig".stylelint_lsp.setup {
    settings = {
        stylelintplus = {}
    }
}

require("lspconfig").yamlls.setup {
    settings = {
        yaml = {
          trace = { server = "verbose" },
          schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
            kubernetes = "/*.yaml",
          },
          schemaDownloads = { enable = true },
          validate = true,
        }
    }
}

-- local project_library_path = "/usr/local/lib/node_modules"
local project_library_path = "/opt/homebrew/lib/node_modules/"
local cmd = {"/opt/homebrew/lib/node_modules/@angular/language-server/bin/ngserver", "--stdio", "--tsProbeLocations", project_library_path , "--ngProbeLocations", project_library_path}

-- local cmd = {
--     "ngserver",
--     "--stdio",
--     "--tsProbeLocations",
--     project_library_path,
--     "--ngProbeLocations",
--     project_library_path
-- }

require "lspconfig".angularls.setup {
    cmd = cmd,
    on_new_config = function(new_config, new_root_dir)
        new_config.cmd = cmd
    end
}

require'lspconfig'.volar.setup{
  filetypes = {'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json'}
}


-- ui
local saga = require "lspsaga"

saga.init_lsp_saga(
    {
        error_sign = "",
        warn_sign = "",
        hint_sign = "",
        infor_sign = "",
        diagnostic_header_icon = "   ",
        code_action_icon = " ",
        code_action_prompt = {
            enable = true,
            sign = true,
            sign_priority = 20,
            virtual_text = true
        },
        finder_definition_icon = "  ",
        finder_reference_icon = "  ",
        max_preview_lines = 10, -- preview lines of lsp_finder and definition preview
        finder_action_keys = {
            open = "o",
            vsplit = "s",
            split = "i",
            quit = "q",
            scroll_down = "<C-f>",
            scroll_up = "<C-b>" -- quit can be a table
        },
        code_action_keys = {
            quit = "q",
            exec = "<CR>"
        },
        rename_action_keys = {
            quit = "<C-c>",
            exec = "<CR>" -- quit can be a table
        },
        definition_preview_icon = "  ",
        border_style = "single",
        rename_prompt_prefix = "➤"
    }
)

local wk = require("which-key")
wk.register(
    {
        name = "Lsp prompts",
        h = {
            d = {":lua require('lspsaga.hover').render_hover_doc()<CR>", "Show nice docs"},
            s = {":lua require('lspsaga.signaturehelp').signature_help()<CR>", "Show signature of method"},
            h = {":lua require'lspsaga.provider'.lsp_finder()<CR>", "Lsp saga events"}
        },
        r = {
            name = "Lsp rename",
            n = {":lua require('lspsaga.codeaction').range_code_action()<CR>", "Code actions"}
        },
        f = {
            name = "Flycheck error",
            p = {"<cmd>lua vim.diagnostic.goto_prev()<CR>", "Prev error"},
            n = {"<cmd>lua vim.diagnostic.goto_next()<CR>", "Next error"}
        }
    },
    {prefix = "<space>"}
)

wk.register(
    {
        l = {":lua require('lspsaga.codeaction').range_code_action()<CR>", "Code actions"},
        d = {":lua require('lspsaga.provider').preview_definition()<CR>", "Show definition"},
        i = {":lua require('lspsaga.hover').render_hover_doc()<CR>", "Show docs"}
    },
    {prefix = "<leader>"}
)

wk.register(
    {
        g = {
            name = "Go",
            d = {":lua vim.lsp.buf.definition()<CR>", "Go to definition"},
            D = {":lua vim.lsp.buf.declaration()<CR>", "Go to declaration"},
            i = {":lua vim.lsp.buf.implementation()<CR>", "Go to implementation"}
        }
    }
)
