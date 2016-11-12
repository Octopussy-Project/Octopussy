#!/bin/sh

AAT="aat"
OCTO="octopussy"
CRON_FILE="/etc/cron.daily/octo_logrotate"

ADDGROUP="/usr/sbin/groupadd -r"
ADDUSER="/usr/sbin/useradd -r -M"
CAT="/bin/cat"
CHKCONFIG="/sbin/chkconfig"
CHMOD_R="/bin/chmod 444"
CHMOD_X="/bin/chmod 755"
CHOWN="/bin/chown -R $OCTO:$OCTO"
CP="/bin/cp -f"
ECHO="/bin/echo"
FIND="/usr/bin/find"
LN="/bin/ln -f -s"
MKDIR="/bin/mkdir -p"
MKFIFO="/usr/bin/mkfifo"
RC_UPDATE="rc-update"
SED="/bin/sed -i -e"
USERMOD="/usr/sbin/usermod -g"
DIR_FIFO="/var/spool/octopussy/"
FILE_FIFO="/var/spool/octopussy/octo_fifo"
DIR_PERL=`perl -MConfig -e 'print $Config::Config{installsitelib}'`;


#
# Display information (requirements, ...)
#
$CAT LINUX/README.txt
sleep 2

#
# Backups Octopussy configuration on upgrade
#
OCTO_TOOL="/usr/sbin/octo_tool"
if [ -x $OCTO_TOOL ]; then
	$OCTO_TOOL backup '/etc/octopussy/octopussy_ugrade_backup' >/dev/null 2>&1
   	$CHOWN /etc/octopussy/octopussy_ugrade_backup*.tgz >/dev/null 2>&1
fi

#
# Add User & Group Octopussy
#
$ECHO "Adding octopussy user & group..."
if id $OCTO >/dev/null 2>&1 ; then
  if [ `id $OCTO -g -n` != "$OCTO" ] ; then
    $ADDGROUP $OCTO || true
    $USERMOD $OCTO $OCTO
  fi
else
  $ADDUSER $OCTO
fi

#
# Create Directories & Change Octopussy permission files
#
$ECHO "Creating directories..."
$MKDIR /etc/$AAT/
$MKDIR /etc/$OCTO/
$MKDIR /usr/share/$AAT/
$MKDIR /usr/share/$OCTO/
$MKDIR $DIR_PERL/AAT/
$MKDIR $DIR_PERL/Octopussy/
$MKDIR /var/lib/$OCTO/
$MKDIR /var/run/$AAT/
$MKDIR /var/run/$OCTO/

#
# Copy Files
#
$ECHO "Copying directories & files..."
$CP -r --preserve=mode bin/* /usr/sbin/
$CHOWN /usr/sbin/octo* || true
$CP -r etc/* /etc/
$CP -r usr/share/$AAT/* /usr/share/$AAT/
$CP -r usr/share/$OCTO/* /usr/share/$OCTO/
$CHOWN /etc/$AAT/ /etc/$OCTO/ /usr/share/$AAT/ /usr/share/$OCTO/ || true
$CP -r var/lib/$OCTO/* /var/lib/$OCTO/
$CHOWN /var/lib/$OCTO/ /var/run/$AAT/ /var/run/$OCTO/ || true
$CP -r lib/AAT* lib/Octo* $DIR_PERL/
$CHMOD_R $DIR_PERL/AAT.pm $DIR_PERL/Octopussy.pm
$FIND $DIR_PERL/AAT/ -name *.pm -exec $CHMOD_R {} \;
$FIND $DIR_PERL/Octopussy/ -name *.pm -exec $CHMOD_R {} \;
$FIND $DIR_PERL/AAT/ -type d -exec $CHMOD_X {} \;
$FIND $DIR_PERL/Octopussy/ -type d -exec $CHMOD_X {} \;

#
# Add octo_logrotate to cron.daily
#
$ECHO "#!/bin/sh" > $CRON_FILE
$ECHO "" >> $CRON_FILE
$ECHO "test -x /usr/sbin/octo_logrotate || exit 0" >> $CRON_FILE
$ECHO "sudo -u octopussy /usr/sbin/octo_logrotate --quiet" >> $CRON_FILE
$CHMOD_X $CRON_FILE

#
# Create init files
#
$LN /usr/sbin/$OCTO /etc/init.d/$OCTO || true

# RH Like
if [ -e "$CHKCONFIG" ]; then
	$CHKCONFIG --add $OCTO || true
	$CHKCONFIG --level 2345 $OCTO on
	$CHKCONFIG --add rsyslog || true
	$CHKCONFIG --level 2345 rsyslog on
fi
# Gentoo Like
if [ -e "$RC_UPDATE" ]; then
	$RC_UPDATE --add $OCTO default || true
fi

#
# Apache2 Configuration
#
$ECHO "Configuring Apache..."
$MKDIR /var/cache/$OCTO/asp/
$CHOWN /var/cache/$OCTO/asp/
$LN /usr/share/$AAT/ /usr/share/$OCTO/AAT
$MKDIR /var/lib/$OCTO/rrd_png/
$CHOWN /var/lib/$OCTO/rrd_png/
$LN /var/lib/$OCTO/rrd_png/ /usr/share/$OCTO/rrd 

# Patch Apache::ASP::StateManager for HttpOnly cookie flag
file_to_patch=$( find / -name StateManager.pm | grep "Apache/ASP" )
patch $file_to_patch < LINUX/apache-asp-statemanager.patch

#
# Octopussy FIFO creation (for Rsyslog)
#
$ECHO "Creating FIFO..."
$MKDIR $DIR_FIFO
$MKFIFO $FILE_FIFO
$CHOWN $DIR_FIFO

#
# Create Octopussy MySQL Database with file 'OCTOPUSSY.sql'
#
$ECHO "Preparing MySQL Database..."
/usr/bin/mysql -u root -p < LINUX/OCTOPUSSY.sql

#
# Generates Certificate for Octopussy WebServer
#
$ECHO "Generating Certificate for Octopussy WebServer..."
openssl genrsa > /etc/octopussy/server.key
openssl req -new -x509 -nodes -sha1 -days 365 -key /etc/octopussy/server.key > /etc/octopussy/server.crt
$CHOWN /etc/octopussy/

#
# Restart Octopussy & Rsyslog
#
$ECHO "Restarting Octopussy & Rsyslog..."
$SED 's/^\$ActionFileDefaultTemplate *RSYSLOG_TraditionalFileFormat/#\$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat/' /etc/rsyslog.conf
$SED 's/# *\$ModLoad *imudp/\$ModLoad imudp/' /etc/rsyslog.conf
$SED 's/# *\$UDPServerRun *514/\$UDPServerRun 514/' /etc/rsyslog.conf
$SED 's/# *\$ModLoad *imtcp/\$ModLoad imtcp/' /etc/rsyslog.conf
$SED 's/# *\$InputTCPServerRun *514/\$InputTCPServerRun 514/' /etc/rsyslog.conf

/etc/init.d/octopussy restart
/etc/init.d/syslog stop
/etc/init.d/rsyslog restart
