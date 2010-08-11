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
MYSQL_OCTO="/usr/bin/mysql -u root -p < OCTOPUSSY.sql"
RC_UPDATE="rc-update"
SED="/bin/sed -i"
USERMOD="/usr/sbin/usermod -g"
DIR_FIFO="/var/spool/octopussy/"
FILE_FIFO="/var/spool/octopussy/octo_fifo"
DIR_PERL=`perl -MConfig -e 'print $Config::Config{installsitelib}'`;


#
# Display information (requirements, ...)
#
$CAT README.txt
sleep 3

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
$ECHO "Creating directories & changing permissions"
$MKDIR /etc/$AAT/
$MKDIR /etc/$OCTO/
$MKDIR /usr/share/$AAT/
$MKDIR /usr/share/$OCTO/
$MKDIR $DIR_PERL/AAT/
$MKDIR $DIR_PERL/Octopussy/
$MKDIR /var/lib/$OCTO/
$MKDIR /var/run/$AAT/
$MKDIR /var/run/$OCTO/
$CHOWN /etc/$AAT/ /etc/$OCTO/ /usr/share/$OCTO/ /usr/sbin/octo* || true
$CHOWN /var/lib/$OCTO/ /var/run/$AAT/ /var/run/$OCTO/ || true

#
# Copy Files
#
$ECHO "Copying directories & files..."
$CP -r etc/* /etc/
$CP -r usr/sbin/* /usr/sbin/
$CP -r usr/share/$AAT/* /usr/share/$AAT/
$CP -r usr/share/$OCTO/* /usr/share/$OCTO/
$CP -r var/lib/$OCTO/* /var/lib/$OCTO/
$CP -r usr/share/perl5/AAT* usr/share/perl5/Octo* $DIR_PERL/
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
$ECHO "Configuring Apache..."
$MKDIR /var/cache/$OCTO/asp/
$CHOWN /var/cache/$OCTO/asp/
$LN /usr/share/$AAT/ /usr/share/$OCTO/AAT

#
# Octopussy FIFO creation (for Rsyslog)
#
$ECHO "Creating FIFO..."
$MKDIR $DIR_FIFO
$MKFIFO $FILE_FIFO
$CHOWN $DIR_FIFO

#
# Restart Octopussy & Rsyslog
#
/etc/init.d/octopussy restart
/etc/init.d/rsyslog restart

#
# Create Octopussy MySQL Database with file 'OCTOPUSSY.sql'
#
$ECHO "Preparing MySQL Database..."
$MYSQL_OCTO
