#!/bin/bash

set -eou pipefail

get_target() {
    avaiable_targets=$(cat ~/.ssh/config | grep "Host plotTarget" | grep -o "plotTarget[a-zA-Z0-9]*")

    while [ -z ${free_target+x} ]; do
        for t in ${avaiable_targets[@]}; do
            set +e
            target_count=$(ps aux | grep scp | grep -v grep | grep -v /usr/bin/ssh | grep -c $t:)
            set -e
            if [ -z ${target_count+x} ] || (( $target_count == 0 )); then
                free_target=$t
                break
            fi
        done
        if [ -z ${free_target+x} ]; then
            sleep 10s
        fi
    done
    echo $free_target
}

migrate_plot() {
    plot_name_full=$1
    plot_target=$(get_target)
    remote_destination=$(ssh $plot_target "python3 get-farm-drive.py")
    echo "Uploading $plot_name_full to $remote_destination"
    scp "$plot_name_full" $plot_target:$remote_destination
    echo "Finished uploading $plot_name_full"

    echo "Deleting $plot_name_full"
    rm "$plot_name_full"
    echo "Deleted $plot_name_full"
}

chia_command=$1
local_plot_drive=$2

eval "$chia_command"

plot_name_full=$(ls -t ${local_plot_drive}/plot*.plot | head -1)

migrate_plot $plot_name_full &
