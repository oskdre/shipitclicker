#!/bin/bash

# Podstaw dane konta Azure

wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w <identyfikator_przestrzeni> -s <klucz_przestrzeni>

sudo /opt/microsoft/omsagent/bin/service_control restart [<identyfikator_przestrzeni>]

sudo docker run --privileged -d -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/containers:/var/lib/docker/containers -e WSID="<identyfikator_przestrzeni>" -e KEY="<klucz_przestrzeni>" -h=`hostname` -p 127.0.0.1:25225:25225 --name="omsagent" --restart=always microsoft/oms


