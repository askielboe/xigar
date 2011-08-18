#/bin/bash

# Small script that logs a COSMOMC run, including parameters file, xigar_params and fakeit parameters from fakec.

source ../settings.sh

# Make new log directory
mkdir $XIGAR/logs/`date +%Y-%m-%d-%H%M`
cd $XIGAR/logs/`date +%Y-%m-%d-%H%M`

# # # Copy files # # #
# From COSMOMC folder
cp $COSMO/xigar.txt .
cp $COSMO/xigar.log .
cp $COSMO/parameters.txt .
cp $COSMO/parameters.txt .
cp $COSMO/bestxraylike.txt .
cp $COSMO/rspec.txt .
cp $COSMO/spectrum.txt .

# From XIGAR folder
cp $XIGAR/xigar_params.f90 .
cp $XIGAR/config/fakec.tcl .
cp $XIGAR/cosmomc/params_xray.ini .
cp $XIGAR/data/clusters/fakec/fakec_ann* .
cp $XIGAR/data/clusters/fakec/fakec.f90 .
cp $XIGAR/data/clusters/fakec/integrated_counts.txt .

cd $XIGAR/tools

# TODO: Add code to make automatic directory names from timestamp.
# TODO: Add automatic compression of log files.