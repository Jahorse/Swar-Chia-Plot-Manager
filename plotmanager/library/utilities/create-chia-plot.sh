#!/bin/bash

set -eou pipefail

migrate_plot() {
    plot_name_full=$1
    remote_destination=$(ssh plotTarget "python3 get-farm-drive.py")
    echo "Uploading $plot_name_full to $remote_destination"
    scp "$plot_name_full" plotTarget:$remote_destination
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
