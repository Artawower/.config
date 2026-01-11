{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Volta packages (not available in nixpkgs)
  voltaPackages = [
    "@angular/language-service@next"
    "copilot-node-server"
    "yalc"
    "lua-fmt"
    "@anthropic-ai/claude-code"
    "@openai/codex"
    "@qwen-code/qwen-code@latest"
    "mcp-codex-cli"
    "@gy920/qwen-mcp-tool"
    "pretty-ts-errors-markdown"
    "playwright"
  ];

  # Cargo packages (not available in nixpkgs)
  cargoPackages = [
    "gitu"
    "wrkflw"
    "kdlfmt"
  ];

  # Go packages (not available in nixpkgs)
  goPackages = [
    "github.com/sahaj-b/wakafetch@latest"
  ];

  # UV tools (Python CLI tools)
  uvTools = [
    "rassumfrassum"
    "ty"
    "basedpyright"
    "http-prompt"
    "httpie"
  ];

  # Custom xonsh with extensions
  xontribDirPicker = pkgs.python3Packages.buildPythonPackage rec {
    pname = "xontrib-dir-picker";
    version = "1.0.2";
    format = "wheel";

    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/py3/x/xontrib-dir-picker/xontrib_dir_picker-1.0.2-py3-none-any.whl";
      sha256 = "19xc00wfqqq7hz1jbam8famj6v92ili05jjfnj6pn0jrziz8waad";
    };

    doCheck = false;
    pythonImportsCheck = [ ];
  };

  xonshDirenv = pkgs.python3Packages.buildPythonPackage rec {
    pname = "xonsh_direnv";
    version = "1.6.5";

    src = pkgs.fetchPypi {
      pname = "xonsh_direnv";
      inherit version;
      sha256 = "sha256-kWTR62EWW2dwWqC9neXS/JsCyxufoBrAabLj7xn4hYQ=";
    };

    format = "setuptools";

    doCheck = false;
  };

  walsh = pkgs.buildGoModule rec {
    pname = "walsh";
    version = "0.5.4";

    src = pkgs.fetchFromGitHub {
      owner = "joshbeard";
      repo = "walsh";
      rev = "${version}";
      sha256 = "1832z165bp6hfnnzwwaimv7rnylr73ihdm7d513zr62yxzh592dp";
    };

    vendorHash = "sha256-AP8kwriZYX38hdOgx5n0ggUpP218rp1TlOenEGRtwV8=";

    meta = with pkgs.lib; {
      description = "Tool for managing wallpapers on Linux, BSD, and macOS";
      homepage = "https://github.com/joshbeard/walsh";
      license = licenses.bsd0;
      platforms = platforms.all;
    };
  };

  xonshWithExtensions = pkgs.python3.withPackages (ps: [
    ps.xonsh
    xontribDirPicker
    xonshDirenv
    ps.httpx
    ps.pip
    ps.tomli-w
  ]);
