#!/bin/bash

set -eou pipefail

chia_command=$1
local_plot_drive=$2

eval "$chia_command"
