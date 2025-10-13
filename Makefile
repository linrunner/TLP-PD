# Makefile for TLP-PD
# Copyright (c) 2025 Thomas Koch <linrunner at gmx.net> and others.
# SPDX-License-Identifier: GPL-2.0-or-later
TLPVER := $(shell read _ver _dummy < ./VERSION; printf '%s' "$${_ver:-undef}")
ifneq (,$(shell which git 2> /dev/null))
	ifneq (,$(shell echo "$(TLPVER)" | grep -E 'alpha|beta'))
		COMMIT_ID := $(shell git rev-parse --short HEAD 2> /dev/null)
		ifneq (,$(COMMIT_ID))
			TLPVER := $(TLPVER)_$(COMMIT_ID)
		endif
	endif
endif

# Evaluate parameters
TLP_SBIN    ?= /usr/sbin
TLP_BIN     ?= /usr/bin
TLP_TLIB    ?= /usr/share/tlp
TLP_FLIB    ?= /usr/share/tlp/func.d
TLP_ULIB    ?= /usr/lib/udev
TLP_BATD    ?= /usr/share/tlp/bat.d
TLP_NMDSP   ?= /usr/lib/NetworkManager/dispatcher.d
TLP_CONFUSR ?= /etc/tlp.conf
TLP_CONFDIR ?= /etc/tlp.d
TLP_CONFDEF ?= /usr/share/tlp/defaults.conf
TLP_CONFREN ?= /usr/share/tlp/rename.conf
TLP_CONFDPR ?= /usr/share/tlp/deprecated.conf
TLP_CONF    ?= /etc/default/tlp
TLP_SYSD    ?= /usr/lib/systemd/system
TLP_SDSL    ?= /usr/lib/systemd/system-sleep
TLP_SYSV    ?= /etc/init.d
TLP_ELOD    ?= /usr/lib/elogind/system-sleep
TLP_POLKIT  ?= /usr/share/polkit-1/actions
TLP_DBCONF  ?= /usr/share/dbus-1/system.d
TLP_DBSVC   ?= /usr/share/dbus-1/system-services
TLP_SHCPL   ?= /usr/share/bash-completion/completions
TLP_ZSHCPL  ?= /usr/share/zsh/site-functions
TLP_FISHCPL ?= /usr/share/fish/vendor_completions.d
TLP_MAN     ?= /usr/share/man
TLP_META    ?= /usr/share/metainfo
TLP_RUN     ?= /run/tlp
TLP_VAR     ?= /var/lib/tlp

# Catenate DESTDIR to paths
_SBIN    = $(DESTDIR)$(TLP_SBIN)
_BIN     = $(DESTDIR)$(TLP_BIN)
_TLIB    = $(DESTDIR)$(TLP_TLIB)
_FLIB    = $(DESTDIR)$(TLP_FLIB)
_ULIB    = $(DESTDIR)$(TLP_ULIB)
_BATD    = $(DESTDIR)$(TLP_BATD)
_NMDSP   = $(DESTDIR)$(TLP_NMDSP)
_CONFUSR = $(DESTDIR)$(TLP_CONFUSR)
_CONFDIR = $(DESTDIR)$(TLP_CONFDIR)
_CONFDEF = $(DESTDIR)$(TLP_CONFDEF)
_CONFREN = $(DESTDIR)$(TLP_CONFREN)
_CONFDPR = $(DESTDIR)$(TLP_CONFDPR)
_CONF    = $(DESTDIR)$(TLP_CONF)
_SYSD    = $(DESTDIR)$(TLP_SYSD)
_SDSL    = $(DESTDIR)$(TLP_SDSL)
_SYSV    = $(DESTDIR)$(TLP_SYSV)
_ELOD    = $(DESTDIR)$(TLP_ELOD)
_POLKIT  = $(DESTDIR)$(TLP_POLKIT)
_DBCONF  = $(DESTDIR)$(TLP_DBCONF)
_DBSVC   = $(DESTDIR)$(TLP_DBSVC)
_SHCPL   = $(DESTDIR)$(TLP_SHCPL)
_ZSHCPL  = $(DESTDIR)$(TLP_ZSHCPL)
_FISHCPL = $(DESTDIR)$(TLP_FISHCPL)
_MAN     = $(DESTDIR)$(TLP_MAN)
_META    = $(DESTDIR)$(TLP_META)
_RUN     = $(DESTDIR)$(TLP_RUN)
_VAR     = $(DESTDIR)$(TLP_VAR)

