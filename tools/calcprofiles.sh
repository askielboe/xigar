#!/bin/bash

# Get binary locations from personal settings-file
source settings.sh

# THE REST OF THE PARAMETERS ARE CHANGED IN fakespec.tcl FOR NOW!
# NO NEED TO CHANGE PARAMETERS ANYWHERE ELSE (only here and in fakespec).

# ---------------------- Here begins the code ---------------------
# DO NOT CHANGE BELOW UNLESS YOU KNOW WHAT YOU'RE DOING!

# Run XSPEC to generate fake spectra.
echo 'Running xspec...'
export HEADAS
. $HEADAS/headas-init.sh
xspec << EOF
# Generate parameter files
@writeparams.tcl
writeparams fakec
EOF

# Run FORTRAN to generate PROFILE
echo 'Running FORTRAN calcprofiles.f90...'
gfortran ../xigar_params.f90 calcprofiles.f90
./a.out