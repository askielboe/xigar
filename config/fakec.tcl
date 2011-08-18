# Data for cluster A2218:
# ----------------------------------- SETTINGS ------------------------------------ #
set use_external_response "TRUE"

# --------------------------------- OBSERVATIONAL --------------------------------- #
# Name of the cluster-observation we use response matrices from
set cname "A2218"

# Prefix for response files (according to cname)
set cprefix "1666_"

# REDSHIFT
set redshift 0.176

# Redshift: z = 0.176
# Reference: 2001ApJ...554L.129M
# Link: http://astrobib.u-strasbg.fr:2008/cgi-bin/cdsbib?2001ApJ...554L.129M

# ABUNDANCE
set abundance 0.20

# abundance: Z = 0.20 ± 0.13
# Reference: The Astrophysical Journal, 567:188-201, 2002 March 1
# Link: http://iopscience.iop.org/0004-637X/567/1/188/fulltext

# GALACTIC ABSORBTION
set Hcolumn 0.026

# Radii of annuli
# set r [list 39.6749 60.9293 80.7667 102.021 124.692 153.032]
# set r [list 0.02 0.05 0.08 0.10 0.14 0.18 0.25 0.40 0.60 0.70 0.80 1.]
# set r [list 0.04 0.06 0.08 0.10 0.12 0.15 0.18 0.22 0.28 0.37 0.56 1.]
# set r [list 0.29 0.41 0.50 0.58 0.65 0.71 0.77 0.82 0.87 0.92 0.96 1.]
# set r [list 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.11 0.14 0.23 1.]
# set r [list 0.04 0.06 0.08 0.10 0.12 0.14 0.17 0.21 0.26 0.34 0.49 1.]
set r [list [expr 1./12.] [expr 2./12.] [expr 3./12.] [expr 4./12.] [expr 5./12.] [expr 6./12.] [expr 7./12.] [expr 8./12.] [expr 9./12.] [expr 10./12.] [expr 11./12.] [expr 12./12.]]
# set r [list 0.04 0.06 0.08 0.10 0.12 0.15 0.18 0.22 0.27 0.34 0.46 1.]
# set r [list 0.03 0.05 0.07 0.09 0.11 0.13 0.16 0.19 0.23 0.30 0.44 1.]
# set r [list 0.1 0.25 0.35 0.5 0.7 0.9 1.]

# Number of annuli
set N [llength $r]

# Observational Exposure
set real_exposure 41796.2

# ---------------------------- FITS FILES SPECIFICS ---------------------------- #
#FOR DUMMY RESPONSE
#set nchannels 1024

#FOR REAL (EXTERNAL) RESPONSE
set nchannels 1024

set nchannels2 1070

# ------------------------------ FAKEIT PARAMETERS ----------------------------- #
# Parameter to vary
set ipar 1			; # 1: Temp, 2: nH, 3: Abundance, 4: redshift, 6: norm
set param_min 0.3	; # Decimals are limited to 3 places,
set param_max 11.	; # this can be changed, but then has to be changed in the fortran code as well.
set nspectra 100.	; # Note that we actually get nspectra+1 spectra!
set param_break 3.; # Set the value of the break between fits in ROOT.
set resolution 10  ; # Number of spectra to use per annulus.

# ------------------------------ MODELS / PROFILES ----------------------------- #
# Fake exposure (exposure to fake with) data is = 41796.2
set exposure 41796.2

# Set temperature profile parameters

# TEMPERATURE
set tnorm 5. ; # Johan: P1
set rt 0.15 ; # Johan: P4
set ta 2.5 ; # Johan: P2
set tb 0.7 ; # Johan: P3
set tc 0.01 ; # NOT USED ATM!

# Set density profile parameters
# n0 = 100., rc = 0.01, da = 1., db = 0.5
# set n0 1.3
# set rc 0.1
# set da 0.9
# set db 2.

# DENSITY
set n0 1.
set rc 0.15
set da 0.8 ; # Johan: P4
set db 0.7 ; # Johan: P3

# NON-SPHERICAL PARAMETERS
# set alpha 0.0
# set beta 3.0
set alpha 3.
set beta 0.5
# set alpha 0.8
# set beta 0.5
