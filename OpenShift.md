Octopussy 2.0 demo on OpenShift
===============================

# Configuration

## OpenShift configuration 

### Perl

Octopussy 2.0 requires Mojolicious so we need a newer Perl version:

```shell
cd ~/app-root/data/
mkdir download
cd download
wget -c -nd http://www.cpan.org/src/5.0/perl-5.18.4.tar.gz
tar -xf perl-5.18.4.tar.gz
cd perl-5.18.4
./Configure -des -Dprefix=~/perl
make && make install
```

```shell
cpan install App::cpanminus

cpanm --force IO::Socket::IP
cpanm Time::HiRes

cpanm Mojolicious
```

### OpenShift Hooks

## Git configuration

I need to `git push` on Github and on OpenShift:
```
git remote set-url origin --push --add ssh://54823b5de0b8cd0fcd00014a@webconsole-octopussy.rhcloud.com/~/git/webconsole.git/
git remote set-url origin --push --add ssh://54824468e0b8cd9b0c0001b3@api-octopussy.rhcloud.com/~/git/api.git/
```
