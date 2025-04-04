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

local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = {"ts-ls", "stylelint_lsp", "cssls", "pyright", "vuels", "gopls"}
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

require "lspconfig".lua_ls.setup {
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
            client.config.settings =
                vim.tbl_deep_extend(
                "force",
                client.config.settings,
                {
                    Lua = {
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            -- (most likely LuaJIT in the case of Neovim)
                            version = "LuaJIT"
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
                }
            )

            client.notify("workspace/didChangeConfiguration", {settings = client.config.settings})
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
            trace = {server = "verbose"},
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
                kubernetes = "/*.yaml"
            },
            schemaDownloads = {enable = true},
            validate = true
        }
    }
}

local languageServerPath = "/Users/darkawower/.npm-global/lib/node_modules"
-- local languageServerPath = vim.fn.stdpath("config").."/lua/languageserver"
local cmd = {"ngserver", "--stdio", "--tsProbeLocations", languageServerPath, "--ngProbeLocations", languageServerPath}

require "lspconfig".angularls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = cmd,
    on_new_config = function(new_config, new_root_dir)
        new_config.cmd = cmd
    end
}

local opts = {noremap = true, silent = true}
local ng = require("ng")
vim.keymap.set("n", "<leader>at", ng.goto_template_for_component, opts)
vim.keymap.set("n", "<leader>ac", ng.goto_component_with_template_file, opts)
vim.keymap.set("n", "<leader>aT", ng.get_template_tcb, opts)

require "lspconfig".volar.setup {
    filetypes = {"typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json"}
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
            toggle_or_open = "o",
            vsplit = "s",
            split = "i",
            quit = "q",
            tabe = "t",
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
wk.add({
    { "<space>", group = "Lsp prompts" },
    { "<space>h", group = "Lsp prompts - Hover and Signature" },
    { "<space>hd", ":lua require('lspsaga.hover').render_hover_doc()<CR>", desc = "Show nice docs" },
    { "<space>hs", ":lua require('lspsaga.signaturehelp').signature_help()<CR>", desc = "Show signature of method" },
    { "<space>hh", ":lua require'lspsaga.provider'.lsp_finder()<CR>", desc = "Lsp saga events" },

    { "<space>c", group = "Lsp code action" },
    { "<space>cr", ":Lspsaga rename<CR>", desc = "Lsp rename" },

    { "<space>f", group = "Flycheck error" },
    { "<space>fp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "Prev error" },
    { "<space>fn", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "Next error" },
    { "<space>f[", "<cmd>lua vim.diagnostic.goto_prev()<CR>", desc = "Prev error" },
    { "<space>f]", "<cmd>lua vim.diagnostic.goto_next()<CR>", desc = "Next error" },

    { "<space>l", group = "Lsp list" },
    { "<space>lr", ":Lspsaga lsp_finder<CR>", desc = "Find references" },
    { "<leader>l", ":lua require('lspsaga.codeaction').range_code_action()<CR>", desc = "Code actions" },
    { "<leader>d", ":lua require('lspsaga.provider').preview_definition()<CR>", desc = "Show definition" },
    { "<leader>i", ":lua require('lspsaga.hover').render_hover_doc()<CR>", desc = "Show docs" },

    { "g", group = "Go" },
    { "gd", ":lua vim.lsp.buf.definition()<CR>", desc = "Go to definition" },
    { "gD", ":lua vim.lsp.buf.declaration()<CR>", desc = "Go to declaration" },
    { "gi", ":lua vim.lsp.buf.implementation()<CR>", desc = "Go to implementation" },
})

require "lspconfig".vuels.setup {}
