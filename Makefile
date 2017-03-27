# Copyright (c) Trainline Limited, 2016. All rights reserved. See LICENSE.txt in the project root for license information.
# variables accepted:
# OS_FLAVOUR if not specified it is autodetected, valid options are debian or redhat
# SYSTEMCTL_ENABLE allows makefile to configure systemctl services related to upstreamr, valid options are true or false

# Detect OS_FLAVOUR
ifeq ($(OS_FLAVOUR),)
ifneq ("$(wildcard /lib/systemd/system)","")
ifneq ("$(wildcard /etc/lsb-release)","")
	OS_FLAVOUR = debian
else ifneq ("$(wildcard /etc/redhat-release)","")
	OS_FLAVOUR = redhat
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
