-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
    function()
        -- Packer can manage itself
        use "wbthomason/packer.nvim"

        -- Keybindings
        use {
            "folke/which-key.nvim",
            config = function()
                require("which-key").setup {}
            end
        }
        -- File manager
        use {
            "kyazdani42/nvim-tree.lua",
            requires = {
                "kyazdani42/nvim-web-devicons" -- optional, for file icon
            },
            config = function()
                require "nvim-tree".setup {}
            end
        }
        use "francoiscabrol/ranger.vim"
        use "kevinhwang91/rnvimr"
        use "rbgrouleff/bclose.vim"
        -- Editing
        -- use "wellle/context.vim"
        -- use 'tpope/vim-surround'
        use {
            "blackCauldron7/surround.nvim",
            config = function()
                require "surround".setup {mappings_style = "surround"}
            end
        }
        -- navigation
        use {
            "phaazon/hop.nvim",
            branch = "v1", -- optional but strongly recommended
            config = function()
                -- you can configure Hop the way you like here; see :h hop-config
                require "hop".setup {keys = "etovxqpdygfblzhckisuran"}
            end
        }
        -- use "lyokha/vim-xkbswitch"
        -- Editing
        use "terrortylor/nvim-comment"
        
        use "neovim/nvim-lspconfig"

        use "williamboman/nvim-lsp-installer"
        use "romgrk/nvim-treesitter-context"
        use {"gaelph/logsitter.nvim", requires = {"nvim-treesitter/nvim-treesitter"}}
        use "nvim-treesitter/playground"
        use {
            "nvim-telescope/telescope.nvim",
            requires = {{"nvim-lua/plenary.nvim"}}
        }
        use "sbdchd/neoformat"
        use {
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate"
        }
        use "windwp/nvim-autopairs"
        -- Completion
        use "hrsh7th/cmp-nvim-lsp"
        use "L3MON4D3/LuaSnip"
        use "hrsh7th/cmp-buffer"
        use "hrsh7th/cmp-path"
        use "hrsh7th/cmp-cmdline"
        -- use "hrsh7th/nvim-cmp"
        use {"Iron-E/nvim-cmp", branch = "feat/completion-menu-borders"}
        use {"tzachar/cmp-tabnine", run = "./install.sh", requires = "hrsh7th/nvim-cmp"}
        -- Tools
        -- use "utahta/trans.nvim" -- translate
        use "voldikss/vim-translator"
        use "windwp/nvim-ts-autotag"
        use "wakatime/vim-wakatime"
        use "mfussenegger/nvim-dap"
        use {"rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"}}
        -- use "gelguy/wilder.nvim"
        -- use "voldikss/vim-floaterm"
        use {"akinsho/toggleterm.nvim"}
        use "TimUntersberger/neogit"
        use {
            "lewis6991/gitsigns.nvim",
            requires = {
                "nvim-lua/plenary.nvim"
            }
        }
        use {
            "dunstontc/projectile.nvim",
            requires = {"Shougo/denite.nvim"}
        }
        use "mhinz/vim-startify"
        -- use 'glepnir/dashboard-nvim'
        use {
            "nvim-orgmode/orgmode",
            ft = {"org"},
            config = function()
                require("orgmode").setup {
                    org_agenda_files = {"~/Yandex.Disk.localized/Dropbox/org/**/*"},
                    org_default_notes_file = "~/Yandex.Disk.localized/Dropbox/org/notes.org"
                }
            end
        }
        use "airblade/vim-rooter"
        use "MattesGroeger/vim-bookmarks"
        use "nvim-telescope/telescope-project.nvim"
        use "tom-anders/telescope-vim-bookmarks.nvim"
        use "pechorin/any-jump.vim" -- Jump syntax tree by regexps
        -- Visual
        use "navarasu/onedark.nvim" -- theme
        use "dylanaraps/wal.vim"
        use(
            {
                "catppuccin/nvim",
                as = "catppuccin"
            }
        )
        use "eddyekofo94/gruvbox-flat.nvim"
        use {"ellisonleao/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}
        -- use "morhetz/gruvbox"
        use "folke/tokyonight.nvim"
        use "Shatur/neovim-ayu"
        use "marko-cerovac/material.nvim"
        -- use "kyazdani42/nvim-palenight.lua"
        -- Themes end here

        use "APZelos/blamer.nvim"
        use "karb94/neoscroll.nvim"
        use "onsails/lspkind-nvim"
        use {
            "nvim-lualine/lualine.nvim",
            requires = {"kyazdani42/nvim-web-devicons", opt = true}
        }
        use "p00f/nvim-ts-rainbow"
        use "lukas-reineke/indent-blankline.nvim"
        use "norcalli/nvim-colorizer.lua"
        use "sakshamgupta05/vim-todo-highlight"
        use {
            "VonHeikemen/searchbox.nvim",
            requires = {
                {"MunifTanjim/nui.nvim"}
            }
        }
        use "chrisbra/Colorizer"
        use "projekt0n/github-nvim-theme"
        use {"tami5/lspsaga.nvim"} -- ui for lsp
        use "Pocco81/TrueZen.nvim"
        -- Languages
        -- use {
        --     "cuducos/yaml.nvim",
        --     ft = {"yaml"}, -- optional
        --     requires = {
        --         "nvim-treesitter/nvim-treesitter",
        --         "nvim-telescope/telescope.nvim" -- optional
        --     },
        --     config = function()
        --         require("yaml_nvim").init()
        --     end
        -- }
        -- SpellCheck
        use 'kamykn/popup-menu.nvim'
        use 'kamykn/spelunker.vim'
        -- use {
        --     "lewis6991/spellsitter.nvim",
        --     config = function()
        --         require("spellsitter").setup(
        --             {
        --                 enable = true
        --             }
        --         )
        --     end
        -- }
    end
)
