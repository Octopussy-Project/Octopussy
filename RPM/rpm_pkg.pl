#!/usr/bin/perl -w

use strict;
use Octopussy;
use Readonly;

Readonly my $PACKAGE => "octopussy";
Readonly my $VERSION => Octopussy::Version();
Readonly my $DEBIAN_PKG => "${PACKAGE}_${VERSION}_all.deb";
Readonly my $DIR_RPM => "${PACKAGE}-${VERSION}";
Readonly my $CMD_ALIEN_RPM => "alien --to-rpm --scripts --generate";
Readonly my $CMD_RPM_BUILD => "rpmbuild -bb";

=head2 Changes made to adapt script from Debian to RedHat

  - /usr/sbin/addgroup --system octopussy -> /usr/sbin/groupadd -r octopussy
  - /usr/sbin/adduser --system --disabled-password --no-create-home octopussy -> /usr/sbin/adduser -r -g octopussy octopussy
  - initrc.d -> service
  - updaterc.d -> chkconfig

=cut

Readonly my %SECTION => ( 
  pre => q(
#!/bin/sh -e

OCTO="octopussy"
ADDGROUP="/usr/sbin/groupadd -r"
ADDUSER="/usr/sbin/adduser -r -g"
USERMOD="/usr/sbin/usermod -g"

#
# Add User & Group Octopussy
#
if id $OCTO >/dev/null 2>&1 ; then
  if [ `id $OCTO -g -n` != "$OCTO" ] ; then
    $ADDGROUP $OCTO || true
    $USERMOD $OCTO $OCTO
  fi
else
  $ADDUSER $OCTO $OCTO
fi
),
  
  post => q(

#!/bin/sh -e

AAT="aat"
OCTO="octopussy"
CHMOD="/bin/chmod 644"
CHMOD_X="/bin/chmod 755"
CHOWN="/bin/chown $OCTO:$OCTO"
CHOWNR="/bin/chown -R $OCTO:$OCTO"
CP="/bin/cp -f"
ECHO="/bin/echo"
FIND="/usr/bin/find"
LN="/bin/ln -f -s"
MKDIR="/bin/mkdir -p"
MKFIFO="/usr/bin/mkfifo"
SED="/bin/sed -i"
SERVICE="service"
CHKCONFIG="chkconfig"
DIR_FIFO="/var/spool/octopussy/"
FILE_FIFO="/var/spool/octopussy/octo_fifo"

#
# Create Directories & Change Octopussy permission files
#
$MKDIR /var/lib/$OCTO/
$MKDIR /var/run/$AAT/
$MKDIR /var/run/$OCTO/
$CHOWNR /etc/$AAT/ /etc/$OCTO/ /usr/share/$AAT/ /usr/share/$OCTO/ /usr/sbin/octo
* 2> /dev/null || true
$CHOWN /var/lib/$OCTO/ /var/lib/$OCTO/logs/ 2> /dev/null || true
$CHOWNR /var/lib/$OCTO/{conf,reports,rrd} /var/run/$AAT/ /var/run/$OCTO/ 2> /dev
/null || true
$FIND /usr/share/perl5/AAT* -name "*.pm" |xargs $CHMOD
$FIND /usr/share/perl5/Octopussy* -name "*.pm" |xargs $CHMOD

#
# Create Octopussy MySQL Database
#
db_get octopussy/mysql_root_password && MYSQL="/usr/bin/mysql -u root --password
=$RET --exec"

$MYSQL="CREATE DATABASE IF NOT EXISTS $OCTO" || true
$MYSQL="CREATE TABLE IF NOT EXISTS $OCTO._alerts_ (log_id bigint(20) NOT NULL au
to_increment, alert_id varchar(250) default NULL, status varchar(50) default 'Op
ened', level varchar(50) default NULL, date_time datetime default NULL, device v
archar(250) default NULL, log text default NULL, comment text default NULL, PRIM
ARY KEY(log_id))" || true
$MYSQL="INSERT IGNORE INTO mysql.user (host,user,password, file_priv) values ('l
ocalhost','octopussy',password('octopussy'), 'Y')" || true
$MYSQL="INSERT IGNORE INTO mysql.db (host,user,db,Select_priv,Insert_priv,Update
_priv,Delete_priv,Create_priv,Drop_priv) values ('localhost','octopussy','octopu
ssy','Y','Y','Y','Y','Y','Y')" || true
$MYSQL="FLUSH PRIVILEGES" || true


#
# Add octo_logrotate to cron.daily
#
CRON_FILE="/etc/cron.daily/octo_logrotate"

$ECHO "#!/bin/sh" > $CRON_FILE
$ECHO "" >> $CRON_FILE
$ECHO "test -x /usr/sbin/octo_logrotate || exit 0" >> $CRON_FILE
$ECHO "sudo -u octopussy /usr/sbin/octo_logrotate" >> $CRON_FILE
$CHMOD_X $CRON_FILE 2> /dev/null || true

#
# Create init files
#
$LN /usr/sbin/$OCTO /etc/init.d/$OCTO || true
$CHKCONFIG --add $OCTO || true

#
# Apache2 Configuration
#
$MKDIR /var/cache/$OCTO/asp/
$CHOWNR /var/cache/$OCTO/asp/ 2> /dev/null || true
$LN /usr/share/$AAT/ /usr/share/$OCTO/AAT

#
# Octopussy FIFO creation (for Rsyslog)
#
$MKDIR $DIR_FIFO
$MKFIFO $FILE_FIFO 2> /dev/null || true
$CHOWNR $DIR_FIFO

#
# Restart Octopussy & Rsyslog
#
$SERVICE octopussy start 2> /dev/null || true
$SERVICE rsyslog restart 2> /dev/null || true
  
  ),
  preun => q(

#!/bin/sh -e

OCTO="octopussy"
SERVICE="service"
USERDEL="/usr/sbin/userdel"
GROUPDEL="/usr/sbin/groupdel"

if [ -x "/etc/init.d/$OCTO" ]; then
  $SERVICE $OCTO stop || exit 0
fi

#
# Remove Octopussy User & Group
#
$USERDEL $OCTO || true

  ),
  postun => q(

%postun
#!/bin/sh -e

# Source debconf library.
. /usr/share/debconf/confmodule

OCTO="octopussy"
RM="/bin/rm"

#
# Delete Octopussy MySQL Database
#
db_get octopussy/mysql_root_password
/usr/bin/mysql -u root --password=$RET --exec="DROP DATABASE IF EXISTS $OCTO" ||
 true

#
# Remove octo_logrotate from cron.daily
#
CRON_FILE="/etc/cron.daily/octo_logrotate"

if [ -x "$CRON_FILE" ]; then
  $RM -f $CRON_FILE || true
fi

#
# Remove init files
#
if [ -x "/etc/init.d/octopussy" ]; then
  $CHKCONFIG --del $OCTO || true
  $RM -f /etc/init.d/$OCTO || true
fi

#
# Remove Octopussy directories & files
#
if [ "$1" = "purge" ]; 
then
  $RM -rf /etc/aat/ || true
  $RM -rf /etc/$OCTO/ || true
  $RM -rf /usr/share/aat/ || true
  $RM -rf /usr/share/$OCTO/ || true
  $RM -rf /usr/share/perl5/AAT* || true
  $RM -rf /usr/share/perl5/Octopussy* || true
  $RM -rf /var/cache/$OCTO/ || true
  $RM -rf /var/lib/$OCTO/ || true
  $RM -rf /var/run/aat/ || true
  $RM -rf /var/run/$OCTO/ || true
  $RM -rf /var/spool/$OCTO/ || true
fi

  ),

  );

#
# MAIN
#

# Generate RPM directory structure from Debian package
system "$CMD_ALIEN_RPM $DEBIAN_PKG";

opendir(DIR, $DIR_RPM);
my ($FILE_RPM_SPEC) = grep /.+\.spec/, readdir(DIR);
closedir(DIR);

# Make changes in spec file
if (defined open my $file, '<', "$DIR_RPM/$FILE_RPM_SPEC")
{
  if (defined open my $file_new, '>', "$DIR_RPM/${FILE_RPM_SPEC}.new")
  {
    while (<$file>)
    {
      my $line = $_;
      print $file_new $line; 
      print $file_new $SECTION{$1} if ($line =~ /^%(pre|post)/)  
    }
    close $file_new;
  }
  close $file;
}

# Generate RPM package from RPM directory structure
system "$CMD_RPM_BUILD $DIR_RPM/$FILE_RPM_SPEC";

#system "rm -rf $DIR_RPM/";
