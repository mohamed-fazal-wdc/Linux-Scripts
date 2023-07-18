#!/bin/bash

# Check if the script is executed as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

log_file="PS3_PS4_$(date +%Y%m%d%H%M%S).log"

# Run nvme list and prompt the user to select the NVMe drive
echo "Available NVMe drives:"
nvme list
echo -n "Enter the number corresponding to the NVMe drive: "
read nvme_number

nvme_device="/dev/nvme${nvme_number}"

echo -n "Enter the number of cycles: "
read num_cycles

# Function to print output to both the screen and the log file
print_and_log() {
    echo "$1"
    echo "$1" >> "$log_file"
}

for ((i = 1; i <= num_cycles; i++))
do
    print_and_log "PS3 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i"

    # PS3 Entry
    print_and_log "PS3 Entry"
    print_and_log "$(date +%m-%d-%H-%M-%S)"
    print_and_log "Running Set-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x03)
    value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Set-Features: $value"
    print_and_log "Running Get-Features"
    get_output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00)
    get_value=$(echo "$get_output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.03

    # Compare values and exit on fail
    if [ "$value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi

    # PS3 Exit
    print_and_log "PS3 Exit"
    print_and_log "$(date +%m-%d-%H-%M-%S)"
    print_and_log "Running Set-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x00)
    value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Set-Features: $value"
    print_and_log "Running Get-Features"
    get_output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00)
    get_value=$(echo "$get_output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.06

    # Compare values and exit on fail
    if [ "$value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi

    print_and_log "PS4 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i"

    # PS4 Entry
    print_and_log "PS4 Entry"
    print_and_log "$(date +%m-%d-%H-%M-%S)"
    print_and_log "Running Get-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x04)
    value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Set-Features: $value"
    print_and_log "Running Get-Features"
    get_output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00)
    get_value=$(echo "$get_output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.030

    # Compare values and exit on fail
    if [ "$value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi

    # PS4 Exit
    print_and_log "PS4 Exit"
    print_and_log "$(date +%m-%d-%H-%M-%S)"
    print_and_log "Running Get-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x00)
    value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Set-Features: $value"
    print_and_log "Running Get-Features"
    get_output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00)
    get_value=$(echo "$get_output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}')
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.060

    # Compare values and exit on fail
    if [ "$value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi
done
