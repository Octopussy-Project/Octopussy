#!/usr/bin/perl -w

=head1 NAME

packaging_svn2debian.pl - Program to create Debian package from SVN repository

=cut

use strict;
use Readonly;

use File::Path;

Readonly my $PACKAGE => 'octopussy';
Readonly my $BIN_POD2MAN => '/usr/bin/pod2man';
Readonly my $DIR_TMP => 'tmp_debian_pkg';
Readonly my $DIR_AAT_PM => 'usr/share/perl5/AAT/';
Readonly my $DIR_OCTO_PM => 'usr/share/perl5/Octopussy/';
Readonly my $FILE_OCTOPUSSY_PM => './usr/share/perl5/Octopussy.pm';
Readonly my $FILE_DEBIAN_CONTROL => "DEBIAN/control";

=head1 PROCEDURES

=head2 Octopussy_Version()

Returns Octopussy version from Octopussy.pm source file

=cut

sub Octopussy_Version
{
  open my $FILE, '<', $FILE_OCTOPUSSY_PM or die @_;
  while (<$FILE>)
  {
    return ($1) if ($_ =~ /Octopussy::VERSION = qv\('(.+)'\);/);
  }
  close $FILE;

  return (undef);
}


=head2 Copy_Files

Copy files from SVN to temporary Debian packaging directory

=cut

sub Copy_Files
{
  printf "Copying Debian packaging files...\n";
  mkpath("$DIR_TMP/DEBIAN/");
  `cp -R ./DEBIAN/* $DIR_TMP/DEBIAN/`;
  `chmod 755 $DIR_TMP/DEBIAN/`;
  `chmod 555 $DIR_TMP/DEBIAN/{post,pre}{inst,rm}`;

  printf "Copying Perl modules...\n";
  mkpath("$DIR_TMP/usr/share/perl5/");
  `cp -R ./usr/share/perl5/AAT* $DIR_TMP/usr/share/perl5/`;
  `cp -R ./usr/share/perl5/Octopussy* $DIR_TMP/usr/share/perl5/`;
  
  printf "Copying Configuration files...\n";
  mkpath("$DIR_TMP/etc/aat/");
  mkpath("$DIR_TMP/etc/$PACKAGE/");
  mkpath("$DIR_TMP/var/lib/$PACKAGE/conf/");
  `cp -R ./etc/aat/* $DIR_TMP/etc/aat/`;
  `cp -R ./etc/$PACKAGE/* $DIR_TMP/etc/$PACKAGE/`;
  `cp -R ./var/lib/$PACKAGE/conf/* $DIR_TMP/var/lib/$PACKAGE/conf/`;
}


=head2 Man()

Generates manual pages from POD information source files

=cut

sub Man
{
  printf "Generating man(1) pages...\n";
  mkpath("$DIR_TMP/usr/share/man/man1/");
  `$BIN_POD2MAN ./usr/sbin/$PACKAGE | gzip -9 > $DIR_TMP/usr/share/man/man1/$PACKAGE.1.gz`;
  opendir my $DIR, './usr/sbin/';
  my @octo_bins = grep /^octo_/, readdir $DIR;
  closedir $DIR;
  foreach my $bin (@octo_bins)
  {
    `$BIN_POD2MAN ./usr/sbin/$bin | gzip -9 > $DIR_TMP/usr/share/man/man1/${bin}.1.gz`;
  }

  printf "Generating man(3) pages...\n";
  mkpath("$DIR_TMP/usr/share/man/man3/");
  `$BIN_POD2MAN ${DIR_AAT_PM}../AAT.pm | gzip -9 > $DIR_TMP/usr/share/man/man3/AAT.3.gz`;
  opendir $DIR, $DIR_AAT_PM;
  my @mods = grep /\.pm$/, readdir $DIR;
  closedir $DIR;
  foreach my $mod (@mods)
  {
    my $dst = $mod;
    $dst =~ s/\.pm$/\.3/;
    `$BIN_POD2MAN $DIR_AAT_PM$mod | gzip -9 > $DIR_TMP/usr/share/man/man3/$dst.gz`;
  }

  `$BIN_POD2MAN ${DIR_OCTO_PM}../Octopussy.pm | gzip -9 > $DIR_TMP/usr/share/man/man3/Octopussy.3.gz`;
  opendir $DIR, $DIR_OCTO_PM;
  @mods = grep /\.pm$/, readdir $DIR;
  closedir $DIR;
  foreach my $mod (@mods)
  {
    my $dst = $mod;
    $dst =~ s/\.pm$/\.3/;
    `$BIN_POD2MAN $DIR_OCTO_PM$mod | gzip -9 > $DIR_TMP/usr/share/man/man3/$dst.gz`;  
  } 
}


