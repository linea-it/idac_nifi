FROM apache/nifi:2.0.0-M4

LABEL maintainer="LIneA"

USER root

RUN apt-get update && \
    apt-get install -y python3 python3-pip munge \
    slurm-client iputils-ping netcat-openbsd telnet \
    build-essential wget \
    libmunge-dev \
    libssl-dev \
    libpam0g-dev \
    libjwt-dev \
    libjson-c-dev \
    libhttp-parser-dev \
    libyaml-dev \
    fakeroot \
    devscripts \
    equivs && \
    rm -rf /var/lib/apt/lists/*


RUN cd /tmp && \ 
    wget https://download.schedmd.com/slurm/slurm-24.05.5.tar.bz2 && \
    tar -xjf slurm-24.05.5.tar.bz2 && \
    cd slurm-24.05.5 && \
    ./configure --prefix=/usr \
      --sysconfdir=/etc/slurm && \
    make -j$(nproc) && \
    make install

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir /opt/nifi/nifi-current/python_scripts
RUN mkdir /opt/nifi/nifi-current/python_requeriments
RUN /usr/sbin/addgroup --gid 15050 lsst_dp1
RUN /usr/sbin/addgroup --gid 15052 lsst_dp2
RUN /usr/sbin/addgroup --gid 15043 lsst_dr1
RUN /usr/sbin/addgroup --gid 15044 lsst_dr2
RUN /usr/sbin/addgroup --gid 15051 container_nifi

RUN /usr/sbin/useradd -u 15428 -g container_nifi -G nifi -m -s /bin/bash app.nifi

COPY nifi/lib /opt/nifi/nifi-current/lib
COPY nifi/python_extensions /opt/nifi/nifi-current/python_extensions
COPY nifi/python_requeriments/requirements.txt /opt/nifi/nifi-current/python_requeriments

RUN pip install --no-cache-dir -r /opt/nifi/nifi-current/python_requeriments/requirements.txt

EXPOSE 8445

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
