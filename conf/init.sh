#!/bin/bash

source /usr/local/rvm/scripts/rvm
/etc/init.d/postgresql start && su postgres -c "psql -f /tmp/db.sql" && \
/opt/msf/msfupdate --git-branch master && \
#/opt/msf/msfconsole
/bin/bash
