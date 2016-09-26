## Upstreamr

### Introduction

Upstreamr is a rapid templating engine which complements [Environment Manager](https://github.com/trainline/environment-manager), it reads from the same sources as Environment Manager itself and is capable of generating templates for application configuration and can also reload services on trigger demand.

At [Trainline](https://github.com/trainline/) we use Upstreamr for configuring nginx instances based on Environment Manager deployments.

We support Upstreamr both in RedHat compatible distros and also in Debian/Ubuntu compatible distros, as we run a mixed environment.

### Install

All Upstreamr dependencies can be run by just running `make install`, its that easy!

### Configuration

Upstreamr looks by default for its configuration in `/etc/upstreamr/upstreamr.conf`, there is an example file heavily commented in the repository [here](https://github.com/trainline/upstreamr/tree/master/conf/upstreamr.conf), go have a look.

### Running

To run upstreamr you can either let systemd handle it for you

``` systemctl start upstreamr ```

Or run it manually

``` /usr/sbin/upstreamr -c /etc/upstreamr/upstreamr.conf ```

You can also run it in debug mode

``` /usr/sbin/upstreamr -c /etc/upstreamr/upstreamr.conf --debug ```

All logs will be generated automatically in `/var/log/upstreamr.log`

### Issues

For any issues please feel free to report in our repository [here](https://github.com/trainline/upstreamr/issues), if you send us a pull request you'll make us happy! :+1:

### Acknowledgements

Upstreamr is :copyright: Trainline Limited. All Rights reserved. Released under the Apache 2.0 license (see [LICENSE.txt](https://github.com/trainline/upstreamr/tree/master/LICENSE.txt) in our repository).

We would like to thank our collaborators:
  + [Marc Cluet](https://github.com/lynxman)
  + [Stuart Macleod](https://github.com/stuartio)
