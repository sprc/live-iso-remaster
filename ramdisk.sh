#!/bin/bash
mkdir tmp
sudo mount -t ramfs -o size=8g ext4 tmp
sudo chown clinton:clinton tmp
