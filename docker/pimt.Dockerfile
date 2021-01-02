#
# pimt.Dockerfile
#
# pimt project
#
# dockerfile for installing dependencies, setting up the environment and running pimt in a container
#
FROM ubuntu:focal

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && \
    apt-get install -y apt-utils awscli dnsutils git jq libcap2-bin libpcap-dev python3 python3-pip wget

ARG PIMT_HOME="/pimt"
ARG TOOL_HOME="/opt"

RUN mkdir -p ${PIMT_HOME} && \
    chmod 777 ${PIMT_HOME}

WORKDIR ${TOOL_HOME}

# wordlists
#RUN git clone https://github.com/danielmiessler/SecLists.git
RUN wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top500.txt

RUN ln -s /usr/bin/python3 /usr/bin/python

# tools
# bucketstream
RUN cd ${TOOL_HOME} && \
    git clone https://github.com/eth0izzle/bucket-stream.git && \
    pip3 install -r bucket-stream/requirements.txt && \
    cp bucket-stream/config.yaml ${PIMT_HOME} && \
    cp bucket-stream/keywords.txt ${PIMT_HOME} && \
    cp -R bucket-stream/permutations ${PIMT_HOME} && \
    chmod 755 ${TOOL_HOME}/bucket-stream/bucket-stream.py

# certstream
RUN pip3 install certstream

RUN wget -q https://raw.githubusercontent.com/sec-tools/MyJunk/master/osint-certstream.py && \
    chmod 755 ${TOOL_HOME}/osint-certstream.py

# cloudenum
RUN git clone https://github.com/initstring/cloud_enum.git && \
    pip3 install -r cloud_enum/requirements.txt && \
    chmod 755 ${TOOL_HOME}/cloud_enum/cloud_enum.py

# subfinder
RUN wget -q https://github.com/projectdiscovery/subfinder/releases/download/v2.4.5/subfinder_2.4.5_linux_amd64.tar.gz && \
    tar -xf subfinder_2.4.5_linux_amd64.tar.gz && \
    mv subfinder /usr/bin/subfinder

# sublister
RUN git clone https://github.com/aboul3la/Sublist3r.git && \
    pip3 install -r Sublist3r/requirements.txt && \
    pip3 install dnspython && \
    chmod 755 ${TOOL_HOME}/Sublist3r/sublist3r.py

# masscan
RUN apt-get install -y masscan && \
    setcap cap_net_raw=ep /usr/bin/masscan

# awscli must be installed after the tools because.. reasons
RUN pip3 install awscli --ignore-installed

ENV PATH=${PATH}:${TOOL_HOME}:${TOOL_HOME}/bucket-stream:${TOOL_HOME}/cloud_enum:${TOOL_HOME}/Sublist3r

WORKDIR ${PIMT_HOME}

# copy over scripts and flask server to home dir
COPY pimtweb.py requirements.txt ./

RUN pip3 install -r requirements.txt

COPY pimt.sh core.sh defs.sh entrypoint.sh prep.sh opt.sh runs.sh tools.sh ./

RUN chmod 755 pimt.sh entrypoint.sh pimtweb.py

# run as user
RUN useradd -ms /bin/bash pimt

USER pimt

ENTRYPOINT [ "/pimt/entrypoint.sh" ]
