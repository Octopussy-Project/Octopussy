#!/bin/sh

AAT="aat"
OCTO="octopussy"
CRON_FILE="/etc/cron.daily/octo_logrotate"

ADDGROUP="/usr/sbin/addgroup --system"
ADDUSER="/usr/sbin/adduser --system --disabled-password --no-create-home"
CAT="/bin/cat"
CHKCONFIG="/sbin/chkconfig"
CHMOD_X="/bin/chmod 755"
CHOWN="/bin/chown -R $OCTO:$OCTO"
CP="/bin/cp -f"
ECHO="/bin/echo"
LN="/bin/ln -f -s"
MKDIR="/bin/mkdir -p"
MKFIFO="/usr/bin/mkfifo"
MYSQL_OCTO="/usr/bin/mysql -u root -p < OCTOPUSSY.sql"
RC_UPDATE="rc-update"
SED="/bin/sed -i"
USERMOD="/usr/sbin/usermod -g"
DIR_FIFO="/var/spool/octopussy/"
FILE_FIFO="/var/spool/octopussy/octo_fifo"

$CAT README.txt
#
# Add User & Group Octopussy
#
if id $OCTO >/dev/null 2>&1 ; then
  if [ `id $OCTO -g -n` != "$OCTO" ] ; then
    $ADDGROUP $OCTO || true
    $USERMOD $OCTO $OCTO
  fi
else
  $ADDUSER --group --quiet $OCTO
fi

#
# Create Directories & Change Octopussy permission files
#
$MKDIR /etc/$AAT/
$MKDIR /etc/$OCTO/
$MKDIR /usr/share/$AAT/
$MKDIR /usr/share/$OCTO/
$MKDIR /usr/share/perl5/AAT/
$MKDIR /usr/share/perl5/Octopussy/
$MKDIR /var/lib/$OCTO/
$MKDIR /var/run/$AAT/
$MKDIR /var/run/$OCTO/
$CHOWN /etc/$AAT/ /etc/$OCTO/ /usr/share/$OCTO/ /usr/sbin/octo* || true
$CHOWN /var/lib/$OCTO/ /var/run/$AAT/ /var/run/$OCTO/ || true

#
# Copy Files
#
$CP -r etc/* /etc/
$CP -r usr/sbin/* /usr/sbin/
$CP -r usr/share/$AAT/* /usr/share/$AAT/
$CP -r usr/share/$OCTO/* /usr/share/$OCTO/
$CP -r usr/share/perl5/AAT* usr/share/perl5/Octo* /usr/share/perl5/
$CP -r var/lib/$OCTO/* /var/lib/$OCTO/

#
# Create Octopussy MySQL Database with file 'OCTOPUSSY.sql'
#
$MYSQL_OCTO

#
# Add octo_logrotate to cron.daily
#
$ECHO "#!/bin/sh" > $CRON_FILE
$ECHO "" >> $CRON_FILE
$ECHO "test -x /usr/sbin/octo_logrotate || exit 0" >> $CRON_FILE
$ECHO "sudo -u octopussy /usr/sbin/octo_logrotate" >> $CRON_FILE
$CHMOD_X $CRON_FILE

#
# Create init files
#
$LN /usr/sbin/$OCTO /etc/init.d/$OCTO || true

# RH Like
if [ -e "$CHKCONFIG" ]; then
	$CHKCONFIG --add $OCTO || true
fi
# Gentoo Like
if [ -e "$RC_UPDATE" ]; then
	$RC_UPDATE --add $OCTO default || true
fi

#
# Apache2 Configuration
#
$MKDIR /var/cache/$OCTO/asp/
$CHOWN /var/cache/$OCTO/asp/
$LN /usr/share/$AAT/ /usr/share/$OCTO/AAT

#
# Octopussy FIFO creation (for Rsyslog)
#
$MKDIR $DIR_FIFO
$MKFIFO $FILE_FIFO
$CHOWNR $DIR_FIFO

#
# Restart Octopussy & Rsyslog
#
/etc/init.d/octopussy restart
/etc/init.d/rsyslog restart

exit 0
