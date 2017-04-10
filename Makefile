# Copyright (c) Trainline Limited, 2016. All rights reserved. See LICENSE.txt in the project root for license information.
# variables accepted:
# OS_FLAVOUR if not specified it is autodetected, valid options are debian or redhat
# SYSTEMCTL_ENABLE allows makefile to configure systemctl services related to upstreamr, valid options are true or false

VERSION = 1.0.2

TEMPDIR := $(shell mktemp -d)

# Detect OS_FLAVOUR
ifeq ($(OS_FLAVOUR),)
ifneq ("$(wildcard /lib/systemd/system)","")
ifneq ("$(wildcard /etc/lsb-release)","")
	OS_FLAVOUR = debian
else ifneq ("$(wildcard /etc/redhat-release)","")
	OS_FLAVOUR = redhat
else
	$(error OS_FLAVOUR cannot be detected, please specify redhat or debian)
endif
endif
endif

# Detect SYSTEMCTL_ENABLE
ifeq ($(SYSTEMCTL_ENABLE),)
	SYSTEMCTL_ENABLE = true
endif

# Set where systemctl is and detect if its present
ifeq ($(SYSTEMCTL_ENABLE),true)
ifeq ($(OS_FLAVOUR),debian)
	SYSTEMCTL = /bin/systemctl
else ifeq ($(OS_FLAVOUR),redhat)
	SYSTEMCTL = /usr/bin/systemctl
endif
ifneq ("$(wildcard $(SYSTEMCTL))", "")
	SYSTEMCTL_PRESENT = true
endif
endif

# Determine packaging name
ifneq ($(PACKAGE_BRANCH),)
	PACKAGE_NAME = upstreamr-$(PACKAGE_BRANCH)
else
	PACKAGE_NAME = upstreamr
endif

init:
	pip install -r requirements.txt

install:
	test -d $(DESTDIR)/usr/sbin || mkdir -p $(DESTDIR)/usr/sbin
	install -m 0755 upstreamr/upstreamr $(DESTDIR)/usr/sbin/upstreamr
	test -d $(DESTDIR)/etc/upstreamr || mkdir -p $(DESTDIR)/etc/upstreamr
	test -d $(DESTDIR)/etc/upstreamr/templates || mkdir -p $(DESTDIR)/etc/upstreamr/templates
	test -d $(DESTDIR)/lib/systemd/system || mkdir -p $(DESTDIR)/lib/systemd/system
	install -m 0644 systemd/upstreamr.service.systemd.$(OS_FLAVOUR) $(DESTDIR)/lib/systemd/system/upstreamr.service
ifneq ($(SYSTEMCTL_PRESENT),)
	$(SYSTEMCTL) enable upstreamr
endif

package:
	$(info Packaging uses fpm)
	$(MAKE) install OS_FLAVOUR=$(OS_FLAVOUR) DESTDIR=$(TEMPDIR) SYSTEMCTL_ENABLE=false
ifeq ($(OS_FLAVOUR),debian)
	fpm -s dir -t deb -a all -n $(PACKAGE_NAME) -v $(VERSION) --iteration 1 --after-install packaging/after-install-$(OS_FLAVOUR).sh --before-remove packaging/before-remove-$(OS_FLAVOUR).sh --description "Rapid templating manager" --deb-user root --deb-group root --depends "python-environment_manager" --depends "python-boto" --depends "python-six" --depends "python-jinja2" --depends "python-dnspython" --depends "python-requests" --prefix / -C $(TEPMPDIR)
else ifeq ($(OS_FLAVOUR),redhat)
	fpm -s dir -t rpm -a all -n $(PACKAGE_NAME) -v $(VERSION) --iteration 1 --after-install packaging/after-install-$(OS_FLAVOUR).sh --before-remove packaging/before-remove-$(OS_FLAVOUR).sh --description "Rapid templating manager" --rpm-os linux --rpm-user root --rpm-group root --depends "python-environment_manager" --depends "python-dns" --depends "python-jinja2" --depends "python-boto" --prefix / -C $(TEMPDIR)
endif

all: init install

clean:
ifneq ("$(wildcard $(DESTDIR)/lib/systemd/system)", "")
ifneq ($(SYSTEMCTL_PRESENT),)
	$(SYSTEMCTL) stop upstreamr
	$(SYSTEMCTL) disable upstreamr
endif
	rm -f $(DESTDIR)/lib/systemd/system/upstreamr.service
endif
	rm -rf $(DESTDIR)/etc/upstreamr
	rm -f $(DESTDIR)/usr/sbin/upstreamr
