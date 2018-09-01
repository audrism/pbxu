FROM ubuntu:bionic

RUN mkdir /asterisk
WORKDIR /asterisk


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
    git bc curl apt-transport-https 


RUN add-apt-repository ppa:ondrej/php
    
RUN apt-get -q update && \
  apt-get install --no-install-recommends -y --force-yes -q \    
    net-tools mpg123 sox apache2 \
    libapache2-mod-php5.6 libapache2-mod-security2 libmysqlclient-dev mysql-client \
    mysql-server php-pear php5.6 php5.6-cgi php5.6-cli php5.6-curl php5.6-fpm \
    php5.6-gd php5.6-mbstring php5.6-mysql php5.6-odbc php5.6-xml \
    unixodbc ffmpeg lame fail2ban mailutils mongodb && \
  apt-get clean && \
  rm /var/lib/apt/lists/*_*
  
  
RUN a2enmod rewrite && \
    a2enmod proxy_fcgi setenvif && \
    a2enconf php5.6-fpm && \
    sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf && \
    sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf  && \
    sed -i 's/^memory_limit =.*/memory_limit = 256M/' /etc/php/5.6/apache2/php.ini && \
    sed -i 's/^upload_ma.*/upload_max_filesize = 120M/' /etc/php/5.6/apache2/php.ini && \
    rm -rf /var/www/html

RUN cd /usr/src && \
    git clone https://github.com/naf419/asterisk.git --branch gvsip && \
    cd asterisk && \
    sed -i 's/MAINLINE_BRANCH=.*/MAINLINE_BRANCH=15/' build_tools/make_version && \
    ./contrib/scripts/install_prereq install && \
    ./contrib/scripts/get_mp3_source.sh && \
    cd /usr/src/asterisk && \
    ./configure && \
    make menuselect.makeopts && \
    menuselect/menuselect --enable format_mp3 --enable app_macro \
       --enable CORE-SOUNDS-EN-WAV --enable CORE-SOUNDS-EN-ULAW menuselect.makeopts && \
    make && \
    make install && \
    make config && \
    ldconfig  && \
    update-rc.d -f asterisk remove && \
    touch /etc/asterisk/{modules,ari,statsd}.conf && \
    cp configs/samples/smdi.conf.sample /etc/asterisk/smdi.conf && \
    useradd -m asterisk && \
    chown asterisk. /var/run/asterisk && \
    chown -R asterisk. /var/{lib,log,spool}/asterisk && \
    chown -R asterisk. /etc/asterisk /usr/lib/asterisk /var/www

