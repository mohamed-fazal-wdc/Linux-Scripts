#!/bin/bash

log_file="PS3_PS4_$(date +%Y%m%d%H%M%S).log"

echo -n "Enter the number of cycles: "
read num_cycles

for ((i = 1; i <= num_cycles; i++))
do
    echo "PS3 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i"
    echo "PS3 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i" >> "$log_file"

    # PS3 Entry
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    nvme set-feature /dev/nvme0 -f 0x02 -v 0x03
    nvme get-feature /dev/nvme0 -f 0x02 -s 0x00 | grep 0x000003 || break
    sleep 0.03

    # PS3 Exit
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    nvme set-feature /dev/nvme0 -f 0x02 -v 0x00
    nvme get-feature /dev/nvme0 -f 0x02 -s 0x00 | grep 00000000 || break
    sleep 0.06

    echo "PS4 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i"
    echo "PS4 in = 30ms out = 60ms | Cycles = $num_cycles | Current Loop = $i" >> "$log_file"

    # PS4 Entry
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    nvme set-feature /dev/nvme0 -f 0x02 -v 0x04 | grep 0x000004 || break
    nvme get-feature /dev/nvme0 -f 0x02 -s 0x00
    sleep 0.030

    # PS4 Exit
    date +%m-%d-%H-%M-%S
    date +%m-%d-%H-%M-%S >> "$log_file"
    nvme set-feature /dev/nvme0 -f 0x02 -v 0x00
    nvme get-feature /dev/nvme0 -f 0x02 -s 0x00 | grep 00000000 || break
    sleep 0.060
done