{ config, pkgs, ... }:

let
  spamassassin_prefs =
  ''
    required_score 3
    report_safe 0
    score BAYES_00 -4
    score BAYES_05 -2
    score BAYES_95 6
    score BAYES_99 9
  '';
in
{
  environment.systemPackages = with pkgs;
  [
    tmux
    neomutt
    pinentry
    gnupg
  ];

  users.users.jeaye =
  {
    isNormalUser = true;
    home = "/etc/user/jeaye";
    extraGroups = [ "wheel"  "ssh" ];
  };

  system.activationScripts =
  {
    jeaye-home =
    {
      deps = [];
      text =
      ''
        PATH=${pkgs.git}/bin:$PATH
        PATH=${pkgs.gnused}/bin:$PATH

        if [ ! -d /etc/user/jeaye/.vim ];
        then
          # TODO: Network IO in an activation script is bad
          git clone --recursive https://github.com/jeaye/vimrc.git /etc/user/jeaye/.vim
          ln -sf /etc/user/jeaye/.vim/vimrc /etc/user/jeaye/.vimrc
        fi
        chown -R jeaye:users /etc/user/jeaye/.vim

        user_prefs=/var/lib/spamassassin/user-jeaye/user_prefs
        rm -f "$user_prefs"
        echo "${spamassassin_prefs}" > "$user_prefs"
        chown spamd:spamd "$user_prefs"
        chmod 0600 "$user_prefs"
      '';
    };
  };

  environment.etc =
  {
    "user/jeaye/.procmailrc" =
    {
      text =
      ''
        INCLUDERC=/etc/user/jeaye/.procmail/list.rc
        INCLUDERC=/etc/user/jeaye/.procmail/work.rc
        INCLUDERC=/etc/user/jeaye/.procmail/admin.rc
      '';
    };
    "user/jeaye/.procmail/list.rc" =
    {
      text =
      ''
        # Clojure mailing list
        :0:
        * ^X-BeenThere: clojure@googlegroups\.com
        .ML.Clojure/

        # ClojureScript mailing list
        :0:
        * ^X-BeenThere: clojurescript@googlegroups\.com
        .ML.ClojureScript/

        # Clang mailing list
        :0:
        * ^X-BeenThere: cfe-(users|dev)@cs\.uiuc\.edu
        .ML.Clang/

        # ISOC++ mailing list
        :0:
        * ^X-BeenThere: std-(proposals|discussion)@isocpp\.org
        .ML.ISOCPP/

        # Slackware mailing list
        :0:
        * ^(From|Cc|To).*slackware-(security|announce)@slackware\.com
        .ML.Slackware/

        # NixOS mailing list
        :0:
        * ^X-BeenThere: nix-dev@lists\.science\.uu\.nl
        .ML.NixOS/

        # NixOS-Security mailing list
        :0:
        * ^X-BeenThere: nix-security-announce@googlegroups\.com
        .ML.NixOS-Sec/

        # Junk
        :0:
        * ^(From|Cc|To): (junk@pastespace\.org|junk@jeaye.com)|lorgonjortle.*
        .Junk/
      '';
    };
    "user/jeaye/.procmail/work.rc" =
    {
      text =
      ''
        # Furthington bucket
        :0:
        * ^(From|Cc|To).*furthington\.com
        .Furthington/

        # Hiring bucket
        :0:
        * ^(From|Cc|To).*(hiring@okletsplay.com)
        .LetsBet-Hiring/

        # LetsBet bucket
        :0:
        * ^(From|Cc|To).*(russalek13.*|.*@okletsplay.com)
        .LetsBet/

        # TinyCo bucket
        :0:
        * ^(From|Cc|To).*brooklynpacket/.*
        .TinyCo/
      '';
    };
    "user/jeaye/.procmail/admin.rc" =
    {
      text =
      ''
        # DMARC reports
        :0:
        * ^Subject: Report [dD]omain:
        .ML.DMARC/

        # Cron reports
        :0:
        * ^From: Cron Daemon
        .Cron/
      '';
    };
  };
}
