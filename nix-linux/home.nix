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
    zoxide
    eza
    bat
    fzf
    ripgrep
    fd
    btop
    htop
    starship
    yazi
    vicinae
    gitu
    just
    dash
    gnupg
    tesseract
    lazydocker
    gh
    vi-mongo
    s-tui
    wakatime-cli

    xonsh
    zellij

    codex
    opencode

    grim
    slurp
    swappy
    cliphist
    fuzzel
    swaynotificationcenter
    waybar
    swaybg
    swww
    brightnessctl
    playerctl
    wl-clipboard
    wl-clip-persist
    xremap
    gradia

    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    networkmanager
    blueman
    bluetuith
    wireplumber
    libnotify
    libcanberra-gtk3

    volta
    python3
    uv
    go
    bun
    gcc
    cmake
    libtool
    pkg-config
    enchant2
    llvmPackages.libclang.lib

    isync
    emacsPackages.mu4e
    gawk
    cacert
    msmtp
    pinentry-gnome3
    pass

    amneziawg-tools

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
