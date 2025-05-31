#!/bin/bash

cancelled_by_user_message () {
    echo -e "\n\nIf you're making mistakes, you're probably rushing."
    echo -e "Slow down."
    echo -e "\nSlow is smooth, smooth is fast."
    echo -e "\t\t- Spencer, when discussing jail"
    echo -e "\nCancelling task based on user input"
    ellipses_loop "5"
    clear
}

# title_string
create_task_header () {
    clear
    echo -e "\n"
    echo -e "$1"
    sleep 1
    echo -e "\n\n"
}

# message text
custom_error_message () {
    echo -e "\n$1"
    ellipses_loop "3"
    clear
}

# num_repeat
ellipses_loop () {
    x=1
    sleep_timer=2
    while [ $x -le $1 ] ; do
        echo -n "."
        sleep $sleep_timer
        x=$(( x + 1 ))
    done
}

# handle_command_options () {
#     while [ $# -gt 0 ] ; do
#         case "$1" in
#             --debug)
#                 debug_mode="true" ;;
#             *)
#                 debug_mode="false" ;;
#         esac
#     done
# }

# user_response
invalid_option_message () {
    echo -e "\n\ntf does $1 even mean?"
    echo -e "QUIT TRYING TO BREAK MY SHIT\n"
    echo -e "Restarting task"
    ellipses_loop "3"
    clear
}


# # Process debug flag
# handle_command_options "$@"

# if [ "$debug_mode" = "true" ] ; then
#     clear
#     echo -e "\n\n<-- Pre-script debugging enabled -->\n"
#     ellipses_loop "3"
# fi