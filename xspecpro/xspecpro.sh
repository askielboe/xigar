#!/bin/bash

# Get binary locations from personal settings-file
source ../settings.sh

# THE REST OF THE PARAMETERS ARE CHANGED IN fakespec.tcl FOR NOW!
# NO NEED TO CHANGE PARAMETERS ANYWHERE ELSE (only here and in fakespec).

# ---------------------- Here begins the code ---------------------
# DO NOT CHANGE BELOW UNLESS YOU KNOW WHAT YOU'RE DOING!

# Delete contents of the output folder (but warn the user first).
echo 'WARNING: This will delete all files in the ./data/clusters/fakec/ folder. Are you sure you wish to continue? (y/n)'
read choice
if [ $choice == 'y' ]; then
	rm -r $XIGAR/data/clusters/fakec
	mkdir $XIGAR/data/clusters/fakec
else
	exit 0
fi

# Run XSPEC to generate fake spectra.
echo 'Running xspec...'
export HEADAS
. $HEADAS/headas-init.sh
xspec << EOF
# Generate parameter files
@$XIGAR/common/writeparams.tcl
writeparams fakec
# Fake spectra
@xspecpro.tcl
xspecpro
EOF

# Run FORTRAN to generate PROFILE
echo 'Running FORTRAN xspecpro.f90...'
gfortran $XIGAR/common/sphvol.f90 $XIGAR/xigar_params.f90 xspecpro.f90 -o $XIGAR/tmp/xspecpro.o
$XIGAR/tmp/xspecpro.o

# Clean up!
rm *.mod

echo 'Fake projected spectra saved to fortran file: ./data/clusters/fakec/fakec.f90'
echo 'To use file as real data in COSMOMC do the following:'
echo 'cp ../data/clusters/fakec/fakec.f90 ../data/spectra/rdata.f90'
echo 'Don not forget to run copy_to_camb.sh afterwards.'