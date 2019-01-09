#!/bin/bash

curl $MD_AGGREGATE_URL > /tmp/metadata.xml
/usr/bin/python3 /opt/source/saml_schematron/scripts/metadata_valid_days.py \
    /tmp/metadata.xml > $MD_VALID_DAYS_OUT