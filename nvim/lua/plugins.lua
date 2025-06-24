return {
    -- Dependencies
    {
        "MunifTanjim/nui.nvim"
    },
    -- Whick key
    {"folke/which-key.nvim", lazy = true},
    -- File managers
    {
        "francoiscabrol/ranger.vim",
        config = function()
            require("ranger_config")
        end
    },
    {
        "mikavilpas/yazi.nvim",
        event = "VeryLazy",
        keys = {
            -- 👇 in this section, choose your own keymappings!
            {
                "<leader>-",
                "<cmd>Yazi<cr>",
                desc = "Open yazi at the current file"
            },
            {
                -- Open in the current working directory
                "<leader>cw",
                "<cmd>Yazi cwd<cr>",
                desc = "Open the file manager in nvim's working directory"
            },
            {
                -- NOTE: this requires a version of yazi that includes
                -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
                "<c-up>",
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session"
            }
        },
        ---@type YaziConfig
        opts = {
            -- if you want to open yazi instead of netrw, see below for more info
            open_for_directories = false,
            keymaps = {
                show_help = "<f1>"
            }
        }
    },
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvimtree_config")
        end
    },
    -- Development
    "folke/neodev.nvim",
    -- UI
    -- Theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = function()
            require("catppuccin").setup(
                {
                    flavour = "frappe", -- latte, frappe, macchiato, mocha
                    transparent_background = true,
                    background = {
                        -- :h background
                        light = "latte",
                        dark = "mocha"
                    },
                    integrations = {
                        cmp = true,
                        gitsigns = true,
                        nvimtree = true,
                        telescope = {
                            enabled = false,
                            theme = "dropdown",
                            style = "nvchad"
                        },
                        notify = false,
                        mini = false
                        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
                    }
                }
            )
        end
    },
    "folke/tokyonight.nvim",
    {
        "f-person/auto-dark-mode.nvim",
        config = function()
            local auto_dark_mode = require("auto-dark-mode")
            auto_dark_mode.setup(
                {
                    update_interval = 1000,
                    set_dark_mode = function()
                        vim.api.nvim_set_option("background", "dark")
                        vim.cmd("colorscheme catppuccin")
                    end,
                    set_light_mode = function()
                        vim.api.nvim_set_option("background", "light")
                        vim.cmd("colorscheme catppuccin_latte")
                    end
                }
            )
            auto_dark_mode.init()
        end
    },
    {
        "karb94/neoscroll.nvim",
        config = function()
            require("neoscroll").setup()
        end
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("lualine_config")
        end
    },
    {
        "romgrk/barbar.nvim",
        dependencies = {
            "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
            "nvim-tree/nvim-web-devicons" -- OPTIONAL: for file icons
        },
        init = function()
            vim.g.barbar_auto_setup = false
            require("tabbar_config")
        end,
        opts = {},
        version = "^1.0.0" -- optional: only update when a new 1.x version is released
    },
    "p00f/nvim-ts-rainbow",
    "norcalli/nvim-colorizer.lua",
    "sakshamgupta05/vim-todo-highlight",
    "VonHeikemen/searchbox.nvim",
    -- Navigation
    {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        event = "VeryLazy",
        version = "2.*",
        config = function()
            require("choosewin_config")
        end
    },
    -- {
    --     "t9md/vim-choosewin",
    --     config = function()
    --         require("choosewin_config")
    --     end
    -- },
    {
        "phaazon/hop.nvim",
        branch = "v2", -- optional but strongly recommended
        keys = {
            {"f", ":HopChar1<CR>", desc = "Jump to char", mode = "n"},
            {"<leader>j", ":HopChar1<CR>", desc = "Jump to char", mode = "n"}
        },
        config = function()
            -- you can configure Hop the way you like here; see :h hop-config
            require "hop".setup {keys = "etovxqpdygfblzhckisuran"}
        end
    },
    {
        "MattesGroeger/vim-bookmarks",
        config = function()
            require("bookmarks_config")
        end
    },
    -- Editing
    {
        "L3MON4D3/LuaSnip"
    },
    -- Vim surround
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end
    },
    -- Turbo log!
    {
        "gaelph/logsitter.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        config = function()
            require("logsitter_config")
        end
    },
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    },
    {
        "sbdchd/neoformat",
        config = function()
            require("neoformat_config")
        end
    },
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup(
                {
                    disable_filetype = {"TelescopePrompt", "vim"}
                }
            )
        end
    },
    "windwp/nvim-ts-autotag",
    -- LSP
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lsp")
        end
    },
    -- Angular lsp
    "joeveiga/ng.nvim",
    "tami5/lspsaga.nvim",
    "williamboman/nvim-lsp-installer",
    -- Completion
    {
        "zbirenbaum/copilot.lua",
        config = function()
            require("copilot_config")
        end
    },
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    {
        "hrsh7th/nvim-cmp",
        config = function()
            require("cmp_config")
        end
    },
    {
        "nvim-telescope/telescope.nvim",
        config = function()
            require("telescope_config")
        end,
        dependencies = {{"nvim-lua/plenary.nvim"}}
    },
    "onsails/lspkind-nvim",
    -- Debug
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
    -- Tools
    -- Translate!
    {
        "voldikss/vim-translator",
        config = function()
            require("translate_config")
        end
    },
    -- Wakatime. Time management
    "wakatime/vim-wakatime",
    -- Detect root
    "airblade/vim-rooter",
    -- Terminal
    {
        "akinsho/toggleterm.nvim",
        config = function()
            require("toggleterm_config")
        end
    },
    -- Git
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns_config")
        end
    },
    -- Timemachine
    {
        "fredeeb/tardis.nvim",
        dependencies = {"nvim-lua/plenary.nvim"}
        -- config = function()
        --     require("tardis_config").setup()
        -- end
    },
    {
        "APZelos/blamer.nvim",
        init = function()
            vim.g.blamer_enabled = 1
        end
    },
    {
        "TimUntersberger/neogit",
        config = function()
            require("neogit-config")
        end
    },
    -- Project management
    "dunstontc/projectile.nvim",
    "nvim-telescope/telescope-project.nvim",
    {
        "ahmedkhalf/project.nvim",
        config = function()
            require("project_nvim").setup(require("project_config"))
        end
    },
    -- Bookmarks
    "tom-anders/telescope-vim-bookmarks.nvim",
    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require("treesitter_config")
        end
    },
    {
        "romgrk/nvim-treesitter-context",
        config = function()
            require "treesitter-context".setup {
                enable = true,
                throttle = true,
                max_lines = 0,
                patterns = {
                    default = {
                        "class",
                        "function",
                        "method"
                    }
                }
            }
        end
    },
    "nvim-treesitter/playground",
    -- Spellchecker

    "kamykn/popup-menu.nvim",
    "kamykn/spelunker.vim",
    -- Markup
    "mattn/emmet-vim",
    -- Kitty integration
    {
        "mikesmithgh/kitty-scrollback.nvim",
        enabled = true,
        lazy = true,
        cmd = {"KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth"},
        event = {"User KittyScrollbackLaunch"},
        -- version = '*', -- latest stable version, may have breaking changes if major version changed
        -- version = '^2.0.0', -- pin major version, include fixes and features that do not have breaking changes
        config = function()
            require("kitty-scrollback").setup()
        end
    },
    -- AI
    -- {
    --     "GeorgesAlkhouri/nvim-aider",
    --     cmd = "Aider",
    --     -- Example key mappings for common actions:
    --     keys = {
    --         {"<leader>a/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider"},
    --         {"<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = {"n", "v"}},
    --         {"<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands"},
    --         {"<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer"},
    --         {"<leader>a+", "<cmd>Aider add<cr>", desc = "Add File"},
    --         {"<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File"},
    --         {"<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only"},
    --         {"<leader>aR", "<cmd>Aider reset<cr>", desc = "Reset Session"},
    --         -- Example nvim-tree.lua integration if needed
    --         {"<leader>a+", "<cmd>AiderTreeAddFile<cr>", desc = "Add File from Tree to Aider", ft = "NvimTree"},
    --         {"<leader>a-", "<cmd>AiderTreeDropFile<cr>", desc = "Drop File from Tree from Aider", ft = "NvimTree"}
    --     },
    --     dependencies = {
    --         "folke/snacks.nvim",
    --         --- The below dependencies are optional
    --         "catppuccin/nvim",
    --         "nvim-tree/nvim-tree.lua",
    --         --- Neo-tree integration
    --         {
    --             "nvim-neo-tree/neo-tree.nvim",
    --             opts = function(_, opts)
    --                 -- Example mapping configuration (already set by default)
    --                 -- opts.window = {
    --                 --   mappings = {
    --                 --     ["+"] = { "nvim_aider_add", desc = "add to aider" },
    --                 --     ["-"] = { "nvim_aider_drop", desc = "drop from aider" }
    --                 --     ["="] = { "nvim_aider_add_read_only", desc = "add read-only to aider" }
    --                 --   }
    --                 -- }
    --                 require("nvim_aider.neo_tree").setup(opts)
    --             end
    --         }
    --     },
    --     config = true
    -- }
    {
        "yetone/avante.nvim",
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make", -- ⚠️ must add this line! ! !
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        event = "VeryLazy",
        version = false, -- Never set this value to "*"! Never!
        ---@module 'avante'
        ---@type avante.Config
        opts = {
            -- add any opts here
            -- for example
            provider = "copilot",
            auto_suggestions_provider = nil,
            providers = {
                copilot = {
                    model = "claude-sonnet-4"
                },
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-sonnet-4-20250514",
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 20480
                    }
                }
            }
        },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "echasnovski/mini.pick", -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "stevearc/dressing.nvim", -- for input provider dressing
            "folke/snacks.nvim", -- for input provider snacks
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true
                        },
                        -- required for Windows users
                        use_absolute_path = true
                    }
                }
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = {"markdown", "Avante"}
                },
                ft = {"markdown", "Avante"}
            }
        }
    }
}
