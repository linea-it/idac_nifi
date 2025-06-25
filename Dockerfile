services:
    nifi-idacbr:
        hostname: apache-nifi
        container_name: apache-nifi-container
        build:
            context: .     
        #image: apache/nifi:2.0.0-M4
        ports:
           - 8443:8443
        volumes:
           - nifi_conf:/opt/nifi/nifi-current/conf
           - nifi_state:/opt/nifi/nifi-current/state
           - nifi_logs:/opt/nifi/nifi-current/logs
           - nifi_database_repository:/opt/nifi/nifi-current/database_repository
           - nifi_flowfile_repository:/opt/nifi/nifi-current/flowfile_repository
           - nifi_content_repository:/opt/nifi/nifi-current/content_repository
           - nifi_provenance_repository:/opt/nifi/nifi-current/provenance_repository
           - nifi_nar:/opt/nifi/nifi-current/nar_extensions
           # Diretório para arquivos JDBC paraconexões com bancos de dados
           - ./nifi/jdbc:/opt/nifi/nifi-current/jdbc
           # Diretório com arquivo que contém as bibliotecas em Python
           - ./nifi/python_requeriments:/opt/nifi/nifi-current/python_requeriments
           # Diretório de scripts Python
           - ./nifi/python_scripts:/opt/nifi/nifi-current/python_scripts
           # Diretório dos PROCESSORs criados em Python
           - ./nifi/python_extensions:/opt/nifi/nifi-current/python_extensions
           # Diretório para manipulação de arquivos em geral
           - /mnt/staging:/opt/nifi/nifi-current/files
           # T0 - /scratch
           #- /lustre/t0:/opt/nifi/nifi-current/t0
           # T1 - /data
           - /data:/data
           # DATA STAGING
           - /mnt/staging:/opt/nifi/nifi-current/staging  
        environment:
            - NIFI_CLUSTER_IS_NODE=false
            - SINGLE_USER_CREDENTIALS_USERNAME=${SINGLE_USER_CREDENTIALS_USERNAME}
            - SINGLE_USER_CREDENTIALS_PASSWORD=${SINGLE_USER_CREDENTIALS_PASSWORD}
            - NIFI_JVM_HEAP_INIT=50g
            - NIFI_JVM_HEAP_MAX=86g
            - TZ=America/Sao_Paulo
    adminer:
        hostname: adminer
        container_name: adminer-container
        image: adminer
        restart: always
        ports:
            - 8080:8080
volumes:
    nifi_conf:
    nifi_state:
    nifi_logs:
    nifi_database_repository:
    nifi_flowfile_repository:
    nifi_content_repository:
    nifi_provenance_repository:
    nifi_nar:
bash-4.4$ cat Dockerfile 
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

COPY nifi/lib /opt/nifi/nifi-current/lib
COPY nifi/python_extensions /opt/nifi/nifi-current/python_extensions
COPY nifi/python_requeriments/requirements.txt /opt/nifi/nifi-current/python_requeriments

RUN pip install --no-cache-dir -r /opt/nifi/nifi-current/python_requeriments/requirements.txt

EXPOSE 8443

CMD ["../scripts/start.sh"]