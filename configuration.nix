{ config, pkgs, ... }:

{
  imports =
  [
    ./hardware-configuration.nix # Auto-generated by nixos
    ./nixos-in-place.nix

    ./system/grub.nix
    ./system/environment.nix
    ./system/network.nix
    ./system/user.nix

    ./program/vim.nix
    ./program/irc.nix

    ./service/httpd.nix
    ./service/postfix.nix
    ./service/dovecot.nix
    ./service/fiche.nix
  ];

  services.locate.enable = true;

  sound.enable = false;

  system.stateVersion = "15.09";
}

# TODO:
# Let's Encrypt automatically handled certs
# Users in /etc/usert
# Bring in weechat/mutt configs
