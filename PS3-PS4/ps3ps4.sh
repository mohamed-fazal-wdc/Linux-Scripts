#!/bin/bash

# Check if the script is executed as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

log_file="PS3_PS4_$(date +%Y%m%d%H%M%S).log"

# Run output=$);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
echo -n);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
read nvme_number

nvme_device="/dev/nvme${nvme_number}"

echo -n "Enter the number of cycles: "
read num_cycles

for ((i = 1; i <= num_cycles; i++))
do
    echo "PS3 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i"
    echo "PS3 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i" >> "$log_file"

    # PS3 Entry
    echo "PS3 Entry"
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    echo "Running Set-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x03);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    echo "Running Get-Features"
    output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    sleep 0.03

    # PS3 Exit
    echo "PS3 Exit"
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    echo "Running Set-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x00);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    echo "Running Get-Features"
    output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    sleep 0.06

    echo "PS4 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i"
    echo "PS4 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i" >> "$log_file"

    # PS4 Entry
    echo "PS4 Entry"
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    echo "Running Get-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x04);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    echo "Running Get-Features"
    output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    sleep 0.030

    # PS4 Exit
    echo "PS4 Exit"
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    echo "Running Get-Features"
    output=$(nvme set-feature "$nvme_device" -f 0x02 -v 0x00);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    echo "Running Get-Features"
    output=$(nvme get-feature "$nvme_device" -f 0x02 -s 0x00);value=$(echo "$output" | awk -F', ' '{split($2, arr, ":"); print arr[2]}');echo "Extracted value: $value"
    sleep 0.060
done
