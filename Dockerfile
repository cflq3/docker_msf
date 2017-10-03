FROM ubuntu:latest

MAINTAINER cflq3 <hackerlq@gmail.com>


WORKDIR /opt
# Base packages
RUN apt-get update && apt-get -y install \
  git build-essential zlib1g zlib1g-dev \
  libxml2 libxml2-dev libxslt-dev locate \
  libreadline6-dev libcurl4-openssl-dev git-core \
  libssl-dev libyaml-dev openssl autoconf libtool \
  ncurses-dev bison curl wget xsel postgresql \
  postgresql-contrib postgresql-client libpq-dev \
  libapr1 libaprutil1 libsvn1 \
  libpcap-dev libsqlite3-dev libgmp3-dev \
  nasm tmux vim nmap && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  git clone https://github.com/rapid7/metasploit-framework.git msf

# Get Metasploit
#WORKDIR /opt
#RUN git clone https://github.com/rapid7/metasploit-framework.git msf
WORKDIR msf

# RVM
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import && \
curl -L https://get.rvm.io | bash -s stable && \
/bin/bash -l -c "rvm requirements" && \
/bin/bash -l -c "rvm install 2.4.2" && \
/bin/bash -l -c "rvm use 2.4.2 --default" && \
/bin/bash -l -c "source /usr/local/rvm/scripts/rvm" && \
/bin/bash -l -c "gem install bundler" && \
/bin/bash -l -c "source /usr/local/rvm/scripts/rvm && which bundle" && \
/bin/bash -l -c "which bundle" && \
/bin/bash -l -c "BUNDLEJOBS=$(expr $(cat /proc/cpuinfo | grep vendor_id | wc -l) - 1)" && \
/bin/bash -l -c "bundle config --global jobs $BUNDLEJOBS" && \
/bin/bash -l -c "bundle install" && \
/bin/bash -l -c "gem install os" && \
for i in `ls /opt/msf/tools/*/*`; do ln -s $i /usr/local/bin/; done && \
ln -s /opt/msf/msf* /usr/local/bin

# Install PosgreSQL
COPY ./conf/db.sql /tmp/
RUN /etc/init.d/postgresql start && su postgres -c "psql -f /tmp/db.sql"
USER root
COPY ./conf/database.yml /opt/msf/config/

# tmux configuration file
COPY ./conf/tmux.conf /root/.tmux.conf
# startup script
COPY ./conf/init.sh /usr/local/bin/init.sh

# settings and custom scripts folder
VOLUME /root/.msf4/
VOLUME /tmp/data/

# Starting script (DB + updates)
CMD /usr/local/bin/init.sh