=head2 MAIN

=cut

my $version = Octopussy_Version();
my $filename_pkg = "${PACKAGE}_${version}_all.deb";

rmtree($DIR_TMP);
Man();
Copy_Files();

`sed -i "s/^Version:.*/Version: $version/" ./$FILE_DEBIAN_CONTROL`;
`dpkg-deb --build $DIR_TMP`;
#`fakeroot dpkg-deb --build $DIR`;
`mv ${DIR_TMP}.deb $filename_pkg`;

=head2 TODO

my $OCTO_DOC = "octopussy_doc";
my $FILE_CHANGELOG = "$DIR/usr/share/doc/$PACKAGE/changelog.gz";

# Function: Changelog()
sub Changelog
{
	`cp $OCTO_DOC/changelog $OCTO_DOC/changelog.tmp`;
  `rm -f $OCTO_DOC/changelog.tmp.gz`;
	`gzip -9 $OCTO_DOC/changelog.tmp`;
	`mv $OCTO_DOC/changelog.tmp.gz $DIR/usr/share/doc/$PACKAGE/changelog.gz`;
}

# CREATING DIRECTORIES
`mkdir -p $DIR/etc/rsyslog.d/`;
`mkdir -p $DIR/usr/sbin/`;
`mkdir -p $DIR/usr/share/$AAT/`;
`mkdir -p $DIR/usr/share/$PACKAGE/`;

# COPYING FILES
`cp /etc/rsyslog.d/$PACKAGE.conf $DIR/etc/rsyslog.d/`;
`chmod -R 644 $DIR/etc/rsyslog.d/ $DIR/etc/$PACKAGE/`;
`cp /usr/sbin/octo* $DIR/usr/sbin/`;
`cp -R /usr/share/$AAT/* $DIR/usr/share/$AAT/`;
`cp -R /usr/share/$PACKAGE/* $DIR/usr/share/$PACKAGE/`;

# Exclude 'private' data
`rm -rf $DIR/etc/$PACKAGE/backup*`;
`rm -rf $DIR/etc/$PACKAGE/CA/`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/alerts/*`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/contacts/*`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/devices/*`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/maps/*`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/reports/*`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/search_templates/*`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/{devicegroups,locations,schedule,servicegroups}.xml`;
`rm -rf $DIR/usr/share/$PACKAGE/rrd/*`;
#`rm -rf $DIR/usr/share/$PACKAGE/JS/*`;
# no Catalyst for now
`rm -rf $DIR/usr/share/$PACKAGE/console/`;


# COPYING REPORTS
`cp -R /var/lib/$PACKAGE/conf/reports/Bind* $DIR/var/lib/$PACKAGE/conf/reports/`;

# Exclude 'private' 'CA_*' data
`rm -rf $DIR/usr/share/perl5/Octopussy/Plugin/CA_*`;
`rm -rf $DIR/usr/share/perl5/Octopussy/Plugin/DenyAll*`;
`rm -rf $DIR/var/lib/$PACKAGE/conf/{plugins,services,tables}/CA_*.xml`;
`rm -rf $DIR/usr/share/aat/Lists/CA_*.xml`;

#
# BUILDING PACKAGE
#
`chown -R root: $DIR/`; #/usr/share/doc/*`;
#`chown -R root: $DIR/DEBIAN/*`;
`find $DIR/usr/sbin/ -name "octo*" | xargs chmod 750`;
`find $DIR/usr/share/perl5/Octopussy/Plugin/ -name "*" | xargs chmod 644`;
`find $DIR/etc/aat/ -name "*.cnf" | xargs chmod 644`;
`find $DIR -name "*.gz" | xargs chmod 644`;
`find $DIR -name "*.asa" | xargs chmod 644`;
`find $DIR -name "*.asp" | xargs chmod 644`;
`find $DIR -name "*.html" | xargs chmod 644`;
`find $DIR -name "*.js" | xargs chmod 644`;
`find $DIR -name "*.pm" | xargs chmod 644`;
`find $DIR -name "*.css" | xargs chmod 644`;
`find $DIR -name "*.inc" | xargs chmod 644`;
`find $DIR -name "*.gif" | xargs chmod 644`;
`find $DIR -name "*.png" | xargs chmod 644`;
`find $DIR -name "*.xml" -exec chmod 644 \{\} \\;`;
`find $DIR -type d | xargs chmod 755`;

=cut
