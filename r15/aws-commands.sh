#!/bin/bash

# Podstaw dane funkcji i konta.
aws events put-rule --name PacktContainerSecurity --event-pattern "{\"source\":[\"aws.guardduty\"]}"
aws events put-targets --rule PacktContainerSecurity --targets Id=1,Arn=arn:aws:lambda:<region>:<ARN digits>:function:<funkcja>
aws lambda add-permission --function-name <funkcja> --statement-id 1 --action 'lambda:InvokeFunction' --principal events.amazonaws.com


