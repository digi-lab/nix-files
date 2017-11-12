{ config, pkgs, ... }:

# TODO: Add automatic blacklist lookup
# http://www.blacklistalert.org/
# https://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a192.241.218.198&run=toolpage
# http://mail-blacklist-checker.online-domain-tools.com/

{
  imports =
  [
    ./hardware-configuration.nix # Auto-generated by nixos
    ./nixos-in-place.nix

    ../shared/system/boot.nix

    ../shared/system/environment.nix
    ./system/environment.nix

    ../shared/system/network.nix
    ./system/network.nix

    ../shared/system/user.nix
    ./server/system/user.nix

    ../shared/system/systemd.nix

    ./program/essentials.nix
    ./program/admin.nix

    ./user/irc.nix
    ./user/git.nix
    ./user/jeaye.nix

    ../shared/service/ssh.nix
    ./service/acme.nix
    ./service/httpd.nix
    ./service/postfix.nix
    ./service/dovecot.nix
    ./service/opendkim.nix
    ./service/spamassassin.nix
    ./service/safepaste.nix
    ./service/jank-benchmark.nix
    ./service/fail2ban.nix
    ./service/radicale.nix
    ./service/gpg.nix
    ./service/jank-license.nix
    ./service/upload.jeaye.com-tmp.nix
    ./service/wordy-word.nix
    ./service/rainloop.nix

    ./container/nextcloud.nix
  ];

  system.stateVersion = "17.09";
}
