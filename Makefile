# Copyright (c) Trainline Limited 2016. All rights reserved. See LICENSE.txt in the project root for license information.

init:
	pip install -r requirements.txt

install:
	install -m 0755 src/upstreamr /usr/sbin/upstreamr
	test -d /etc/upstreamr || mkdir /etc/upstreamr
	test -d /etc/upstreamr/templates || mkdir /etc/upstreamr/templates
	ifneq ("$(wildcard /lib/systemd/system)","")
		ifneq ("$(wildcard /etc/lsb-release)","")
			$(info Installing startup file for Debian/Ubuntu)
			install -m 0644 systemd/upstreamr.service.systemd.debian /lib/systemd/system/upstreamr.service
			systemctl enable upstreamr
		else ifneq ("$(wildcard /etc/redhat-release)","")
			$(info Installing startup file for RedHat compatible distros)
			install -m 0644 systemd/upstreamr.service.systemd.redhat /lib/systemd/system/upstreamr.service
			systemctl enable upstreamr
		else
			$(info System not supported, no startup file for you, sorry)
		endif
	else
		$(info No systemd detected, we dont have a startup file for you, sorry)
	endif

all: init install

clean:
	ifneq ("$(wildcard /lib/systemd/system)","")
		systemctl stop upstreamr
		systemctl disable upstreamr
		rm -f /lib/systemd/system/upstreamr.service
	endif
	rm -rf /etc/upstreamr
	rm -f /usr/sbin/upstreamr
