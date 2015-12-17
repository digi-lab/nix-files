{ config, lib, pkgs, ... }:

with config;

let
  localcf = pkgs.writeText "sa-local.cf"  ''
    # set required score a bit higher
    required_score 5.2

    # don't use any dns blacklists
    skip_rbl_checks 1

    # leave the message as is (just append headers)
    report_safe 0

    # include generated whitelist
    # which is generated by ${mkwhitelist} script via cron
    include whitelist_from.txt

    # learn settings
    #bayes_auto_learn_threshold_nonspam 0.1
    bayes_auto_learn_threshold_spam 10.0
  '';

  mkwhitelist = pkgs.writeScript "mk-whitelist.sh" ''
    #!/bin/sh -e
    # go through all Sent mailboxes and collect To addresses
    # copied from: http://wiki.apache.org/spamassassin/ManualWhitelist#Automatically_whitelisting_people_you.27ve_emailed
    # should be run as root, it modifies files in /etc/spamassassin

    log() {
      ${pkgs.inetutils}/bin/logger "mk-whitelist: $1"
    }

    log "starting on $(date)"
    SENTMAIL=
    for d in /home/*; do  #*/
       if [ -r "$d/Maildir/.Sent/cur" ]; then
         SENTMAIL="$SENTMAIL $d/Maildir/.Sent/cur/*"
       fi
    done
    log "adding mail addresses from folders $SENTMAIL"
    cat $SENTMAIL |
          grep -Ei '^(To|cc|bcc):' |
          grep -oEi '[a-z0-9_.=/-]+@([a-z0-9-]+\.)+[a-z]{2,}' |
          tr "A-Z" "a-z" |
          sort -u |
          xargs -n 100 echo "whitelist_from"
    log "done on $(date)"
  '';

  learnfromusers = pkgs.writeScript "learn-ham-and-spam.sh" ''
    #!/bin/sh -e
    # feeds mails from LearnSpam and LearnNotSpam maildirs into spamassassin
    # must be run as root

    LEARNHAM=".LearnNotSpam"
    LEARNSPAM=".LearnSpam"

    log() {
      ${pkgs.inetutils}/bin/logger "learn-spam-ham: $1"
    }
    learn() {
      user=$(expr match ''${2#/home/} '\([a-zA-Z0-9]*\)')
      log "Learn $1 for user $user on file $2…"
      ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/sh spamd -c "${pkgs.spamassassin}/bin/sa-learn -u $user --dbpath /var/lib/spamassassin/user-$user/bayes $1 $2"
      #chown -R spamd:spamd /var/lib/spamassassin/user-$user/
      if [ "$1" = "--spam" ]; then
          [ "$(ls -A $2)" ] && log "remove spam mail $2" && rm -f $2/* #*/
      else
          # mv does not work if src dir is empty
          [ "$(ls -A $2)" ] && log "move ham mail $2 to inbox" && mv -f $2/* /home/$user/Maildir/cur/ #*/
      fi
      return 0
    }

    log "starting on $(date)"
    find /home -type d | grep "$LEARNHAM/cur" | while read f; do
      learn "--ham" $f
    done
    find /home -type d | grep "$LEARNSPAM/cur" | while read f; do
      learn "--spam" $f
    done
    log "done on $(date)"
  '';
in
{

  services.spamassassin = {
    enable = true;
    debug = true;
  };

  services.postfix =
  {
    extraMasterConf =
    ''
      smtp       inet  n      -       -       -       -       smtpd
        -o content_filter=spamassassin
      spamassassin unix -     n       n       -       -       pipe
        user=spamd argv=${pkgs.spamassassin}/bin/spamc -f -e
        ${pkgs.postfix}/bin/sendmail -oi -f ''${sender} ''${recipient}
    '';
  };

  services.cron.systemCronJobs = [
    "0 3 * * * root ${mkwhitelist} > /tmp/whitelist && mv /tmp/whitelist /etc/spamassassin/whitelist_from.txt"
    "0 3 * * * root ${learnfromusers}"
  ];

  system.activationScripts = if (services.spamassassin.enable) then {
    spamassassincfg = ''
      mkdir -p /etc/spamassassin
      mkdir -p /var/lib/spamassassin
      for u in $(ls -1 /home/); do
          mkdir -p /var/lib/spamassassin/user-$u
      done
      chown -R spamd:spamd /var/lib/spamassassin
      cp -n ${pkgs.spamassassin}/share/spamassassin/* /etc/spamassassin/
      #*/
      rm -f /etc/spamassassin/local.cf
      ln -s ${localcf} /etc/spamassassin/local.cf
      #chmod -R 0770 /var/postfix
      postfix set-permissions
    '';
  } else {};

  users.users.spamd =
  {
    extraGroups = [ "postdrop" ];
  };

  users.users.root =
  {
    extraGroups = [ "postdrop" ];
  };

  # TODO: Needs initial sa-update
}
