{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./grub.nix
    ./user.nix
    ./vim.nix
    ./network.nix
    ./httpd.nix
    ./postfix.nix
    ./dovecot.nix
    ./fiche.nix
    ./irc.nix
  ];

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Los_Angeles";
  services.ntp.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    elinks
    unzip
    git
    htop
    bashCompletion
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      fiche = pkgs.callPackage ./pkg/fiche.nix { };
    };
  };

  programs.bash.enableCompletion = true;

  services.locate.enable = true;
  services.cron.enable = true;

  swapDevices = [
    {
      # Nix will create this automagically
      device = "/root/swap";
      size = 1024;
    }
  ];

  system.stateVersion = "15.09";
}

# TODO:
# Setup email for pastespace (postfix + dovecot)
# OpenSSL keys declaratively
# Bring in weechat/mutt configs
# Harden more (ping limit? tor? better firewall?)