in
{
  home.stateVersion = "23.05";
  home.username = "darkawower";
  home.homeDirectory = "/Users/darkawower";

  # Enable font management
  fonts.fontconfig.enable = true;

  # Packages installed through Nix
  home.packages = with pkgs; [
    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove # Cascadia Code
    nerd-fonts._3270
    # monaspace  # Plain version - use Homebrew cask for NF version

    # CLI tools
    # grc  # Disabled: causes fork() deprecation warnings
    ripgrep
    fd
    htop
    wget
    curl
    git
    tmux
    neovim
    bash
    coreutils
    jq
    tree
    unzip
    sqlite
    fish
    eza

    # Shells
    xonshWithExtensions
    starship
    dash # one of the quickest shell for scripting

    # Shell & productivity
    # atuin          # shell history sync
    # zellij # terminal multiplexer

    # File managers & viewers
    yazi # terminal file manager
    ranger # terminal file manager

    # System monitoring & info
    fastfetch # system info (fast)
    neofetch # system info (classic)

    # Editors
    helix

    # Development tools
    gh # GitHub CLI
    gobang # TUI database manager
    xxh # portable shell environment via SSH

    # Node.js packages available in nixpkgs
    nodePackages.typescript
    nodePackages.eslint
    nodePackages.prettier
    # vue-language-server
    cmake

    # Software
    zoxide
    walsh
  ];

  home.file = { };

  home.sessionVariables = {
    PATH = "$HOME/.volta/bin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH:/Users/darkawower/.local/share/uv/tools";
  };

  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -Ux EDITOR 'emacsclient -ac'
      set fish_greeting
      set fish_color_cwd blue
      set fish_color_cwd_root blue
      set fish_color_host blue
      set pure_show_system_time false
      set pure_shorten_prompt_current_directory_length 5
      set -x LSP_USE_PLISTS true
      set -x PYTHONWARNINGS "ignore::DeprecationWarning"

      bind \f accept-autosuggestion
      bind \v history-token-search-backward
      bind \n history-token-search-forward
      bind \cA beginning-of-line
      bind \cE end-of-line

      bind -M insert \f accept-autosuggestion
      bind -M insert \v history-search-backward
      bind -M insert \n history-search-forward
      bind -M insert \ce end-of-line
      bind -M insert \ca beginning-of-line

      bind -M default \v history-search-backward
      bind -M default \n history-search-forward

      bind -M insert \cj 'commandline -f history-token-search-forward'

      set pure_enable_single_line_prompt true
      if test -e ~/.config/fish/secrets.fish
          source ~/.config/fish/secrets.fish
      end
    '';

    shellInit = ''
      set -gx PATH /opt/homebrew/bin /opt/homebrew/sbin $PATH   
      set -gx PATH /nix/var/nix/profiles/default/bin /nix/var/nix/profiles/per-user/$USER/profile/bin $PATH
      set -gx PATH /opt/homebrew/bin /usr/local/bin $PATH
      set -gx PATH /opt/homebrew/opt/gnupg@2.2/bin /opt/homebrew/opt/autoconf@2.69/bin /Users/darkawower/.sdkman/candidates/java/current/bin /Users/darkawower/.sdkman/candidates/gradle/current/bin /opt/homebrew/opt/openjdk@11/bin /Users/darkawower/.bun/bin /Users/darkawower/.npm-global/lib /Users/darkawower/.npm-global/bin /Users/darkawower/Library/Android/sdk/build-tools/34.0.0 /opt/homebrew/opt/node@22/bin /opt/homebrew/lib/node_modules/typescript/bin /Users/darkawower/Library/pnpm /opt/homebrew/opt/openssl@1.1/bin /Users/darkawower/node_modules/usr/local/opt/libpq/bin /Users/darkawower/.cargo/bin /Users/darkawower/.nix-profile/bin /nix/var/nix/profiles/default/bin /usr/local/bin /usr/bin /usr/sbin /bin /sbin /Users/darkawower/.orbstack/bin /opt/homebrew/bin /Users/darkawower/.local/bin/ /usr/local/opt/bin/ /usr/local/bin/ /usr/bin/ /Users/darkawower/dev/flutter/bin /Users/darkawower/tmp/lua-language-server/bin /Users/darkawower/.go/bin /opt/homebrew/opt/go/libexec/bin /Users/darkawower/Library/Android/sdk/tools /Users/darkawower/Library/Android/sdk/platform-tools /run/current-system/sw/bin $HOME/.volta/bin $HOME/go/bin;
      set -gx PATH /Users/darkawower/.local/share/uv/tools $PATH

      fish_vi_key_bindings

      alias doom="~/.emacs.d/bin/doom"
      alias emacs30="/opt/homebrew/Cellar/emacs-plus@30/30.0.93/bin/emacs --init-dir ~/.emacs.d-30"
      alias pip="pip3"
      alias python="python3"
      alias wakatime-cli="/opt/homebrew/bin/wakatime"
      alias nv="~/.config/nv.sh"
      alias ls="eza --icons"
      alias syncwp="unison -ui text '/Volumes/DARK SIDE/wallpappers/' ~/Pictures/wallpappers"
      alias m="minikube"
      alias ms="minikube start --driver=docker --alsologtostderr"
      alias md="m dashboard"
      alias n="nvim"
      alias kg="kubectl get"
      alias c="clear"
      alias dublog="ssh -i ~/.ssh/dublog darkawower@49.12.98.254"
      alias farm="ssh -i ~/.ssh/farm artur@chiafarm.hopto.org -p 2222"
      alias farmd="ssh -i ~/.ssh/farm artur@chiafarm.freeddns.org -p 2222"
      alias o="cd ~/projects/pet/orgnote"
      alias oc="cd ~/projects/pet/orgnote/orgnote-client"
      alias os="cd ~/projects/pet/orgnote/org-mode-ast"
      alias oa="cd ~/projects/pet/orgnote/orgnote-api"
      alias oci="cd ~/projects/pet/orgnote/orgnote-cli"
      alias ob="cd ~/projects/pet/orgnote/orgnote-backend"
      alias watch-dark-mode="sh ~/.config/scripts/kitty-auto-theme-switcher.sh &"
      alias br="bun run"
      alias bi="bun install"
      alias bis="bun install --exact --save"
      alias bid="bun install --exact --save --dev"
      alias pi="pnpm run install"
      alias pr="pnpm run"
      alias displays="/Users/darkawower/.config/yabai/layouts/Arturs-MacBook-Pro.local/desktop.sh"
      alias preserve-displays="/Users/darkawower/.config/yabai/restore-script.sh"
      alias volar="/Users/darkawower/.npm-global/bin/vue-language-server"
      alias tree="eza --tree"
      alias y="yazi"
      alias ui="cd ~/projects/ui/"
      alias uim="cd ~/projects/ui-main-dev/"
      alias ua="cd ~/projects/ui_alternative/"
      alias mr="cd ~/projects/miron/"
      alias pet="cd ~/projects/pet/"
      alias sub="cd ~/projects/pet/subscrumber-repo/"
      alias u="cd ~/.config/nix && make rebuild"
      alias uclean="sudo nix-collect-garbage -d"
      alias uh="cd ~/.config/nix && make home"
      alias ud="cd ~/.config/nix && make darwin"

      set -gx PATH $HOME/.volta/bin $PATH
    '';

    plugins = [
      # Disabled: grc causes fork() deprecation warnings in Python
      # {
      #   name = "grc";
      #   src = pkgs.fishPlugins.grc.src;
      # }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "e0e1b9dfdba362f8ab1ae8c1afc7ccf62b89f7eb";
          sha256 = "0dbnir6jbwjpjalz14snzd3cgdysgcs3raznsijd6savad3qhijc";
        };
      }
      {
        name = "gh-copilot-cli-alias";
        src = pkgs.fetchFromGitHub {
          owner = "rcny";
          repo = "gh-copilot-cli-alias.fish";
          rev = "master";
          sha256 = "0bjc4wr451prl2jaamm8mr4y2w12m21s75pmjs8cyp1d08y12yj5";
        };
      }
      {
        name = "sdkman-for-fish";
        src = pkgs.fetchFromGitHub {
          owner = "reitzig";
          repo = "sdkman-for-fish";
          rev = "v2.1.0";
          sha256 = "0mvlacq88m3r7lqkym8qzlirmx06kad4njfrzdpl5pshg13k5j7d";
        };
      }
      {
        name = "nvm";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "nvm.fish";
          rev = "main";
          sha256 = "0f0gwz6rqc6f9czd556hh9g3rhrcy6q6mzmh3p0lqrs3h2hs2ymv";
        };
      }
      {
        name = "wakatime";
        src = pkgs.fetchFromGitHub {
          owner = "ik11235";
          repo = "wakatime.fish";
          rev = "master";
          sha256 = "0njbysbz8w4baby55kp4779r22v5h43bcww3xgfg62hzgvvgmjhy";
        };
      }
      {
        name = "loadenv";
        src = pkgs.fetchFromGitHub {
          owner = "berk-karaal";
          repo = "loadenv.fish";
          rev = "main";
          sha256 = "143v9l20d3cms9qx7g85p53083rgb5j24d785apmjqc8fhh8mb22";
        };
      }
      {
        name = "pisces";
        src = pkgs.fetchFromGitHub {
          owner = "laughedelic";
          repo = "pisces";
          rev = "master";
          sha256 = "073wb83qcn0hfkywjcly64k6pf0d7z5nxxwls5sa80jdwchvd2rs";
        };
      }
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "pure-fish";
          repo = "pure";
          rev = "master";
          sha256 = "0xfqa7c7l984i4dr89lqv9gh588lzpj479ir91hchyh0y7csxjkp";
        };
      }
      {
        name = "autoenv";
        src = pkgs.fetchFromGitHub {
          owner = "SpaceShaman";
          repo = "autoenv.fish";
          rev = "master";
          sha256 = "11wfsz0rkzb66np0xg28bnslw46fc3g7wlypcvjz6x850n3f4v0p";
        };
      }
    ];
  };

  programs.fish.functions = {
    hx = {
      description = "Launch Helix after syncing theme with system";
      body = ''
        ~/.config/helix/theme_switcher.sh >/dev/null 2>&1
        command hx $argv
      '';
    };

    bash = {
      description = "Delegate to external bash (no hardcoded path)";
      body = "command bash $argv";
    };
  };

  home.activation = {
    fixReadlinkCompat = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      readlink() {
        case "$1" in
          -e|-m)
            shift
            realpath "$@"
            ;;
          *)
            /usr/bin/readlink "$@"
            ;;
        esac
      }
      export -f readlink
    '';

    installRarePackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="$HOME/.volta/bin:$HOME/.cargo/bin:$HOME/go/bin:/opt/homebrew/bin:$PATH"

      if command -v volta >/dev/null 2>&1; then
        ${lib.concatMapStringsSep "\n" (
          pkg:
          "volta list 2>/dev/null | grep -q ${lib.escapeShellArg (builtins.head (lib.splitString "@" pkg))} || volta install ${pkg} 2>/dev/null"
        ) voltaPackages}
      fi

      if command -v cargo >/dev/null 2>&1; then
        ${lib.concatMapStringsSep "\n" (
          pkg: "command -v ${pkg} >/dev/null 2>&1 || cargo install ${pkg} 2>/dev/null"
        ) cargoPackages}
      fi

      if command -v go >/dev/null 2>&1; then
        export GOPATH="$HOME/go"
        export GOBIN="$HOME/go/bin"
        ${lib.concatMapStringsSep "\n" (
          pkg:
          let
            pkgName = lib.last (lib.splitString "/" (builtins.head (lib.splitString "@" pkg)));
          in
          "command -v ${pkgName} >/dev/null 2>&1 || go install ${pkg} 2>/dev/null"
        ) goPackages}
      fi

      if command -v uv >/dev/null 2>&1; then
        ${lib.concatMapStringsSep "\n" (
          pkg:
          let
            pkgName = builtins.head (lib.splitString "@" pkg);
          in
          "uv tool list 2>/dev/null | grep -q ${lib.escapeShellArg pkgName} || uv tool install ${pkg} 2>/dev/null"
        ) uvTools}
      fi

    '';
  };

  launchd.agents.walsh = {
    enable = true;
    config = {
      Label = "com.darkawower.walsh";
      ProgramArguments = [
        "${walsh}/bin/walsh"
        "set"
        "--interval"
        "600"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/walsh.stdout";
      StandardErrorPath = "/tmp/walsh.stderr";
    };
  };
}
