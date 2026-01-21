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
    wl-clipboard
    cliphist
    fuzzel
    swaynotificationcenter
    waybar
    swaybg
    brightnessctl
    playerctl
    bun
    # emacs30
    volta
    python3
    uv
    rustup
    go
    zoxide
    eza
    bat
    fzf
    nodejs_22
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
    # satty
    ripgrep
    fd
    # mattermost-desktop
    swww
    gitu
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    networkmanager
    blueman
    # impala требует iwd, а у нас NetworkManager + wpa_supplicant
    # Используй nmtui для WiFi
    bluetuith     # TUI for Bluetooth
    wireplumber
    neohtop
    gradia
    wakatime-cli
    htop
    xremap
    pkg-config
    enchant2
    gcc
    dash
    libz
    freetype
  ];

  home.sessionVariables = {
    SHELL = "${pkgs.xonsh}/bin/xonsh";
    CPATH = "${pkgs.enchant2}/include/enchant-2";
    LIBRARY_PATH = "${pkgs.enchant2}/lib";
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
}
