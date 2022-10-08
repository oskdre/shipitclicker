#!/bin/bash

helm install datadog-agent -f values.yaml  --set datadog.apiKey={klucz_API} stable/datadog
