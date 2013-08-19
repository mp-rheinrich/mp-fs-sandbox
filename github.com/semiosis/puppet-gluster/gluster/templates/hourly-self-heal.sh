#!/bin/bash

parallel -j <%= max_jobs -%> /var/tmp/<%= volume -%>-hourly-self-heal-find.sh -- <%= bricks -%>/<%= volume -%>* | xargs -0 stat > /dev/null
