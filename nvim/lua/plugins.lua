return {
    -- Whick key
    {"folke/which-key.nvim", lazy = true},
    -- File managers
    {
        "francoiscabrol/range.vim",
        config = function()
            require("ranger_config")
        end
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
    -- {
    --   'fredeeb/tardis.nvim',
    --   dependencies = { 'nvim-lua/plenary.nvim' },
    --   config = function()
    --     require('tardis_config').setup()
    --   end
    -- },
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
    }
}
