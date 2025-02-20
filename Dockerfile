FROM parrotsec/security

#https://github.com/moby/moby/issues/27988
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update

RUN apt-get install -y wget curl net-tools whois netcat-traditional pciutils bmon htop tor

#Sets WORKDIR to /usr

WORKDIR /usr

RUN apt-get clean && rm -rf /var/lib/apt/lists/*
#MAINTAINER Lorenzo "Palinuro" Faletra (palinuro@linux.it)
ENV DEBIAN_FRONTEND noninteractive
ENV VERSION 4.8-1
# Install components
RUN apt-get update; apt-get -y full-upgrade; apt-get -y dist-upgrade; apt-get -y install parrot-pico; apt-get -y install parrot-mini parrot-tools-cloud; apt-get -y install parrot-interface parrot-interface-full parrot-tools-full; apt -y --allow-downgrades install parrot-interface parrot-interface-full parrot-tools-full; apt-get -y install xrdp; rm -rf /var/lib/apt/lists/*
# Set locale to en_US.utf8
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
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh


# Create directory for SSH daemon's runtime files
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/kali.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config # Allow root login via SSH
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config  # Allow password authentication
RUN echo root:${Password}|chpasswd # Set root password
RUN service ssh start
RUN chmod 755 /kali.sh

# Expose port
EXPOSE 80 8888 8080 22 443 5130 5131 5132 5133 5134 5135 3306

# Start the shell script on container startup
CMD  /kali.sh
