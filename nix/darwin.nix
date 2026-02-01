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
    dock = {
      autohide = true;
      tilesize = 32;
      largesize = 48;
      magnification = true;
      show-recents = false;
    };
    loginwindow.LoginwindowText = "Husky v maske";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 30;
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "61" = {
            enabled = true;
            value = {
              parameters = [
                65535
                105
                0
              ];
              type = "standard";
            };
          };
        };
      };
    };
  };

  environment.loginItems = {
    enable = true;
    items = [
      "/Applications/Ice.app"
      "/Applications/AltTab.app"
      "/Applications/AlDente.app"
      "/Applications/VoiceInk.app"
      "/Applications/Input Source Pro.app"
      "/Applications/Raycast.app"
      "/Applications/Shottr.app"
      "/Applications/Clop.app"
    ];
  };

  system.activationScripts.setWorkspaceAutoSwoosh = ''
    echo "Disabling workspaces-auto-swoosh..."
    defaults write com.apple.dock workspaces-auto-swoosh -bool NO
    killall Dock || true
  '';

  system.activationScripts.setInputSourceHotkey = ''
    su -l darkawower -c 'killall SystemUIServer || true'
  '';

  system.activationScripts.disableLanguageCursorPopup = ''
    /usr/bin/defaults write /Library/Preferences/FeatureFlags/Domain/UIKit.plist redesigned_text_cursor -dict-add Enabled -bool NO
  '';

  system.activationScripts.postActivation.text = ''
        echo "Updating hotkeys..."
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

        echo "Checking Library Validation..."
        if [ "$(/usr/bin/defaults read /Library/Preferences/com.apple.security.libraryvalidation.plist DisableLibraryValidation 2>/dev/null)" != "1" ]; then
          echo "Applying Library Validation fix..."
          /usr/bin/defaults write /Library/Preferences/com.apple.security.libraryvalidation.plist DisableLibraryValidation -bool YES
        fi

        emacsclient_bin="/opt/homebrew/bin/emacsclient"
        target_dir="/Applications/Emacsclient.app"
        if [ -x "$emacsclient_bin" ]; then
          if [ -d "$target_dir" ]; then
            rm -rf "$target_dir"
          fi
          mkdir -p "$target_dir/Contents/MacOS" "$target_dir/Contents/Resources"
          cat > "$target_dir/Contents/Info.plist" <<'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleDisplayName</key>
      <string>Emacsclient</string>
      <key>CFBundleName</key>
      <string>Emacsclient</string>
      <key>CFBundleIdentifier</key>
      <string>org.gnu.emacsclient</string>
      <key>CFBundleVersion</key>
      <string>1.0</string>
      <key>CFBundleShortVersionString</key>
      <string>1.0</string>
      <key>CFBundleExecutable</key>
      <string>Emacsclient</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>LSUIElement</key>
      <false/>
    </dict>
    </plist>
    EOF
          cat > "$target_dir/Contents/MacOS/Emacsclient" <<'EOF'
    #!/bin/sh
    exec /opt/homebrew/bin/emacsclient -c -a ""
    EOF
          chmod +x "$target_dir/Contents/MacOS/Emacsclient"
        fi
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

  security.sudo.extraConfig = ''
    darkawower ALL=(root) NOPASSWD: /opt/homebrew/bin/yabai --load-sa
  '';

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
      }
      {
        name = "FelixKratz/formulae/borders";
        restart_service = false;
      }
      { name = "koekeishiya/formulae/skhd"; }
      # "sketchybar"
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
      "sdkman/tap/sdkman-cli"
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
      "opencode"
      "git-delta"
      "harper"
      "pdf2svg"
      "fzf"
      "graphviz"
      "direnv"
      "zellij"
      # "helix"
      {
        name = "d12frosted/emacs-plus/emacs-plus@30";
        restart_service = true;
        args = [
          "with-xwidgets"
          "with-imagemagick"
          "with-dbus"
          "with-compress-install"
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
      "rustup"
      "fontforge"
      "oven-sh/bun/bun"
      "rust"
      "ripgrep"
      "gitu"
      "pinentry-mac"
      "lgug2z/tap/komorebi-for-mac"
    ];
    taps = [
      "clojure/tools"
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
      "FelixKratz/formulae"
      "sst/tap"
      "lgug2z/tap"
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
      "krtirtho/apps/spotube"
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
      "shottr"
      "clop"
      "input-source-pro"
      "mongodb-compass"
      "cyberduck"
      "rustdesk"
      "wakatime"
      "rescuetime"
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
      "nikitabobko/tap/aerospace"
      "amneziavpn"
      "dotnet-sdk"
      "dotnet-sdk@9"
      # "rust-disk-cleaner"
      # "macforge"
      "telegram-desktop"
      "bitwarden"
      "whatsapp"
      "keycastr"
      "kamillobinski/thock/thock"
      "stats"
      "freefilesync"
      "zed"
      "chia"
      "aldente"
      "voiceink"
      "chatgpt"
      "alt-tab"
      "yandex-disk"
      "claude-code"
      "thock"
      "android-studio"
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
}
