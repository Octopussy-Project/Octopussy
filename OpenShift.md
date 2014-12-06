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
wget -c -nd http://www.cpan.org/src/5.0/perl-perl-5.16.3.tar.gz
tar -xf perl-perl-5.16.3.tar.gz
cd perl-perl-5.16.3
./Configure -des -Dprefix=~/app-root/data/perl-5.16.3
make
make install
```

```shell
cd ~/app-root/data/perl-5.16.3/bin
HOME=~/app-root/data/ 
./perl cpan App::cpanminus

./cpanm --force IO::Socket::IP
./cpanm Time::HiRes
./cpanm --force Mojolicious
```

### OpenShift Hooks

## Git configuration

I need to `git push` on Github and on OpenShift:
```
git remote set-url origin --push --add ssh://54823b5de0b8cd0fcd00014a@webconsole-octopussy.rhcloud.com/~/git/webconsole.git/
git remote set-url origin --push --add ssh://54824468e0b8cd9b0c0001b3@api-octopussy.rhcloud.com/~/git/api.git/
```
