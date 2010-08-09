#!/bin/bash

# Get binary locations from personal settings-file
source settings.sh

# -----------------------     PARAMETERS     ----------------------
cluster='fakec'

# THE REST OF THE PARAMETERS ARE CHANGED IN fakespec.tcl FOR NOW!
# NO NEED TO CHANGE PARAMETERS ANYWHERE ELSE (only here and in fakespec).

# ---------------------- Here begins the code ---------------------
# DO NOT CHANGE BELOW UNLESS YOU KNOW WHAT YOU'RE DOING!

# Delete contents of the output folder (but warn the user first).
echo 'WARNING: This will delete all files in the ./tmp folder. Are you sure you wish to continue? (y/n)'
read choice
if [ $choice == 'y' ]; then
	rm ./tmp/*
else
	exit 0
fi

# Run XSPEC to generate fake spectra.
echo 'Running xspec...'
export HEADAS
. $HEADAS/headas-init.sh
xspec << EOF
# Generate parameter files
source $XIGAR/common/writeparams.tcl
writeparams $cluster
# Fake spectra
source fakespec.tcl
fakespec
$cluster
EOF

# Run FORTRAN to generate PROFILE
echo 'Running FORTRAN profile.f90...'
gfortran xigar_params.f90 $XIGAR/common/profile.f90 -o $XIGAR/tmp/profile.o
$XIGAR/tmp/profile.o

# Run ROOT to generate fit PARAMETERS
echo 'Running ROOT...'
source $rootfolder
root -l << EOF
.L fit.c+
FitAll()
WriteParams()
.q
EOF

echo 'xigar run completed'
echo 'Fit parameters saved to: fit_params.f90'
echo 'Now make sure everything is set up in cosmomc/params_xray.ini and do:'
echo './copy_to_camb.sh'

# Clean up!
# rm *.out
# rm *.mod
# rm *.so
# rm *.d
# rm *.h