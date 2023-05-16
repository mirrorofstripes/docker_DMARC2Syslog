# Pull image
FROM fedora:latest

# Install dependencies
RUN dnf -y update && dnf -y install git python3.10 python3-pip && dnf clean all
RUN pip install exchangelib==4.6.2

# Clone script repository
RUN mkdir /srv/dmarc2syslog
RUN git clone https://github.com/BHCyber/DMARC2Syslog.git /srv/dmarc2syslog

# Populate the config file
# CONFIG section
start_datetime=$(date +"%Y-%m-%d-%H:%M")
RUN sed -i "s/.*start_datetime.*/start_datetime = ${start_datetime}/g" /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*mailbox_type.*/mailbox_type = ews/g' /srv/dmarc2syslog/bin/config/config.ini

# SYSLOG section

# EWS section
RUN sed -i 's/.*ews_username.*/ews_username = dmarc@skolasatalice.cz/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_password.*/ews_password = foo/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_email.*/ews_email = dmarc@skolasatalice.cz/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_service_endpoint.*/ews_service_endpoint = https://outlook.office365.com/EWS/Exchange.asmx/g' /srv/dmarc2syslog/bin/config/config.ini
RUN sed -i 's/.*ews_disable_https_cert_verify.*/ews_disable_https_cert_verify = False/g' /srv/dmarc2syslog/bin/config/config.ini






