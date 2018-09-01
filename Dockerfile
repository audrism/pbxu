FROM ubuntu:bionic

RUN mkdir /asterisk
WORKDIR /asterisk


RUN add-apt-repository ppa:ondrej/php
RUN apt-get -q update && \
  apt-get install --no-install-recommends -y --force-yes -q \
    openssh-server \
    software-properties-common \
	     lsof sudo \
		  zsh \
		  libssl-dev \
		  sssd \
		  sssd-tools \
		  libnss-sss \
		  libpam-pwquality \
		  libpam-sss \
		  libsss-sudo \
		  ldap-utils \
		  vim \
		  build-essential \
    ca-certificates \
    git bc \
    curl apt-transport-https net-tools mpg123 sox apache2 \
    libapache2-mod-php5.6 libapache2-mod-security2 libmysqlclient-dev mysql-client \
    mysql-server php-pear php5.6 php5.6-cgi php5.6-cli php5.6-curl php5.6-fpm \
    php5.6-gd php5.6-mbstring php5.6-mysql php5.6-odbc php5.6-xml \
    unixodbc ffmpeg lame fail2ban mailutils mongodb && \
  apt-get clean && \
  rm /var/lib/apt/lists/*_*

