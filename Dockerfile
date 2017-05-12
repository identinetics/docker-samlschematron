FROM centos:centos7
MAINTAINER r2h2 <rainer@hoerbe.at>

# CentOS7 + prerequsites
ENV PYTHON=python3.4
ENV PIP=pip3.4
RUN yum -y update \
 && yum -y install epel-release \
 && yum -y install curl git ip lsof make net-tools openssl unzip which xmlstarlet \
 && yum -y install gcc libxslt-devel python-pip python34-devel \
 && yum -y install java-1.8.0-openjdk-devel.x86_64 \
 && yum -y clean all \
 && curl https://bootstrap.pypa.io/get-pip.py | $PYTHON \
 && $PIP install jinja2 lxml Werkzeug

RUN curl -O https://www-eu.apache.org/dist/xalan/xalan-j/binaries/xalan-j_2_7_2-bin-2jars.tar.gz \
 && tar -xzf xalan-j_2_7_2-bin-2jars.tar.gz \
 && rm xalan-j_2_7_2-bin-2jars.tar.gz

COPY install/opt/xmlsectool /opt/xmlsectool
ENV XMLSECTOOL=/opt/xmlsectool/xmlsectool.sh

# use pyJNIus as Python/Java bridge
# 2016-10-26: cython 0.25 is breaking pyjnius (https://github.com/kivy/pyjnius/issues/244)
RUN $PIP install Cython==0.24 \
 && mkdir -p /opt/source/ \
 && git clone https://github.com/identinetics/pyjnius.git /opt/source/pyjnius/ \
 && cd /opt/source/pyjnius/ && $PYTHON setup.py install

# SAMLschematron install option Github:
COPY install/opt/saml_schematron /opt/source/saml_schematron
COPY install/opt/pvzdjava/pvzdValidateXsd.jar /opt/source/saml_schematron/lib/pvzdValidateXsd.jar
WORKDIR /opt/source/saml_schematron
RUN $PYTHON setup.py install
# SAMLschematron install option PyPi:
#RUN pip install SAMLschtron
#WORKDIR /opt/saml_schematron/rules/schtron_src
#RUN mkdir -p ../schtron_xsl && make

# Application will run as a non-root user/group that must map to the docker host
ARG USERNAME=schtron
ARG UID=3000
RUN groupadd -g $UID $USERNAME \
 && adduser -g $UID -u $UID $USERNAME

COPY install/scripts/*.sh /
RUN chmod +x /start.sh /*.sh \
 && chown -R $USERNAME:$USERNAME /opt/source/saml_schematron \
 && chmod -R 750 /opt/source/saml_schematron

# === startup backend system
EXPOSE 8080
VOLUME /etc/pki /var/log
USER $USERNAME
ENV PYTHON='python3.4'
CMD ["/start.sh"]
