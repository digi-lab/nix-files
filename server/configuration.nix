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

    ./shared/system/grub.nix

    ./shared/system/environment.nix
    ./server/system/environment.nix

    ./shared/system/network.nix
    ./server/system/network.nix

    ./server/system/user.nix
    ./shared/system/systemd.nix

    ./server/program/essentials.nix
    ./server/program/admin.nix

    ./server/user/irc.nix
    ./server/user/git.nix
    ./server/user/jeaye.nix

    ./server/service/ssh.nix
    ./server/service/acme.nix
    ./server/service/httpd.nix
    ./server/service/postfix.nix
    ./server/service/dovecot.nix
    ./server/service/opendkim.nix
    ./server/service/spamassassin.nix
    ./server/service/safepaste.nix
    ./server/service/jank-benchmark.nix
    ./server/service/fail2ban.nix
    ./server/service/radicale.nix
    ./server/service/gpg.nix
    ./server/service/jank-license.nix
    ./server/service/upload.jeaye.com-tmp.nix
    ./server/service/wordy-word.nix
    ./server/service/rainloop.nix

    ./server/container/nextcloud.nix
  ];

  system.stateVersion = "17.09";
}
