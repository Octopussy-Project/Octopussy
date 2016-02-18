FROM debian:squeeze

MAINTAINER Sebastien Thebert <stt@octopussy.pm>

EXPOSE 8888

RUN \
    echo "deb http://ftp.fr.debian.org/debian/ squeeze non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://ftp.fr.debian.org/debian/ squeeze non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --force-yes -y \
    adduser curl debconf apache2 rsyslog nscd perl perl-modules sudo mysql-server \
    libapache2-mod-perl2 libapache-asp-perl libapp-info-perl libunix-syslog-perl \
    libxml-simple-perl libcrypt-passwdmd5-perl libdbi-perl libdbd-mysql-perl libsys-cpu-perl \
    libdate-manip-perl libnet-scp-perl libnet-telnet-perl libnet-xmpp-perl libmail-sender-perl \
    libnet-ldap-perl librrd4 rrdtool htmldoc liblinux-inotify2-perl libcache-cache-perl \
    libproc-processtable-perl liburi-perl libproc-pid-file-perl \
    libwww-perl libjson-perl libreadonly-perl libregexp-assemble-perl liblist-moreutils-perl \
    libterm-progressbar-perl liblocale-maketext-lexicon-perl libdatetime-format-strptime-perl libfile-slurp-perl

RUN curl -L -s -o /tmp/Octopussy-1.0.14.tar.gz https://github.com/sebthebert/Octopussy/archive/Octopussy-1.0.14.tar.gz && \
    cd /tmp && \
    tar xfz Octopussy-1.0.14.tar.gz

ADD INSTALL.sh /tmp/Octopussy-Octopussy-1.0.14/LINUX/INSTALL.sh

RUN \
    cd /tmp/Octopussy-Octopussy-1.0.14/LINUX/ && \
    chmod 755 *.sh && \
    ./INSTALL.sh

ENTRYPOINT [ "/etc/init.d/octopussy", "start" ]
