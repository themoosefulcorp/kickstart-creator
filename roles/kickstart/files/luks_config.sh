#!/bin/bash

if [ -e /sys/class/tpm/tpm*/tpm_version_major ] || [[ $(ls /dev/tpm* 2>/dev/null) ]] ; then
    tpm_present="true"
    if [ "$debug_mode" = "true" ] ; then
        clear
        create_task_header "Configure LUKS"
    fi
else
    tpm_present="false"
fi
if [ "$tpm_present" = "false" ] && [ $(virt-what) ] ; then
    while [ "$user_luks_response" != "true" ] && [ "$user_luks_response" != "false" ] ; do
        clear
        create_task_header "Configure LUKS"
        echo -e "The installer detected that it is running in a VM."
        echo -e "LUKS encryption is not recommended unless TPM passthrough is enabled.\n"
        read -r -p "Would you still like to enable disk encryption? (default: no) [yes/no]:  " require_luks
        case "$require_luks" in
            [nN]|[nN][oO]|"")
                user_luks_response="false" ;;
            [yY]|[yY][eE]|[yY][eE][sS])
                user_luks_resonse="true" ;;
            *)
                invalid_option_message "$require_luks" ;;
        esac
    done
fi
if [ "$tpm_present" = "true" ] || [ "$user_luks_response" = "true" ] ; then
    sed -i -e 's/--grow/--grow --encrypted --luks-version=luks2 --cipher=aes-cbc-essiv:sha256 --passphrase='{{ luks_password }}'/' /tmp/drive_config.ks
fi
# if [ "$debug_mode" = "true" ] ; then
#     echo -e "\n\n<-- Begin debug output -->\n"
#     echo -e "Selected contents of /tmp/drive_config.ks:\n"
#     cat /tmp/drive_config.ks | grep -i grow
#     echo -e "\n<-- End debug output -->\n\n"
#     read -r -p "Press <Enter> to continue:  " descriptive_variable
# fi