#!/bin/bash

# Automated task
# No user interaction required

# if [ "$debug_mode" = "true" ] ; then
#     clear
#     create_task_header "Configure NTP"
# fi
echo -e "\n\n#created automatically based on default variables" >> /tmp/network_config.ks
echo "timezone $timezone_region --ntpservers=$ntp_server1,$ntp_server2" >> /tmp/network_config.ks
# if [ "$debug_mode" = "true" ] ; then
#     echo -e "\n\n<-- Begin debug output -->\n"
#     echo -e "Contents of /tmp/network_config.ks:\n"
#     cat /tmp/network_config.ks
#     echo -e "\n<-- End debug output -->\n\n"
#     read -r -p "Press <Enter> to continue:  " descriptive_variable
# fi