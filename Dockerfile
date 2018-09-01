FROM ubuntu:bionic

RUN mkdir /asterisk
WORKDIR /asterisk

RUN apt-get -q update && \
  apt-get install --no-install-recommends -y --force-yes -q \
    openssh-server \
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
    python python-pip \
    python-dev libpython-dev \
    python-numpy python-scipy python-imaging \
    ipython ipython-notebook \
    libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev libboost-all-dev \
    libopenblas-dev libatlas-dev libatlas-base-dev libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler && \
  apt-get clean && \
  rm /var/lib/apt/lists/*_*

