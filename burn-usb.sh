#!/bin/bash
sync
sudo apt-get install pv
sudo bash -c "pv < $1 > $2"
sync
