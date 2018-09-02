FROM ubuntu:bionic

RUN mkdir /asterisk
WORKDIR /asterisk

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get -q update && \
  apt-get install --no-install-recommends -y --allow-downgrades -q \
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
    aptitude \
    git bc curl apt-transport-https 


#RUN add-apt-repository ppa:ondrej/php
    
RUN apt-get -q update && \
  apt-get install --no-install-recommends -y --allow-downgrades -q \    
    net-tools mpg123 sox \
    unixodbc ffmpeg lame 
#   && \
#  apt-get clean && \
#  rm /var/lib/apt/lists/*_*
  
  
#RUN a2enmod rewrite && \
#    a2enmod proxy_fcgi setenvif && \
#    a2enconf php5.6-fpm && \
#    sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf && \
#    sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf  && \
#    sed -i 's/^memory_limit =.*/memory_limit = 256M/' /etc/php/5.6/apache2/php.ini && \
#    sed -i 's/^upload_ma.*/upload_max_filesize = 120M/' /etc/php/5.6/apache2/php.ini && \
#    rm -rf /var/www/html

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

