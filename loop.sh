#!/bin/bash

# This is only for testing when you can't attach to a cron job.
# It should be backgrounded.

while true; do
	./checkbuild.sh 2>&1 >/dev/null
	sleep 60m
done
