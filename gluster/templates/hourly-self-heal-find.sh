#!/bin/bash

find $1 -mmin <%= mmin -%> -printf "<%= mount_point -%>/%P\0"
