#!/bin/bash


while [ "$need_apache_configuration" != "true" ] && [ "$need_apache_configuration" != "false" ] ; do
    clear
    create_task_header "Configure Apache partition"
    read -r -p "Will this system host software repositories using Apache? (default: no) [yes/no]:  " apache_yesno
    case "$apache_yesno" in
        [nN]|[nN][oO]|"")
            need_apache_configuration="false" ;;
        [yY]|[yY][eE]|[yY][eE][sS])
            need_apache_configuration="true" ;;
        *)
            invalid_option_message "$apache_yesno" ;;
    esac
done
if [ "$need_apache_configuration" = "true" ] ; then
    while : ; do
        capacity_bytes=$(lsblk $parsed_drive -d -n -b -o size)
        capacity_available_gb=$(( $capacity_bytes / 1000000000 * 3 / 4 ))
        if [ "$capacity_available_gb" -le 50 ] ; then
            clear
            custom_error_message "$parsed_drive does not have the required capacity available for Apache.\nSkipping Apache configuration"
            echo -e "\n\n#apache directory not added due to size limitations" >> /tmp/drive_config.ks
            echo -e "#$parsed_drive has $capacity_available_gb GB available, which is less than the required 50 GB + 25% buffer" >> /tmp/drive_config.ks
            break
        fi
        while : ; do
            clear
            echo -e "\n$parsed_drive has $capacity_available_gb GB available for use.\n"
            read -r -p "How much would you like to allocate, in GB? (default: $(( $capacity_available_gb / 2 ))) [1 - $capacity_available_gb]:  " user_capacity
            # Pressing enter for the default is equivalent to a zero-length string
            if [ -z "$user_capacity" ] ; then
                capacity_allocation=$(( $capacity_available_gb / 2 ))
                break 1
            elif [[ "$user_capacity" =~ [^0-9]+ ]] ; then
                invalid_option_message "$user_capacity"
            elif [ "$user_capacity" -lt 1 ] || [ "$user_capacity" -gt "$capacity_available_gb" ] ; then
                custom_error_message "$user_capacity GB is not a valid value.\nTry again."
            else
                capacity_allocation="$user_capacity"
                break 1
            fi
        done
        if [ "$capacity_allocation" -le "$capacity_available_gb" ] && [ "$capacity_allocation" -ge 1 ] ; then
            clear
            echo -e "\n$parsed_drive has $capacity_available_gb GB available.\n"
            read -r -p "Confirm that you would like to allocate $capacity_allocation GB to /var/www/html (default: yes) [yes/no]:  " allocation_confirmation
            case "$allocation_confirmation" in
                [yY]|[yY][eE]|[yY][eE][sS]|"")
                    capacity_mebibytes=$(( $capacity_allocation * 1000000000 / 1049000 ))
                    echo -e "\n\n#created based on user input" >> /tmp/drive_config.ks
                    echo "#$capacity_mebibytes MiB is approximately $capacity_allocation GB (hopefully)" >> /tmp/drive_config.ks
                    echo "logvol /var/www/html --fstype=ext4 --name=varwwwhtml --vgname=rhelvgroup --fsoptions=nodev --size=$capacity_mebibytes" >> /tmp/drive_config.ks
                    echo -e "\n\n#prerequisite due to configuration of apache directory" >> /tmp/repo_config.ks
                    echo -e "%packages --ignore-missing\nhttpd\n%end" >> /tmp/repo_config.ks
                    break ;;
                [nN]|[nN][oO])
                    cancelled_by_user_message ;;
                *)
                    invalid_option_message "$allocation_confirmation" ;;
            esac
        else
            custom_error_message "$user_capacity GB is not a valid size."
        fi
    done
else
    echo -e "\n\n#apache directory not created based on user input" >> /tmp/drive_config.ks
fi
# if [ "$debug_mode" = "true" ] ; then
#     echo -e "\n\n<-- Begin debug output -->\n"
#     echo -e "Contents of /tmp/drive_config.ks:\n"
#     cat /tmp/drive_config.ks
#     if [ "$need_apache_configuration" = "true" ] ; then
#         echo "\n\nContents of /tmp/repo_config.ks:\n"
#         cat /tmp/repo_config.ks
#     fi
#     echo -e "\n<-- End debug output -->\n\n"
#     read -r -p "Press <Enter> to continue:  " descriptive_variable
# fi