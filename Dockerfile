FROM parrotsec/core


#https://github.com/moby/moby/issues/27988
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update

RUN apt-get install -y wget curl net-tools whois netcat-traditional pciutils bmon htop tor

#Sets WORKDIR to /usr

WORKDIR /  ROOT


# Sherlock
# https://github.com/sherlock-project/sherlock

RUN apt-get clean && rm -rf /var/lib/apt/lists/*


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


VOLUME /config
EXPOSE 3000
