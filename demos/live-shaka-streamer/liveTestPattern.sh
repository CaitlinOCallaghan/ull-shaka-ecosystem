#!/bin/bash

rm -r -f /var/www/html/testpattern/

../../shaka-streamer/shaka-streamer \
    --skip_deps_check \
    -i input_test_pattern_config.yaml \
    -p pipeline_live_config.yaml \
    -o /var/www/html/testpattern

