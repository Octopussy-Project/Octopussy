#!/usr/bin/perl -w

=head1 NAME

packaging_from_svn.pl - Program to create packages from SVN repository

=cut

use strict;
use warnings;
use Readonly;

use File::Find;
use File::Path;
use File::Spec::Functions qw( catfile );

Readonly my $PACKAGE             => 'octopussy';
Readonly my $BIN_POD2MAN         => '/usr/bin/pod2man';
Readonly my $DIR_TMP             => 'tmp_debian_pkg';
Readonly my $DIR_AAT_PM          => 'usr/share/perl5/AAT/';
Readonly my $DIR_OCTO_PM         => 'usr/share/perl5/Octopussy/';
Readonly my $FILE_OCTOPUSSY_PM   => './usr/share/perl5/Octopussy.pm';
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
		return ($1) if ( $_ =~ /Octopussy::VERSION\s*=\s*'(.+)';/ );
	}
	close $FILE;

	return (undef);
}

=head2 Changelog()

Generates /usr/share/doc/octopussy/changelog.gz file from changelog file

=cut

sub Changelog
{
	printf "Generating changelog file...\n";
	mkpath("$DIR_TMP/usr/share/doc/$PACKAGE/");
	`cat ./changelog | gzip -9 > $DIR_TMP/usr/share/doc/$PACKAGE/changelog.gz`;
	`cat ./changelog | gzip -9 > $DIR_TMP/usr/share/doc/$PACKAGE/changelog.Debian.gz`;
}

=head2 Copy_Files()

Copy files from SVN to temporary Debian packaging directory

=cut

sub Copy_Files
{
	`cp ./copyright $DIR_TMP/usr/share/doc/$PACKAGE/`;

	printf "Copying Debian packaging files...\n";
	`svn export ./DEBIAN/ $DIR_TMP/DEBIAN/`;

	printf "Copying Perl modules...\n";
	`svn export ./usr/share/perl5/ $DIR_TMP/usr/share/perl5/`;

	printf "Copying Configuration files...\n";
	`svn export ./etc/ $DIR_TMP/etc/`;

	mkpath("$DIR_TMP/var/lib/$PACKAGE/");
	`svn export ./var/lib/$PACKAGE/conf/ $DIR_TMP/var/lib/$PACKAGE/conf/`;

	`mv $DIR_TMP/etc/$PACKAGE/apache2_debian.conf $DIR_TMP/etc/$PACKAGE/apache2.conf`;
	`mv $DIR_TMP/etc/$PACKAGE/apache2_other.conf LINUX/apache2.conf`;

	printf "Copying Program files...\n";
	`svn export ./usr/sbin/ $DIR_TMP/usr/sbin/`;

	printf "Copying WebSite files...\n";
	`svn export ./usr/share/aat/ $DIR_TMP/usr/share/aat/`;
	`svn export ./usr/share/$PACKAGE/ $DIR_TMP/usr/share/$PACKAGE/`;

	`rm -rf $DIR_TMP/var/lib/$PACKAGE/conf/{devicegroups,locations,schedule,servicegroups}.xml`;

    `find $DIR_TMP/ -type d -print0 | xargs -0 chmod 755`;
    `find $DIR_TMP/ -type f -print0 | xargs -0 chmod 644`;
    `chmod 755 $DIR_TMP/DEBIAN/config $DIR_TMP/DEBIAN/control`;
    `chmod 755 $DIR_TMP/DEBIAN/post*`;
    `chmod 755 $DIR_TMP/DEBIAN/pre*`;
    `chmod 755 $DIR_TMP/usr/sbin/*`;
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
   	`chmod 644 $DIR_TMP/usr/share/man/man1/*.gz`;

	printf "Generating man(3) pages...\n";
	mkpath("$DIR_TMP/usr/share/man/man3/");
	`$BIN_POD2MAN ${DIR_AAT_PM}../AAT.pm | gzip -9 > $DIR_TMP/usr/share/man/man3/AAT.3pm.gz`;
	opendir $DIR, $DIR_AAT_PM;
	my @mods = grep /\.pm$/, readdir $DIR;
	closedir $DIR;
	foreach my $mod (@mods)
	{
		my $dst = $mod;
		$dst =~ s/\.pm$/\.3pm/;
	  	`$BIN_POD2MAN $DIR_AAT_PM$mod | gzip -9 > $DIR_TMP/usr/share/man/man3/AAT::$dst.gz`;
	}

	`$BIN_POD2MAN ${DIR_OCTO_PM}../Octopussy.pm | gzip -9 > $DIR_TMP/usr/share/man/man3/Octopussy.3pm.gz`;
	opendir $DIR, $DIR_OCTO_PM;
	@mods = grep /\.pm$/, readdir $DIR;
	closedir $DIR;
	foreach my $mod (@mods)
	{
		my $dst = $mod;
		$dst =~ s/\.pm$/\.3pm/;
		`$BIN_POD2MAN $DIR_OCTO_PM$mod | gzip -9 > $DIR_TMP/usr/share/man/man3/Octopussy::$dst.gz`;
	}
	opendir $DIR, "${DIR_OCTO_PM}Report/";
    @mods = grep /\.pm$/, readdir $DIR;
    closedir $DIR;
    foreach my $mod (@mods)
    {
        my $dst = $mod;
        $dst =~ s/\.pm$/\.3pm/;
        `$BIN_POD2MAN ${DIR_OCTO_PM}Report/$mod | gzip -9 > $DIR_TMP/usr/share/man/man3/Octopussy::Report::$dst.gz`;
    }
 	`chmod 644 $DIR_TMP/usr/share/man/man3/*.gz`;
}

# ===== MAIN ===== #

my $version      = Octopussy_Version();
my $filename_pkg = "${PACKAGE}_${version}_all.deb";

# Removes old packaging stuff
rmtree($DIR_TMP);
unlink $filename_pkg;

Man();
Changelog();
Copy_Files();

`perl -i -p -e 's/^Version:.*/Version: $version/' ./$FILE_DEBIAN_CONTROL`;
#`sed -i "s/^Version:.*/Version: $version/" ./$FILE_DEBIAN_CONTROL`;
`dpkg-deb --build $DIR_TMP $filename_pkg`;
printf(">>> Package Debian: %s\n", $filename_pkg);

rmtree("$DIR_TMP/DEBIAN");
`mv $DIR_TMP octopussy`;
`cp ./LINUX/INSTALL.sh ./LINUX/OCTOPUSSY.sql ./LINUX/README.txt octopussy/`;
`mv -f ./LINUX/apache2.conf octopussy/etc/octopussy/apache2.conf`;
`chmod 755 octopussy/INSTALL.sh`;
`tar cvfz octopussy-$version.tar.gz octopussy/`;
printf(">>> Package generic: %s\n", "octopussy-$version.tar.gz");

rmtree($DIR_TMP);
rmtree('octopussy');

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
