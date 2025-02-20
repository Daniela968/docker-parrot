FROM parrotsec/core


a
# Kali - Common packages

RUN apt -y install amap \
    apktool \
    arjun \
    beef-xss \
    binwalk \
    cri-tools \
    dex2jar \
    dirb \
    exploitdb \
    kali-tools-top10 \
    kubernetes-helm \
    lsof \
    ltrace \
    man-db \
    nikto \
    set \
    steghide \
    strace \
    theharvester \
    trufflehog \
    uniscan \
    wapiti \
    whatmask \
    wpscan \
    xsser \
    yara

#Sets WORKDIR to /usr

WORKDIR /usr

# XSS-RECON

RUN git clone https://github.com/Ak-wa/XSSRecon; 

# Install language dependencies

RUN apt -y install python3-pip npm nodejs golang

# PyEnv
RUN apt install -y build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl

RUN curl https://pyenv.run | bash

# Set-up necessary Env vars for PyEnv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN pyenv install -v 3.7.16; pyenv install -v 3.8.15

# GitHub Additional Tools

# Blackbird
# for usage: blackbird/
# python blackbird.py
RUN git clone https://github.com/p1ngul1n0/blackbird && cd blackbird && pyenv local 3.8.15 && pip install -r requirements.txt && cd ../

# Maigret
RUN git clone https://github.com/soxoj/maigret.git && pyenv local 3.8.15 && pip3 install maigret && cd ../

# Sherlock
# https://github.com/sherlock-project/sherlock
RUN pip install sherlock-project

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /

COPY conf/proxychains.conf /etc/proxychains.conf

ENTRYPOINT ["/docker-entrypoint.sh"]


# prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# update dependencies
RUN apt update
RUN apt upgrade -y

ENV LANG en_US.utf8

# Define arguments and environment variables
ARG NGROK_TOKEN
ARG Password
ENV Password=${Password}
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Install ssh, wget, and unzip
RUN apt install ssh wget unzip -y > /dev/null 2>&1
# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip
# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
RUN echo "./ngrok tcp 5900 &>/dev/null &" >>/kali.sh
ARG USER=root
ENV USER=${USER}


RUN chmod 755 /kali.sh
RUN /kali.sh

COPY /root /

# ports and volumes
EXPOSE 3000
VOLUME /config

