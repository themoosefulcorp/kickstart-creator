#!/bin/bash


while : ; do
    clear
    create_task_header "Set system hostname"
    read -r -p "Enter a hostname for the system:  " hostname_input
    echo -e "\n"
    read -r -p "Confirm that you want the system to be named $hostname_input. [yes]:  " hostname_confirmation
    case "$hostname_confirmation" in
        [yY]|[yY][eE]|[yY][eE][sS]|"")
            if [ ${#hostname_input} -gt $(getconf HOST_NAME_MAX) ] || [ ${#hostname_input} -lt 1 ] || [[ "$hostname_input" =~ "."  ]] ; then
                invalid_option_message "$hostname_input"
            else
                fqdn=$(echo $(echo $hostname_input | awk '{print tolower($0)}')".$domain_name")
                echo "network --hostname=$fqdn" >> /tmp/network_config.ks
                break
            fi ;;
        [nN]|[nN][oO])
            cancelled_by_user_message ;;
        *)
            invalid_option_message "$hostname_confirmation" ;;
    esac
done
# if [ "$debug_mode" = "true" ] ; then
#     echo -e "\n\n<-- Begin debug output -->\n"
#     echo -e "Selected contents of /tmp/network_config.ks:\n"
#     cat /tmp/network_config.ks | grep -i hostname
#     echo -e "\n<-- End debug output -->\n\n"
#     read -r -p "Press <Enter> to continue:  " descriptive_variable
# fi