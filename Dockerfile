FROM centos:centos7
MAINTAINER r2h2 <rainer@hoerbe.at>

# CentOS7 + prerequsites
RUN yum -y update \
 && yum -y install epel-release \
 && yum -y install curl git ip lsof make net-tools unzip xmlstarlet \
 && yum -y install gcc libxslt-devel python-pip python34-devel \
 && yum -y install java-1.8.0-openjdk-devel.x86_64 \
 && yum -y clean all \
 && curl https://bootstrap.pypa.io/get-pip.py | python3.4 \
 && pip3.4 install jinja2 lxml Werkzeug

RUN curl -O https://www-eu.apache.org/dist/xalan/xalan-j/binaries/xalan-j_2_7_2-bin-2jars.tar.gz \
 && tar -xzf xalan-j_2_7_2-bin-2jars.tar.gz \
 && rm xalan-j_2_7_2-bin-2jars.tar.gz

COPY install/opt/xmlsectool-2 /opt/xmlsectool-2
ENV XMLSECTOOL=/opt/xmlsectool-2/xmlsectool.sh

# Install Options: Github Reop or PyPi:
RUN mkdir -p /opt/source/saml_schematron
WORKDIR /opt/source/saml_schematron
RUN git clone https://github.com/identinetics/saml_schematron.git . \
 && python3.4 setup.py install
#RUN pip install SAMLschtron
#WORKDIR /opt/saml_schematron/rules/schtron_src
#RUN mkdir -p ../schtron_xsl && make

# Application will run as a non-root user/group that must map to the docker host
ARG USERNAME=schtron
ARG UID=3000
RUN groupadd -g $UID $USERNAME \
 && adduser -g $UID -u $UID $USERNAME

WORKDIR /opt/source/saml_schematron/lib

COPY install/scripts/*.sh /
RUN chmod +x /start.sh /opt/saml_schematron/scripts/*.sh \
 && chown -R $USERNAME:$USERNAME /opt/saml_schematron \
 && chmod -R 750 /opt/saml_schematron

# === startup backend system
# EXPOSE 8080
USER $USERNAME
CMD ["/start.sh"]
