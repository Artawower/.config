{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    darkman
    dconf
  ];

  xdg.configFile."darkman/config.yaml".text = ''
    usegeoclue: false
  '';
  
  # Fixed schedule timers (disabled)
  # systemd.user.timers.darkman-light = {
  #   Unit = {
  #     Description = "Switch to light mode at 08:00";
  #   };
  #   Timer = {
  #     OnCalendar = "08:00";
  #     Persistent = true;
  #   };
  #   Install = {
  #     WantedBy = [ "timers.target" ];
  #   };
  # };
  # 
  # systemd.user.services.darkman-light = {
  #   Unit = {
  #     Description = "Switch darkman to light mode";
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.darkman}/bin/darkman set light";
  #   };
  # };
  # 
  # systemd.user.timers.darkman-dark = {
  #   Unit = {
  #     Description = "Switch to dark mode at 19:00";
  #   };
  #   Timer = {
  #     OnCalendar = "19:00";
  #     Persistent = true;
  #   };
  #   Install = {
  #     WantedBy = [ "timers.target" ];
  #   };
  # };
  # 
  # systemd.user.services.darkman-dark = {
  #   Unit = {
  #     Description = "Switch darkman to dark mode";
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.darkman}/bin/darkman set dark";
  #   };
  # };

  # Theme switch script
  # Use Adwaita (lighter than Breeze)
  xdg.dataFile."darkman/theme-switch.sh" = {
    text = ''
      #!/bin/sh
      MODE="$1"
      
      case "$MODE" in
        light)
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita'"
          ;;
        dark)
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
          ;;
      esac
    '';
    executable = true;
  };

  # xdg-desktop-portal config for Niri
  # Use gtk portal only, no gnome
  xdg.configFile."xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    default=gtk
  '';

  # darkman systemd service (disabled)
  # systemd.user.services.darkman = {
  #   Unit = {
  #     Description = "Framework for dark-mode and light-mode transitions";
  #     PartOf = [ "graphical-session.target" ];
  #     After = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     Type = "exec";
  #     ExecStart = "${pkgs.darkman}/bin/darkman run";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  #   Install = {
  #     WantedBy = [ "graphical-session.target" ];
  #   };
  # };
}
