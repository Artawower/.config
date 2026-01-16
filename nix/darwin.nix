{ self, pkgs, ... }:
let
  emacsDaemonStarter = pkgs.writeShellScriptBin "emacs-daemon-starter" ''
    exec /opt/homebrew/bin/emacs --fg-daemon=server --eval '(server-start)'
  '';
in
{
  environment.systemPackages = with pkgs; [
    vim
    nixfmt-rfc-style
    xonsh
  ];

  environment.variables = {
    EDITOR = "emacsclient -c";
    PATH = "/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH";
  };

  nix.settings.experimental-features = "nix-command flakes";

  system.primaryUser = "darkawower";

  # programs.fish.enable = true;

  # users.users.darkawower.shell = pkgs.fish;

  environment.shells = [ pkgs.xonsh ];

  users.users.darkawower = {
    shell = pkgs.xonsh;
  };

  system.defaults = {
    dock.autohide = true;
    loginwindow.LoginwindowText = "Husky v maske";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 30;
    NSGlobalDomain = {
      NSAutomaticWindowAnimationsEnabled = false;
    };
  };

  system.activationScripts.setWorkspaceAutoSwoosh = ''
    echo "Disabling workspaces-auto-swoosh..."
    defaults write com.apple.dock workspaces-auto-swoosh -bool NO
    killall Dock || true
  '';

  # ensure log dir exists for the user
  system.activationScripts.ensureEmacsLogDir = ''
    su -l darkawower -c 'mkdir -p "$HOME/.local/state/emacs"'
  '';

  # Fix readlink for home-manager on macOS
  system.activationScripts.fixReadlink = ''
    if [ ! -f /usr/local/bin/readlink ]; then
      mkdir -p /usr/local/bin
      ln -sf /opt/homebrew/bin/greadlink /usr/local/bin/readlink 2>/dev/null || true
    fi
  '';

  security.pam.services.sudo_local.touchIdAuth = true;

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
  nixpkgs.hostPlatform = "aarch64-darwin";

  nixpkgs.config = {
    permittedInsecurePackages = [
      "python-2.7.18.8"
    ];
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    brews = [
      # Libraries & build tools (keep in Homebrew)
      "jpeg"
      "enchant"
      "imagemagick"
      "automake"
      "autoconf"
      "dbus"
      "gcc"
      "libgccjit"
      "pkgconf"
      "meson"
      "ninja"
      "librsvg"
      "texinfo"
      "zlib"
      "libxml2"
      "jansson"
      "gnutls"
      "unbound"
      "p11-kit"
      "nettle"
      "libtasn1"
      "libnghttp2"
      "libidn2"
      "libevent"
      "gdk-pixbuf"
      "tree-sitter"

      # System tools
      "coreutils"
      "openvpn"
      "nmap"
      "gomi"
      "gpg"
      "wireguard-tools"
      "mas"
      "terminal-notifier"

      # Window management (system integration required)
      {
        name = "koekeishiya/formulae/yabai";
        args = [ "--HEAD" ];
      }
      # "yabai"
      {
        name = "borders";
        restart_service = false;
      }
      { name = "koekeishiya/formulae/skhd"; }
      # "skhd"
      "sketchybar"

      # Development tools (keep in Homebrew for reasons)
      "moar"
      "uv"
      "ipython"
      "ncdu"
      "awk"
      "go"
      "python"
      "grep"
      "findutils"
      "gnu-sed"
      "make"
      "gnu-tar"
      "clojure"
      "clojure/tools/clojure"
      "spoof-mac"
      "google-java-format"
      "lua-language-server"
      "wakatime-cli"
      "proctools"
      "jj"
      "SDKMAN-cli"
      "mkcert"
      "cocoapods"
      "staticcheck"
      "volta"
      "superfile"
      "lazygit"
      "dtach"
      "bandwhich"
      "poetry"
      "pandoc"
      "jqp"
      "podman"
      "cloc"
      "claude-squad"
      "sst/tap/opencode"
      "git-delta"
      "node@20"
      "harper"
      "pdf2svg"
      "fzf"
      "graphviz"
      "direnv"
      "zellij"
      # "helix"
      {
        name = "emacs-plus@30";
        args = [
          "with-xwidgets"
          "with-imagemagick"
          "with-modern-doom3-icon"
          "with-dbus"
        ];
      }
      # "jackett"
      # "acsandmann/tap/rift"
      "just"
      "resterm"
      "cava"
      "pipes-sh"
      "Artawower/tap/wallboy"
      "vips"
      "borkdude/brew/babashka"
      "clojure-lsp/brew/clojure-lsp-native"
      "gleam"
      "erlang"
      "llvm"
      "ast-grep"
      "quicktype"
    ];
    taps = [
      "kamillobinski/thock"
      "krtirtho/apps"
      "koraysels/personal"
      "FelixKratz/formulae"
      "marcuzzz/homebrew-marcstap"
      "d12frosted/emacs-plus"
      "SDKMAN/tap"
      "nikitabobko/tap"
      "ozankasikci/tap"
      "koekeishiya/formulae"
      "borkdude/brew"
    ];
    casks = [
      # Fonts (not available as Nerd Fonts in nixpkgs)
      "font-liga-comic-mono"
      "font-monaspace-nf" # Monaspace Nerd Font (with icons)

      # "betterdisplay@2.2.10"
      "lulu"
      "vlc"
      "marta"
      "ghostty"
      "freefilesync"
      "orbstack"
      "wezterm"
      "freedom"
      "flameshot"
      "pearcleaner"
      "spotube"
      "discord"
      {
        name = "stretchly";
        args = {
          no_quarantine = true;
        };
      }
      "applite"
      "obsidian"
      "neohtop"
      "db-browser-for-sqlite"
      "jordanbaird-ice"
      "zen"
      "karabiner-elements"
      "loom"
      "zoom"
      "skype"
      "shottr"
      "clop"
      "input-source-pro"
      "mongodb-compass"
      "cyberduck"
      "rustdesk"
      "wakatime"
      "rescuetime"
      "google-chrome"
      "arc"
      "openvpn-connect"
      "hoppscotch"
      "cursor"
      "mattermost"
      "ticktick"
      # "ollama"
      "raycast"
      "zen@twilight"
      "ghostty"
      # "th-ch/youtube-music/youtube-music"
      # "swiftbar"
      "licecap"
      "aerospace"
      "amneziavpn"
      "dotnet-sdk@9"
      "rust-disk-cleaner"
      "macforge"
      "telegram-desktop"
      "bitwarden"
      "whatsapp"
      "keycastr"
      "thock"
      "stats"
    ];
    masApps = {
      # "Bitwarden" = 1352778147;
      # "Whatsapp" = 310633997;
      # "Telegram" = 747648890;
      # "Hyperduck" = 6444667067;
      # "Gifski" = 1351639930;
    };
  };

  system.activationScripts.masOptional = ''
    if command -v mas >/dev/null 2>&1; then
      install_or_warn() {
        local name="$1" id="$2"
        echo "Installing optional MAS app: $name ($id)"
        if ! mas install "$id"; then
          echo "Warning: failed to install $name ($id)" >&2
        fi
      }
      install_or_warn "Arc browser" 6472513080
      # install_or_warn "Grab 2 text" 6475956137
    else
      echo "mas not found; skipping optional MAS apps" >&2
    fi
  '';

  # launchd.user.agents."gnu.emacs.daemon" = {
  #   serviceConfig = {
  #     Label = "gnu.emacs.daemon";
  #     ProgramArguments = [
  #       "${emacsDaemonStarter}/bin/emacs-daemon-starter"
  #     ];
  #     RunAtLoad = true;
  #     KeepAlive = {
  #       SuccessfulExit = false;
  #       Crashed = true;
  #     };
  #     ProcessType = "Background";
  #     StandardOutPath = "/Users/darkawower/.local/state/emacs/daemon.log";
  #     StandardErrorPath = "/Users/darkawower/.local/state/emacs/daemon.err";
  #     EnvironmentVariables = {
  #       LANG = "en_US.UTF-8";
  #       PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin";
  #       TERM = "xterm-256color";
  #     };
  #   };
  # };
}
