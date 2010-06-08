# Data for cluster A2218:

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
set r [list 39.6749 60.9293 80.7667 102.021 124.692 153.032]

# Number of annuli
set N [llength $r]

# Observational Exposure
set real_exposure 1

# ---------------------------- FITS FILES SPECIFICS ---------------------------- #
set nchannels 1024
set nchannels2 1070

# ------------------------------ FAKEIT PARAMETERS ----------------------------- #
# Parameter to vary
set ipar 1			; # 1: Temp, 2: nH, 3: Abundance, 4: redshift, 6: norm
set param_min 0.3	; # Decimals are limited to 3 places,
set param_max 11.	; # this can be changed, but then has to be changed in the fortran code as well.
set nspectra 100.	; # Note that we actually get nspectra+1 spectra!
set param_break 3.; # Set the value of the break between fits in ROOT.

# ------------------------------ MODELS / PROFILES ----------------------------- #
# Fake exposure (exposure to fake with)
set exposure 4179600.2

# Set temperature profile parameters
set rt 5.
set ta 0.3
set tb 2.
set tc 0.01

# Set density profile parameters
# n0 = 100., rc = 0.01, da = 1., db = 0.5
set n0 1.3
set rc 5.
set da 0.9
set db 2.

# NON-SPHERICAL PARAMETERS
set alpha 3.
set beta 1.
