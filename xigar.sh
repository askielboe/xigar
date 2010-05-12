#!/bin/bash

# ----------------------- PROGRAM LOCATIONS ----------------------- 

# Path to xspec (headas-init.sh)
HEADAS='/Users/askielboe/Downloads/heasoft-6.9/i386-apple-darwin10.3.0'

# Path to thisroot.sh
rootfolder='/Users/askielboe/Repositories/root/bin/thisroot.sh'

# -----------------------     PARAMETERS     ----------------------
cluster='A2218'

# THE REST OF THE PARAMETERS ARE CHANGED IN fakespec.tcl FOR NOW!
# NO NEED TO CHANGE PARAMETERS ANYWHERE ELSE (only here and in fakespec).

# ---------------------- Here begins the code ---------------------
# DO NOT CHANGE BELOW UNLESS YOU KNOW WHAT YOU'RE DOING!

# Delete contents of the output folder (but warn the user first).
echo 'WARNING: This will delete all files in the ./data folder. Are you sure you wish to continue? (y/n)'
read choice
if [ $choice == 'y' ]; then
	rm ./data/output/*
else
	exit 0
fi

# Run XSPEC to generate fake spectra.
echo 'Running xspec...'
export HEADAS
. $HEADAS/headas-init.sh
xspec << EOF
@fakespec.tcl
fakespec
$cluster
EOF

# Run FORTRAN to generate PROFILE
echo 'Running FORTRAN profile.f90...'
gfortran xspec_params.f90 profile.f90
./a.out

# Run ROOT to generate fit PARAMETERS
echo 'Running ROOT...'
source $rootfolder
root -l << EOF
.L fit.c+
FitAll()
WriteParams()
EOF

echo 'xigar run completed'
echo 'Fit parameters saved to: params.f90'

# Clean up!
rm *.out
rm *.mod
rm *.so
rm *.d