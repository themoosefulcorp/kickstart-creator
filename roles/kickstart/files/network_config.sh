#!/bin/bash


# Positionals - user_input , header_array
confirm_entry () {
  echo -e "\n\n"
  read -r -p "Confirm $1 as the $2 (default: yes) [yes/no]:  " confirm_input
  case "$confirm_input" in
    [yY]|[yY][eE]|[yY][eE][sS]|"")
      return 0 ;;
    [nN]|[nN][oO])
      cancelled_by_user_message
      return 1 ;;
    *)
      invalid_option_message "$confirm_input"
      return 1 ;;
  esac
  echo "$configured_value"
}


declare -a nic_headers=("IPv4 Address" "Gateway" "Netmask" "Primary DNS" "Secondary DNS")
declare -a nic_values=("$ip_address" "$ip_gateway" "$ip_netmask" "$dns_server1" "$dns_server2")


while : ; do
#   if [ "$debug_mode" = "true" ] ; then
#     clear
#     create_task_header "Configure network settings"
#   fi
  select ip_mode in DHCP Static ; do
    if [ "$REPLY" -ge 1 ] && [ "$REPLY" -le 2 ] ; then
      break 2
    else
      custom_error_message "Invalid selection.\nPlease choose either 1 for DHCP or 2 for Static."
    fi
  done
