#!/bin/bash
# Force GNU11 standard for both Kernel and Host tools
# "$@" passes any arguments (like -j16, menuconfig, clean) to the make command
# We must include the default flags (-Wall -O2 etc) because passing 
# HOSTCFLAGS on the command line overwrites the Makefile defaults entirely.
# ----
# Usage:
# ./build.sh -j$(nproc)
# This injects the flag directly into the CC variable
make CC="gcc -std=gnu11" "$@"
