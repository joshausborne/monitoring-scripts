#!/bin/bash

# Copyright © End Point Corporation
# License: BSD 2-clause

systemctl status netfilter-persistent > /dev/null 2>&1
if [ $? = 0 ]; then
        echo "iptables / netfilter-persistent is running"
        exit 0;
else
        echo "iptables / netfilter-persistent is not running"
        exit 2;
fi
