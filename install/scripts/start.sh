#!/bin/bash
#
# Startup script for the saml schematron validation web app

/usr/bin/start_srv.py > /var/log/access.log 2> /var/log/error.log
