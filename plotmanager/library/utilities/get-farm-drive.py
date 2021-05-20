import subprocess
from typing import List, Dict
import random

FARMING_DRIVE_LABEL = 'plotDrive'

# Returns a list of drives with thier names and amount of free space
def get_drive_list() -> List[Dict]:
    drive_list = []

    list_drives_cmd = subprocess.Popen(
        ["df", "--output=avail,target"],
        stdout=subprocess.PIPE
    )
    filter_farm_drives_cmd = subprocess.Popen(
        ["grep", FARMING_DRIVE_LABEL],
        stdin=list_drives_cmd.stdout,
        stdout=subprocess.PIPE
    )
    (drive_list_str, err) = filter_farm_drives_cmd.communicate()

    drive_list_str = drive_list_str.decode('utf-8')
    raw_drive_list = str(drive_list_str).split('\n')[:-1]

    for drive_info in raw_drive_list:
        drive_info = drive_info.strip().split(' ')
        drive = {
            'name': drive_info[1],
            'space': int(drive_info[0]) / 1024 / 1024
        }
        drive_list.append(drive)

    return drive_list


def get_drives_with_space(drive_list: List[Dict]) -> List[str]:
    drives_with_space = []

    for drive in drive_list:
        if (drive['space'] > 108):
            drives_with_space.append(drive['name'])

    return drives_with_space

def main():
    drive_list = get_drive_list()

    drives_with_space = get_drives_with_space(drive_list)

    # What if a drive has a transfer in progress that will fill it?
    # Destinations of active transfers:
    #  ps aux | grep scp | egrep -o "\/media\/plotDrive[0-9]+"
    print(random.choice(drives_with_space))

if __name__ == "__main__":
    main()
