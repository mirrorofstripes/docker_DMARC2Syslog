# Pull image
FROM fedora:latest

# Install dependencies
RUN dnf -y update && dnf -y install git python3.10 python3-pip syslog-ng && dnf clean all
RUN python3.10 -m ensurepip
RUN python3.10 -m pip install --upgrade pip
RUN python3.10 -m pip install exchangelib==4.6.2 lxml

# Clone script repository
RUN mkdir /srv/dmarc2syslog
RUN git clone https://github.com/BHCyber/DMARC2Syslog.git /srv/dmarc2syslog

# Configure dmarc2syslog
# CONFIG section
start_datetime=$(date +"%Y-%m-%d-%H:%M")
RUN sed -i "s/.*start_datetime.*/start_datetime = ${start_datetime}/g" /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*mailbox_type.*/mailbox_type = ews/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*srv_max_worker.*/srv_max_worker = 2/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*error_log_enable.*/error_log_enable = true/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*debug_log_enable.*/debug_log_enable = true/g' /srv/dmarc2syslog/bin/config/config.ini

# SYSLOG section
RUN sed -i 's/.*syslog_server.*/syslog_server = 127.0.0.1/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*syslog_port.*/syslog_port = 514/g' /srv/dmarc2syslog/bin/config/config.ini

# EWS section
RUN sed -i 's/.*ews_username.*/ews_username = dmarc@skolasatalice.cz/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_password.*/ews_password = foo/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_email.*/ews_email = dmarc@skolasatalice.cz/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_service_endpoint.*/ews_service_endpoint = https://outlook.office365.com/EWS/Exchange.asmx/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_disable_https_cert_verify.*/ews_disable_https_cert_verify = False/g' /srv/dmarc2syslog/bin/config/config.ini

# Configure syslog-ng
RUN cat <<EOF >> /etc/syslog-ng/syslog-ng.conf \
source s_loopback { \
    network( \
        ip("127.0.0.1") \
        port("514") \
        transport("udp") \
    ); \
}; \
\
log { \
    source(s_loopback); \
    destination { \
        file("/dev/stdout"); \
    }; \
}; \
EOF
RUN systemctl enable syslog-ng.service && systemctl start syslog-ng.service


