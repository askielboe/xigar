#!/bin/bash

# ----------------------- PROGRAM LOCATIONS ----------------------- 

# Path to xspec (headas-init.sh)
HEADAS='/Users/askielboe/Downloads/heasoft-6.9/i386-apple-darwin10.3.0'

# THE REST OF THE PARAMETERS ARE CHANGED IN fakespec.tcl FOR NOW!
# NO NEED TO CHANGE PARAMETERS ANYWHERE ELSE (only here and in fakespec).

# ---------------------- Here begins the code ---------------------
# DO NOT CHANGE BELOW UNLESS YOU KNOW WHAT YOU'RE DOING!

# Delete contents of the output folder (but warn the user first).
echo 'WARNING: This will delete all files in the ./data/clusters/fakec/ folder. Are you sure you wish to continue? (y/n)'
read choice
if [ $choice == 'y' ]; then
	rm ./data/clusters/fakec/*
else
	exit 0
fi

# Run XSPEC to generate fake spectra.
echo 'Running xspec...'
export HEADAS
. $HEADAS/headas-init.sh
xspec << EOF
# Generate parameter files
@writeparams.tcl
writeparams fakec
# Fake spectra
@xspecpro.tcl
xspecpro
EOF

# Run FORTRAN to generate PROFILE
echo 'Running FORTRAN xspecpro.f90...'
gfortran xigar_params.f90 xspecpro.f90
./a.out

echo 'Fake projected spectra saved to fortran file: ./data/clusters/fakec/fakec.f90'
echo 'Copy to rdata to use in Monte Carlo:'
echo 'cp ./data/clusters/fakec/fakec.f90 rdata.f90'