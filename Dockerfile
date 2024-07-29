# Frappe Bench Dockerfile

# FROM debian:9.6-slim
FROM ubuntu:20.04
LABEL author=frappé

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends locales \
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale en_us.UTF-8 for mariadb and general locale data
ENV PYTHONIOENCODING=utf-8
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# # Install all neccesary packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-suggests --no-install-recommends \
    python3-mysqldb curl build-essential cron python3-testresources python3-setuptools \
    python3-dev libffi-dev python3-pip libcurl4 dnsmasq fontconfig git htop libcrypto++-dev libfreetype6-dev liblcms2-dev \
    libwebp-dev libxext6 libxrender1 libxslt1-dev libxslt1.1 ntpdate postfix python-tk screen \
    vim xfonts-75dpi xfonts-base zlib1g-dev apt-transport-https libsasl2-dev libldap2-dev libcups2-dev pv libjpeg8-dev \
    libtiff5-dev tcl8.6-dev tk8.6-dev libdate-manip-perl logwatch wget libjpeg-turbo8-dev iputils-ping libmariadb-dev \
    libmariadbclient-dev libssl-dev mariadb-client python3-tk redis-tools rlwrap software-properties-common sudo wkhtmltopdf \
    fonts-cantarell
# libmysqlclient-dev  
  
# install node js
RUN python3 -m pip install --upgrade setuptools==66.1.1
RUN python3 -m pip install --upgrade cryptography psutil
RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh 
RUN apt install gpg-agent -y
RUN sudo bash nodesource_setup.sh 
RUN apt install nodejs -y 
RUN npm install -g yarn

# Install wkhtmltox correctly
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb && rm wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && cp /usr/local/bin/wkhtmlto* /usr/bin/ \
    && chmod a+x /usr/bin/wk*

# Add frappe user and setup sudo
RUN groupadd -g 500 frappe \
    && useradd -ms /bin/bash -u 500 -g 500 -G sudo frappe \
    && chown frappe -R /home/frappe

# install bench
# RUN pip3 install -U frappe-bench
RUN pip3 install -e git+https://github.com/jimmyrianto/bench.git#egg=bench --no-cache
# RUN echo fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p

USER frappe

# Add some bench files
COPY --chown=frappe:frappe ./frappe-bench /home/frappe/frappe-bench

WORKDIR /home/frappe/frappe-bench

EXPOSE 8000 9000 6787

VOLUME [ "/home/frappe/frappe-bench" ]

# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-suggests --no-install-recommends \
#   build-essential cron curl git libffi-dev liblcms2-dev libldap2-dev libmariadbclient-dev libsasl2-dev libssl-dev libtiff5-dev \
#   libwebp-dev mariadb-client iputils-ping python3-dev python3-pip python3-setuptools python3-tk redis-tools rlwrap \
#   software-properties-common sudo tk8.6-dev vim xfonts-75dpi xfonts-base wget wkhtmltopdf fonts-cantarell \
#   && apt-get clean && rm -rf /var/lib/apt/lists/* \
#   && curl https://deb.nodesource.com/node_10.x/pool/main/n/nodejs/nodejs_10.10.0-1nodesource1_amd64.deb > node.deb \
#   && dpkg -i node.deb \
#   && rm node.deb \
#   && npm install -g yarn
# # python-pip

# # Install wkhtmltox correctly
# RUN wget https://raw.githubusercontent.com/jimmyrianto/wkhtmltopdf/master/wkhtmltox_0.12.5-1.stretch_amd64.deb
# RUN dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb && rm wkhtmltox_0.12.5-1.stretch_amd64.deb

# # Add frappe user and setup sudo
# RUN groupadd -g 500 frappe \
#   && useradd -ms /bin/bash -u 500 -g 500 -G sudo frappe \
#   && printf '# Sudo rules for frappe\nfrappe ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/frappe \
#   && chown -R 500:500 /home/frappe

# # Install bench
# RUN pip install -e git+https://github.com/jimmyrianto/bench.git#egg=bench --no-cache

# USER frappe

# # Add some bench files
# COPY --chown=frappe:frappe ./frappe-bench /home/frappe/frappe-bench

# WORKDIR /home/frappe/frappe-bench

# EXPOSE 8000 9000 6787

# VOLUME [ "/home/frappe/frappe-bench" ]
