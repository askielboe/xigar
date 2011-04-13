#!/bin/bash
source /Users/askielboe/ls/xigar/settings.sh
source /Users/askielboe/ls/xigar/copy_to_camb.sh
rm parameters.txt
cp empty.txt parameters.txt
rm bestxraylike.txt
cp worstxraylike.txt bestxraylike.txt
cd source
make
cd ..
echo 'Great! Now you can run ./cosmomc params_xray.ini..'