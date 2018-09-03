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
		  vim less \
		  build-essential \
    ca-certificates \
    aptitude \
    git bc curl apt-transport-https 


RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    
RUN apt-get -q update && \
    apt-get install --no-install-recommends -y --allow-downgrades -q \
    net-tools mpg123 sox \
    unixodbc ffmpeg lame apache2 \
    libapache2-mod-php5.6 libapache2-mod-security2 libmysqlclient-dev mysql-client \
    mysql-server php-pear php5.6 php5.6-cgi php5.6-cli php5.6-curl php5.6-fpm \
    php5.6-gd php5.6-mbstring php5.6-mysql php5.6-odbc php5.6-xml \
    unixodbc ffmpeg lame fail2ban mailutils
#   && \
#  apt-get clean && \
#  rm /var/lib/apt/lists/*_*
  
  
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
    touch /etc/asterisk/modules.conf /etc/asterisk/ari.conf /etc/asterisk/statsd.conf && \
    cp configs/samples/smdi.conf.sample /etc/asterisk/smdi.conf && \
    useradd -m asterisk && \
    chown asterisk. /var/run/asterisk && \
    chown -R asterisk. /var/lib/asterisk /var/log/asterisk /var/spool/asterisk && \
    chown -R asterisk. /etc/asterisk /usr/lib/asterisk /var/www

COPY freepbx.service /lib/systemd/system
COPY mysqld.cnf /tmp
COPY odbc.ini /tmp
COPY startsvc.sh /bin

RUN cat /tmp/mysqld.cnf >> /etc/mysql/conf.d/mysqld.cnf && \
    usermod -d /var/lib/mysql/ mysql && \
    service mysql restart && \
    cat /tmp/odbc.ini >> /etc/odbc.ini && \
    cd && \
    wget https://cdn.mysql.com/Downloads/Connector-ODBC/5.3/mysql-connector-odbc-5.3.11-linux-ubuntu18.04-x86-64bit.tar.gz && \
    tar -xzf mysql-connector-odbc-5.3.11-linux-ubuntu18.04-x86-64bit.tar.gz && \
    rm -f mysql-connector-odbc-5.3.11-linux-ubuntu18.04-x86-64bit.tar.gz && \
    cd mysql-connector-odbc-5.3.11-linux-ubuntu18.04-x86-64bit && \
    cp bin/* /usr/bin/ && \
    cp lib/* /usr/lib/x86_64-linux-gnu/odbc/ && \
    myodbc-installer -a -d -n "MySQL" -t "Driver=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc5a.so" && \
    ldconfig && \
    odbcinst -i -d -f /etc/odbcinst.ini && \
    odbcinst -i -s -l -f /etc/odbc.ini && \
    odbcinst -q -d
    
RUN cd /usr/src && \
    wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz && \
    tar vxfz freepbx-14.0-latest.tgz && \
    rm -f freepbx-14.0-latest.tgz && \
    cd freepbx
#    ./start_asterisk start && \
#    service mysql restart
# && \ 
#    ./install -n

COPY freepbx.service /lib/systemd/system    
