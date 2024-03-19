#!/bin/bash -e
##-------------------------------------------------------------------
## License: Code is licensed under MIT License
## File: check_proc_threadcount.sh
## Author : Denny <contact@dennyzhang.com>
## Description :
## Read more: https://www.dennyzhang.com/nagois_threadcount
## https://raw.githubusercontent.com/dennyzhang/monitoring/master/process/check_proc_threadcount/check_proc_threadcount.sh
## A few adjustments by Josh Williams <jwilliams@endpoint.com>
## --
##
## Created : <2015-02-25>
## Updated: Time-stamp: <2017-09-04 18:52:17>
##-------------------------------------------------------------------
if [ "$1" = "-w" ] && [ "$2" -gt "0" ] && \
    [ "$3" = "-c" ] && [ "$4" -gt "0" ]; then
    pidPattern=${5?"specify how to get pid"}

    if [ "$pidPattern" = "--pidfile" ]; then
        pidfile=${6?"pidfile to get pid"}
        pid=$(cat "$pidfile")
    elif [ "$pidPattern" = "--cmdpattern" ]; then
        cmdpattern=${6?"command line pattern to find out pid"}
        pid=$(pgrep -a -f "$cmdpattern" | grep -v check_proc_threadcount.sh | head -n 1 | awk -F' ' '{print $1}')
    elif [ "$pidPattern" = "--pid" ]; then
        pid=${6?"pid"}
    else
        echo "ERROR input for pidpattern"
        exit 2
    fi

    if [ -z "$pid" ]; then
        echo "ERROR: no related process is found"
        exit 2
    fi

    thread_count=$(ls "/proc/$pid/task" | wc -l)

    if [ "$thread_count" -ge "$4" ]; then
        echo "CRITICAL: thread count of pid($pid) is $thread_count, more than $4|threadcount=$thread_count;$2;$4"
        exit 2
    elif [ "$thread_count" -ge "$2" ]; then
        echo "WARNING: thread count of pid($pid) is $thread_count, more than $2|threadcount=$thread_count;$2;$4"
        exit 1
    else
        echo "OK: thread count of pid($pid) is $thread_count|threadcount=$thread_count;$2;$4"
        exit 0
    fi
else
    echo "check_proc_threadcount v1.0"
    echo ""
    echo "Usage:"
    echo "check_proc_threadcount.sh -w <warn_count> -c <criti_count> <pid_pattern> <pattern_argument>"
    echo ""
    echo "Below: If tomcat starts more than 1024 threads, send warning"
    echo "check_proc_threadcount.sh -w 1024 -c 2048 --pidfile /var/run/tomcat7.pid"
    echo "check_proc_threadcount.sh -w 1024 -c 2048 --pid 11325"
    echo "check_proc_threadcount.sh -w 1024 -c 2048 --cmdpattern \"tomcat7.*java.*MaxPermSize\""
    echo ""
    echo "Copyright (C) 2017 DennyZhang (contact@dennyzhang.com)"
    exit
fi
## File - check_proc_threadcount.sh ends
