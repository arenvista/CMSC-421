#!/bin/bash
gcc -o test_runner test_suite.c handles.c string_utils.c -lcheck -lm -lpthread -lrt 
./test_runner