SED = sed \
    -e "s|@TLPVER@|$(TLPVER)|g" \
	-e "s|@TLP_SBIN@|$(TLP_SBIN)|g" \
	-e "s|@TLP_TLIB@|$(TLP_TLIB)|g" \
	-e "s|@TLP_FLIB@|$(TLP_FLIB)|g" \
	-e "s|@TLP_ULIB@|$(TLP_ULIB)|g" \
	-e "s|@TLP_BATD@|$(TLP_BATD)|g" \
	-e "s|@TLP_CONFUSR@|$(TLP_CONFUSR)|g" \
	-e "s|@TLP_CONFDIR@|$(TLP_CONFDIR)|g" \
	-e "s|@TLP_CONFDEF@|$(TLP_CONFDEF)|g" \
	-e "s|@TLP_CONFREN@|$(TLP_CONFREN)|g" \
	-e "s|@TLP_CONFDPR@|$(TLP_CONFDPR)|g" \
	-e "s|@TLP_CONF@|$(TLP_CONF)|g" \
	-e "s|@TLP_RUN@|$(TLP_RUN)|g"   \
	-e "s|@TLP_VAR@|$(TLP_VAR)|g"

INFILES = \
	tlp-pd \
	tlp-pd.service

MANFILESPD8 = \
	tlp-pd.service.8

# Make targets
all: $(INFILES)

$(INFILES): %: %.in
	$(SED) $< > $@

clean:
	rm -f $(INFILES)

install-pd: all
	install -D -m 755 tlp-pd $(_SBIN)/tlp-pd
	install -D -m 644 tlp-pd.service $(_SYSD)/tlp-pd.service
	install -D -m 644 tlp-pd.policy $(_POLKIT)/tlp-pd.policy
	$(foreach BUS_NAME,org.freedesktop.UPower.PowerProfiles net.hadess.PowerProfiles, \
		install -D -m 644 tlp-pd.dbus.conf $(_DBCONF)/$(BUS_NAME).conf; \
		sed -e 's|@BUS_NAME@|$(BUS_NAME)|g' -i $(_DBCONF)/$(BUS_NAME).conf; \
		install -D -m 644 tlp-pd.dbus.service $(_DBSVC)/$(BUS_NAME).service; \
		sed -e 's|@BUS_NAME@|$(BUS_NAME)|g' -i $(_DBSVC)/$(BUS_NAME).service;)

install-man-pd:
	# manpages
	install -d -m 755 $(_MAN)/man8
	cd man-pd && install -m 644 $(MANFILESPD8) $(_MAN)/man8/

install: install-pd

install-man: install-man-pd

uninstall-pd:
	rm -f $(_SBIN)/tlp-pd
	rm -f $(_POLKIT)/tlp-pd.policy
	rm -f $(_DBCONF)/org.freedesktop.UPower.PowerProfiles.conf
	rm -f $(_DBSVC)/org.freedesktop.UPower.PowerProfiles.service
	rm -f $(_DBCONF)/net.hadess.PowerProfiles.conf
	rm -f $(_DBSVC)/net.hadess.PowerProfiles.service

uninstall-man-pd:
	# manpages
	cd $(_MAN)/man8 && rm -f $(MANFILESPD8)

uninstall: uninstall-pd

uninstall-man: uninstall-man-pd
