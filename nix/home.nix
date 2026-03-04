{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Go packages (not available in nixpkgs)
  goPackages = [
    "github.com/sahaj-b/wakafetch@latest"
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
    ps.setuptools
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
    # fish
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

    # Android SDK for Capacitor
    jdk21
    gradle
  ];

  home.file = { };

  home.sessionVariables = {
    PATH = "$HOME/.volta/bin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH:/Users/darkawower/.local/share/uv/tools";
    ANDROID_HOME = "$HOME/Library/Android/sdk";
    ANDROID_SDK_ROOT = "$HOME/Library/Android/sdk";
    JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    signing = {
      key = "4357424B95BAB5C5";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Artur Iaroshenko";
        email = "artawower@protonmail.com";
      };
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.program = "/opt/homebrew/bin/gpg";
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