done
# String to match with is case-sensitive
if [ "$ip_mode" = "Static" ] ; then
  while [ -z "$configured_ip" ] ; do
    clear
    echo -e "\nAn example ${nic_headers[0]} for this domain is ${nic_values[0]}\n"
    read -r -p "Enter ${nic_headers[0]}:  " user_ip
    case "$user_ip" in
    "")
      custom_error_message "That was just a sample ${nic_headers[0]}.\nThere is no default available for use because John poked holes in that logic.\nPlease specify an ${nic_headers[0]}." ;;
    *)
      if [[ "$user_ip" =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]] ; then
        IFS='.' read -ra ip_octets <<< "$user_ip"
        if [ "${ip_octets[0]}" -le 255 ] && [ "${ip_octets[1]}" -le 255 ] && [ "${ip_octets[2]}" -le 255 ] && [ "${ip_octets[3]}" -le 255 ] ; then
          confirm_entry "$user_ip" "${nic_headers[0]}"
          if [ "$?" -eq 0 ] ; then
            configured_ip="$user_ip"
          fi
        else
          custom_error_message "Nice try. Those are definitely just random numbers."
        fi
      else
        custom_error_message "That's no ${nic_headers[0]}"
      fi ;;
    esac
  done
  while [ -z "$configured_gateway" ] ; do
    clear
    echo -e "\n${nic_headers[0]} is set to $configured_ip"
    echo -e "\nDefault ${nic_headers[1]} is set to ${nic_values[1]}\n\n"
    read -r -p "Enter gateway to use (default: ${nic_values[1]}):  " user_gateway
    case "$user_gateway" in
      "")
        confirm_entry "${nic_values[1]}" "${nic_headers[1]}"
        if [ "$?" -eq 0 ] ; then
          configured_gateway="${nic_values[1]}"
        fi ;;
      *)
        if [[ "$user_gateway" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
          if [ "$user_gateway" != "$configured_ip" ] ; then
            IFS='.' read -ra gateway_octets <<< "$user_gateway"
            if [ "${gateway_octets[0]}" -le 255 ] && [ "${gateway_octets[1]}" -le 255 ] && [ "${gateway_octets[2]}" -le 255 ] && [ "${gateway_octets[3]}" -le 255 ] ; then
              confirm_entry "$user_gateway" "${nic_headers[1]}"
              if [ "$?" -eq 0 ] ; then
                configured_gateway="$user_gateway"
              fi
            else
              custom_error_message "Nice try. Those are definitely just random numbers."
            fi
          else
            custom_error_message "${nic_headers[1]} cannot equal ${nic_headers[0]}."
          fi
        else
          invalid_option_message "$user_gateway"
        fi ;;
    esac
  done
  while [ -z "$configured_gateway" ] ; do
    clear
    echo -e "\n${nic_headers[0]} is set to $configured_ip"
    echo -e "${nic_headers[1]} is set to $configured_gateway"
    echo -e "\nDefault ${nic_headers[2]} is set to ${nic_values[2]}\n\n"
    read -r -p "Enter netmask to use (default: ${nic_values[2]}):  " user_netmask
    case "$user_netmask" in
      "")
        confirm_entry "${nic_values[2]}" "${nic_headers[2]}"
        if [ "$?" -eq 0 ] ; then
          configured_gateway="${nic_values[2]}"
        fi ;;
      *)
        if [[ "$user_netmask" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
          if [ "$user_netmask" != "$configured_ip" ] && [ "$user_netmask" != "$configured_gateway" ] ; then
            IFS='.' read -ra netmask_octets <<< "$user_netmask"
            if [ "${netmask_octets[0]}" -le 255 ] && [ "${netmask_octets[1]}" -le 255 ] && [ "${netmask_octets[2]}" -le 255 ] && [ "${netmask_octets[3]}" -le 255 ] ; then
              confirm_entry "$user_netmask" "${nic_headers[2]}"
              if [ "$?" -eq 0 ] ; then
                configured_gateway="$user_gateway"
              fi
            else
              custom_error_message "Nice try. Those are definitely just random numbers."
            fi
          else
            custom_error_message "${nic_headers[2]} cannot equal ${nic_headers[0]} or ${nic_headers[1]}."
          fi
        else
          invalid_option_message "$user_netmask"
        fi ;;
    esac
  done
  while [ -z "$configured_dns1" ] ; do
    clear
    echo -e "\n${nic_headers[0]} is set to $configured_ip"
    echo -e "${nic_headers[1]} is set to $configured_gateway"
    echo -e "${nic_headers[2]} is set to $configured_netmask"
    echo -e "\nDefault ${nic_headers[3]} server is set to ${nic_values[3]}\n\n"
    read -r -p "Enter address for ${nic_headers[3]} (default: ${nic_values[3]}):  " user_dns1
    case "$user_dns1" in
      "")
        confirm_entry "${nic_values[3]}" "${nic_headers[3]}"
        if [ "$?" -eq 0 ] ; then
          configured_dns1="${nic_values[3]}"
        fi ;;
      *)
        if [[ "$user_dns1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
          if [ "$user_dns1" != "$configured_gateway" ] && [ "$user_dns1" != "$configured_netmask" ] ; then
            if [ "$user_dns1" != "$configured_ip" ] ; then
              IFS='.' read -ra dns1_octets <<< "$user_dns1"
              if [ "${dns1_octets[0]}" -le 255 ] && [ "${dns1_octets[1]}" -le 255 ] && [ "${dns1_octets[2]}" -le 255 ] && [ "${dns1_octets[3]}" -le 255 ] ; then
                confirm_entry "$user_dns1" "${nic_headers[3]}"
                if [ "$?" -eq 0 ] ; then
                  configured_dns1="$user_dns1"
                fi
              else
                custom_error_message "Nice try. Those are definitely just random numbers."
              fi
            else
              custom_error_message "Please use a loopback address."
            fi
          else
            custom_error_message "${nic_headers[3]} cannot equal ${nic_headers[1]} or ${nic_headers[2]}."
          fi
        else
          invalid_option_message "$user_dns1"
        fi ;;
    esac
  done
  while [ -z "$configured_dns2" ] ; do
    clear
    echo -e "\n${nic_headers[0]} is set to $configured_ip"
    echo -e "${nic_headers[1]} is set to $configured_gateway"
    echo -e "${nic_headers[2]} is set to $configured_netmask"
    echo -e "${nic_headers[3]} is set to $configured_dns1\n\n"
    read -r -p "Does this system have a secondary DNS server? (default: no) [yes/no]:  " need_dns2
    case "$need_dns2" in
      [yY]|[yY][eE]|[yY][eE][sS]|"")
        clear
        echo -e "\nDefault ${nic_headers[4]} is set to ${nic_values[4]}\n\n"
        read -r -p "Would you like to change this? (default: no) [yes/no]:  " change_dns2
        case "$change_dns2" in
          [nN]|[nN][oO]|"")
            configured_dns2="${nic_values[4]}" ;;
          [yY]|[yY][eE]|[yY][eE][sS])
            read -r -p "Enter a secondary DNS server to use (default: ${nic_values[4]}):  " user_dns2
            case "$user_dns2" in
              "")
                confirm_entry "${nic_values[4]}" "${nic_headers[4]}"
                if [ "$?" -eq 0 ] ; then
                  configured_dns2="${nic_values[4]}"
                fi ;;
              *)
                if [[ "$user_dns2" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] ; then
                  if [ "$user_dns2" != "$configured_gateway" ] && [ "$user_dns2" != "$configured_netmask" ] && [ "$user_dns2" != "$configured_dns1" ] ; then
                    if [ "$user_dns2" != "$configured_ip" ] ; then
                      IFS='.' read -ra dns2_octets <<< "$user_dns2"
                      if [ "${dns2_octets[0]}" -le 255 ] && [ "${dns2_octets[1]}" -le 255 ] && [ "${dns2_octets[2]}" -le 255 ] && [ "${dns2_octets[3]}" -le 255 ] ; then
                        confirm_entry "$user_dns2" "${nic_headers[4]}"
                        if [ "$?" -eq 0 ] ; then
                          configured_dns2="$user_dns2"
                        fi
                      else
                        custom_error_message "Nice try. Those are definitely just random numbers."
                      fi
                    else
                      custom_error_message "Please use a loopback address."
                    fi
                  else
                    custom_error_message "${nic_headers[4]} cannot equal ${nic_headers[1]}, ${nic_headers[2]}, or ${nic_headers[3]}."
                  fi
                else
                  invalid_option_message "$user_dns2"
                fi ;;
            esac ;;
          *)
            invalid_option_message "$user_dns2" ;;
        esac ;;
      [nN]|[nN][oO])
        configured_dns2="false" ;;
      *)
        invalid_option_message "$need_dns2" ;;
    esac
  done
  if [ "$configured_dns2" = "false" ] ; then
    echo -e "\n\n#secondary dns server not configured based on user input" >> /tmp/network_config.ks
    echo "network --bootproto=static --ip=$configured_ip --gateway=$configured_gateway --netmask=$configured_netmask --nameserver=$configured_dns1 --ipv6=auto --onboot=yes --activate" >> /tmp/network_config.ks
  else
    echo -e "\n\n#secondary dns server configured based on user input" >> /tmp/network_config.ks
    echo "network --bootproto=static --ip=$configured_ip --gateway=$configured_gateway --netmask=$configured_netmask --nameserver=$configured_dns1,$configured_dns2 --ipv6=auto --onboot=yes --activate" >> /tmp/network_config.ks
  fi
else
  echo -e "\n\n#configured as dhcp based on user input" >> /tmp/network_config.ks
  echo "network --bootproto=dhcp --ipv6=auto --onboot=yes --activate" >> /tmp/network_config.ks
fi
# if [ "$debug_mode" = "true" ] ; then
#     echo -e "\n\n<-- Begin debug output -->\n"
#     echo -e "Contents of /tmp/network_config.ks:\n"
#     cat /tmp/network_config.ks
#     echo -e "\n<-- End debug output -->\n\n"
#     read -r -p "Press <Enter> to continue:  " descriptive_variable
# fi