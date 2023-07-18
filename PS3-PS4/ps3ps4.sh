#!/bin/bash

# Check if the script is executed as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

log_file="PS3_PS4_$(date +%Y%m%d%H%M%S).log"
nvme_device=""
num_cycles=""

# Function to print output to both the screen and the log file
print_and_log() {
    echo "$1"
    echo "$1" >> "$log_file"
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -nvme)
        nvme_device="$2"
        shift
        shift
        ;;
    -cycles)
        num_cycles="$2"
        shift
        shift
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

if [[ -z "$nvme_device" || -z "$num_cycles" ]]; then
    echo "Usage: $0 -nvme <nvme_device_number> -cycles <num_cycles>"
    exit 1
fi

# Run nvme list and prompt the user to select the NVMe drive
echo "Available NVMe drives:"
nvme list

nvme_device="/dev/nvme${nvme_device}"

# Function to run Set-Features and extract value
run_set_feature() {
    local output
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v "$1")
    echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}'
}

# Function to run Get-Features and extract value
run_get_feature() {
    local output
    output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00)
    echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}'
}

for ((i = 1; i <= num_cycles; i++)); do
    print_and_log "PS3/PS4 | In = 30ms | Out = 60ms | Total Cycles = $num_cycles | Current Cycle = $i"

    # PS3 Entry
    print_and_log "PS3 Entry $(date +%m/%d-%H:%M:%S)"
    echo "Running Set-Features"
    set_value=$(run_set_feature 0x03)
    print_and_log "Extracted value from Set-Features: $set_value"
    echo "Running Get-Features"
    get_value=$(run_get_feature)
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.03

    # Compare values and exit on fail
    if [ "$set_value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi

    # PS3 Exit
    print_and_log "PS3 Exit $(date +%m/%d-%H:%M:%S)"
    echo "Running Set-Features"
    set_value=$(run_set_feature 0x00)
    print_and_log "Extracted value from Set-Features: $set_value"
    echo "Running Get-Features"
    get_value=$(run_get_feature)
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.06

    # Compare values and exit on fail
    if [ "$set_value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi

    # PS4 Entry
    print_and_log "PS4 Entry $(date +%m/%d-%H:%M:%S)"
    echo "Running Set-Features"
    set_value=$(run_set_feature 0x04)
    print_and_log "Extracted value from Set-Features: $set_value"
    echo "Running Get-Features"
    get_value=$(run_get_feature)
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.030

    # Compare values and exit on fail
    if [ "$set_value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi

    # PS4 Exit
    print_and_log "PS4 Exit $(date +%m/%d-%H:%M:%S)"
    echo "Running Set-Features"
    set_value=$(run_set_feature 0x00)
    print_and_log "Extracted value from Set-Features: $set_value"
    echo "Running Get-Features"
    get_value=$(run_get_feature)
    print_and_log "Extracted value from Get-Features: $get_value"
    sleep 0.060

    # Compare values and exit on fail
    if [ "$set_value" != "$get_value" ]; then
        print_and_log "ERROR: Extracted value from Get-Features does not match the value from Set-Features!"
        exit 1
    fi
    clear
done
