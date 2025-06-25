FROM apache/nifi:2.0.0-M4

LABEL maintainer="LIneA"

USER root

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir /opt/nifi/nifi-current/python_scripts
RUN mkdir /opt/nifi/nifi-current/python_requeriments
RUN /usr/sbin/addgroup --gid 15050 lsst_dp1
RUN /usr/sbin/addgroup --gid 15052 lsst_dp2
RUN /usr/sbin/addgroup --gid 15043 lsst_dr1
RUN /usr/sbin/addgroup --gid 15044 lsst_dr2

COPY libs/lib /opt/nifi/nifi-current/lib
COPY libs/python_extensions /opt/nifi/nifi-current/python_extensions
COPY libs/python_requeriments/requirements.txt /opt/nifi/nifi-current/python_requeriments

RUN pip install --no-cache-dir -r /opt/nifi/nifi-current/python_requeriments/requirements.txt

EXPOSE 8443

CMD ["../scripts/start.sh"]