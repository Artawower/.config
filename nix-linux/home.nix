{ pkgs, inputs, ... }:

{
  imports = [
    ./darkman.nix
    ./fonts.nix
  ];

  home.username = "darkawower";
  home.homeDirectory = "/home/darkawower";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    inputs.dms.packages.${pkgs.system}.dms-shell
    helix
    fastfetch
    grim 
    slurp 
    swappy
    cliphist
    fuzzel
    swaynotificationcenter
    waybar
    swaybg
    brightnessctl
    playerctl
    volta
    python3
    uv
    # rustup
    go
    zoxide
    eza
    bat
    fzf
    xonsh
    zellij
    codex
    opencode
    bitwarden-desktop
    starship
    yazi
    vicinae
    just
    cmake
    libtool
    libcanberra-gtk3
    libnotify
    ripgrep
    fd
    swww
    gitu
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    networkmanager
    blueman
    bluetuith  
    btop
    wireplumber
    gradia
    wakatime-cli
    htop
    xremap
    enchant2
    gcc
    dash
    libz

    # Build deps
    cmake
    libtool
    pkg-config
    enchant2
    dash
    libz
    llvmPackages.libclang.lib

    # freetype
    gnupg
    tesseract
    
    # Mail
    isync
    emacsPackages.mu4e
    gawk
    cacert
    msmtp
    pinentry-gnome3
    pass

    # Clipboard
    wl-clipboard
    wl-clip-persist

    # Tools
    amneziawg-tools

    lazydocker
    # Development
    bun

    # Cli/tui
    vi-mongo
    s-tui
    gh


    # Voice to text
    (writeShellScriptBin "waystt" ''
  export ALSA_PLUGIN_DIRS="/usr/lib64/alsa-lib"
  export LD_LIBRARY_PATH="/usr/lib64:${pkgs.stdenv.cc.cc.lib}/lib"
  exec /home/darkawower/.local/bin/waystt-bin "$@"
'')
  ];

  home.sessionVariables = {
    BROWSER = "app.zen_browser.zen";
    SHELL = "${pkgs.xonsh}/bin/xonsh";
    CPATH = "${pkgs.enchant2}/include/enchant-2";
    LIBRARY_PATH = "${pkgs.enchant2}/lib";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    LD_LIBRARY_PATH = "${pkgs.llvmPackages.libclang.lib}/lib:${pkgs.libz}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-I${pkgs.llvmPackages.libclang.lib}/lib/clang/${pkgs.llvmPackages.libclang.version}/include";
  };

  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  services.cliphist.enable = false;
  programs.home-manager.enable = true;

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "breeze";
  };

xdg.portal = {
  enable = true;
  extraPortals = [ 
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
  ];
  config = {
    common = {
      default = "gtk";
    };
    niri = {
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
    };
  };
};

programs.gpg = {
    enable = true;
    settings = {
      pinentry-mode = "loopback";
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
    enableSshSupport = true;
    enableExtraSocket = true;
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
