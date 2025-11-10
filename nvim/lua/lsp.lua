-- Modern LSP configuration for Neovim 0.11+
-- Using vim.lsp.config instead of deprecated lspconfig framework

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

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
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
end

-- Setup capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Helper function to start LSP
local function setup_lsp(name, config)
    vim.lsp.config[name] = vim.tbl_extend("force", {
        capabilities = capabilities,
        on_attach = on_attach,
    }, config or {})
end

-- Configure TypeScript/JavaScript LSP
setup_lsp('ts_ls', {
    cmd = {'typescript-language-server', '--stdio'},
    root_dir = vim.fs.root(0, {'package.json', 'tsconfig.json', 'jsconfig.json'}),
    filetypes = {'javascript', 'javascriptreact', 'typescript', 'typescriptreact'},
})

-- Configure Stylelint LSP
setup_lsp('stylelint_lsp', {
    cmd = {'stylelint-lsp', '--stdio'},
    root_dir = vim.fs.root(0, {'.stylelintrc', '.stylelintrc.json', '.stylelintrc.js'}),
    filetypes = {'css', 'scss', 'less', 'sass'},
    settings = {
        stylelintplus = {}
    }
})

-- Configure CSS LSP
setup_lsp('cssls', {
    cmd = {'vscode-css-language-server', '--stdio'},
    root_dir = vim.fs.root(0, {'package.json'}),
    filetypes = {'css', 'scss', 'less'},
})

-- Configure Pyright (Python)
setup_lsp('pyright', {
    cmd = {'pyright-langserver', '--stdio'},
    root_dir = vim.fs.root(0, {'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile'}),
    filetypes = {'python'},
})

-- Configure Vuels (Vue.js 2)
setup_lsp('vuels', {
    cmd = {'vls'},
    root_dir = vim.fs.root(0, {'package.json', 'vue.config.js'}),
    filetypes = {'vue'},
})

-- Configure Go LSP
setup_lsp('gopls', {
    cmd = {'gopls'},
    root_dir = vim.fs.root(0, {'go.mod', 'go.work'}),
    filetypes = {'go', 'gomod', 'gowork', 'gotmpl'},
})

-- Configure Lua LSP
setup_lsp('lua_ls', {
    cmd = {'lua-language-server'},
    root_dir = vim.fs.root(0, {'.luarc.json', '.luarc.jsonc', '.git'}),
    filetypes = {'lua'},
    on_init = function(client)
        local path = client.workspace_folders and client.workspace_folders[1] and client.workspace_folders[1].name
        if path and not vim.uv.fs_stat(path .. "/.luarc.json") and not vim.uv.fs_stat(path .. "/.luarc.jsonc") then
            client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
                Lua = {
                    runtime = {
                        version = "LuaJIT"
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME
                        }
                    }
                }
            })
            client.notify("workspace/didChangeConfiguration", {settings = client.config.settings})
        end
        return true
    end,
    settings = {
        Lua = {
            runtime = {version = "LuaJIT"},
            workspace = {
                checkThirdParty = false,
                library = {vim.env.VIMRUNTIME}
            }
        }
    }
})

-- Configure YAML LSP
setup_lsp('yamlls', {
    cmd = {'yaml-language-server', '--stdio'},
    root_dir = vim.fs.root(0, {'.git'}),
    filetypes = {'yaml', 'yml'},
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
})

-- Configure Angular LSP
local languageServerPath = "/Users/darkawower/.npm-global/lib/node_modules"
local angular_cmd = {"ngserver", "--stdio", "--tsProbeLocations", languageServerPath, "--ngProbeLocations", languageServerPath}

setup_lsp('angularls', {
    cmd = angular_cmd,
    root_dir = vim.fs.root(0, {'angular.json', 'project.json'}),
    filetypes = {'typescript', 'html', 'typescriptreact'},
})

-- Configure Volar (Vue 3)
setup_lsp('volar', {
    cmd = {'vue-language-server', '--stdio'},
    root_dir = vim.fs.root(0, {'package.json'}),
    filetypes = {'vue', 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'json'},
})

-- Enable LSP servers automatically
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("LspAttach", {clear = true}),
    callback = function(args)
        local bufnr = args.buf
        local filetype = vim.bo[bufnr].filetype
        
        -- Map filetypes to LSP server names
        local ft_to_lsp = {
            lua = 'lua_ls',
            python = 'pyright',
            javascript = 'ts_ls',
            javascriptreact = 'ts_ls',
            typescript = 'ts_ls',
            typescriptreact = 'ts_ls',
            vue = 'volar',
            css = 'cssls',
            scss = 'stylelint_lsp',
            less = 'stylelint_lsp',
            sass = 'stylelint_lsp',
            go = 'gopls',
            yaml = 'yamlls',
            yml = 'yamlls',
        }
        
        local lsp_name = ft_to_lsp[filetype]
        if lsp_name and vim.lsp.config[lsp_name] then
            vim.lsp.enable(lsp_name)
        end
    end,
})

-- Angular navigation shortcuts
local ng_ok, ng = pcall(require, "ng")
if ng_ok then
    local opts = {noremap = true, silent = true}
    vim.keymap.set("n", "<leader>at", ng.goto_template_for_component, opts)
    vim.keymap.set("n", "<leader>ac", ng.goto_component_with_template_file, opts)
    vim.keymap.set("n", "<leader>aT", ng.get_template_tcb, opts)
end

-- UI - LSPSaga (modern API)
local saga_ok, saga = pcall(require, "lspsaga")
if saga_ok then
    saga.setup({
        ui = {
            border = "single",
            code_action = " ",
        },
        symbol_in_winbar = {
            enable = true,
        },
        lightbulb = {
            enable = true,
            sign = true,
            virtual_text = true,
        },
        finder = {
            max_height = 0.6,
            keys = {
                toggle_or_open = "o",
                vsplit = "s",
                split = "i",
                quit = "q",
                tabe = "t",
                scroll_down = "<C-f>",
                scroll_up = "<C-b>"
            }
        },
        code_action = {
            keys = {
                quit = "q",
                exec = "<CR>"
            }
        },
        rename = {
            keys = {
                quit = "<C-c>",
                exec = "<CR>"
            }
        },
    })
end

-- Which-key mappings
local wk_ok, wk = pcall(require, "which-key")
if wk_ok then
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
end
