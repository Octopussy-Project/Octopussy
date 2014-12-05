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
wget -c -nd http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz
tar -xf perl-5.16.3.tar.gz
cd perl-5.16.3
./Configure -des -Dprefix=~/app-root/data/perl-new
make
make install
```

### OpenShift Hooks

## Git configuration

I need to `git push` on Github and on OpenShift:

```

```
