#!/usr/bin/perl

=head1 NAME

packaging_from_git.pl

=head1 DESCRIPTION

Program to create packages (.tar.gz & .deb) from GIT repository

=cut

use strict;
use warnings;

use File::Find;
use File::Path qw( make_path rmtree);
use File::Spec::Functions qw( catfile );

my $PACKAGE             = 'octopussy';
my $BIN_POD2MAN         = '/usr/bin/pod2man';
my $DIR_TMP             = 'tmp_debian_pkg';
my $DIR_AAT_PM          = 'usr/share/perl5/AAT/';
my $DIR_OCTO_PM         = 'usr/share/perl5/Octopussy/';
my $FILE_OCTOPUSSY_PM   = './usr/share/perl5/Octopussy.pm';
my $FILE_DEBIAN_CONTROL = "DEBIAN/control";

=head1 SUBROUTINES/METHODS

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
	make_path("$DIR_TMP/usr/share/doc/$PACKAGE/");
	`cat ./changelog | gzip -9 > $DIR_TMP/usr/share/doc/$PACKAGE/changelog.gz`;
	`cat ./changelog | gzip -9 > $DIR_TMP/usr/share/doc/$PACKAGE/changelog.Debian.gz`;
}

=head2 Copy_Files()

Copy files from SVN to temporary Debian packaging directory

=cut

sub Copy_Files
{
 	`git archive master DEBIAN/ usr/share/perl5/ etc/ var/lib/octopussy/conf/ usr/sbin/ usr/share/ | tar -x -C $DIR_TMP/`;

	foreach my $d ('alerts', 'contacts', 'devices', 'maps', 'search_templates')
	{
		make_path("$DIR_TMP/var/lib/octopussy/conf/$d/");
	}
	`cp ./copyright $DIR_TMP/usr/share/doc/$PACKAGE/`;

	`mv $DIR_TMP/etc/$PACKAGE/apache2_debian.conf $DIR_TMP/etc/$PACKAGE/apache2.conf`;
	`mv $DIR_TMP/etc/$PACKAGE/apache2_other.conf LINUX/apache2.conf`;

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
	make_path("$DIR_TMP/usr/share/man/man1/");
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
	make_path("$DIR_TMP/usr/share/man/man3/");
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
