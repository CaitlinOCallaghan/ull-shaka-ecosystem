#!/bin/bash

rm -r -f /var/www/html/livelooped/

../../shaka-streamer/shaka-streamer \
    --skip_deps_check \
    -i input_looped_file_config.yaml \
    -p pipeline_live_config.yaml \
    -o /var/www/html/livelooped
