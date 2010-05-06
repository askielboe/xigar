proc fakespec { args } {
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# BEGIN > DEFINITIONS - CHANGE THESE TO YOUR SPECIFIC TASK! #

	# Uncomment next line to use external response matrices
	# set file_response "1666_3.wrmf"
	# set file_arf "1666_3.warf"
	
	# Parameter to vary
	set ipar 1			; # 1: Temp, 2: nH, 3: Abundance, 4: redshift, 6: norm
	set param_min 0.1	; # Decimals are limited to 3 places,
	set param_max 15.	; # this can be changed, but then has to be changed in the fortran code as well.
	set nspectra 100.	; # Note that we actually get nspectra+1 spectra!
	
	# Model Parameters

	set temp 1.
	set nH 1.
	set abundance 0.3
	set redshift 0.18
	set switch 1.
	set norm 2.47359
	
	# Fakeit Parameters
	set exposuretime 4179600.2
	
# END > DEFINITIONS                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if {[exec ls ./data/output/] == ""} then {
	# Note that this way we actually get nspectra+1 spectra!
	set stepsize [expr ($param_max-$param_min)/$nspectra]
	
	# Galactic absorbtion for: A2218
	set Hcolumn 0.026

	# Galactic absorbtion for: A1689
	set Hcolumn 0.0183
	
	# dummyrsp .01 10 1024
	
	# Initiate the model (ignoring parameters for now)
	model mekal & $temp & $nH & $abundance & $redshift & $switch & $norm &
	
	# Add the galactic absorbtion
	addcomp 2 wabs & $Hcolumn

	# Run through all parameters generating spectra and dumping to unique ACSII files
	for {set param $param_min} {$param <= $param_max} {set param [expr $param + $stepsize]} {
		newpar $ipar & $param
		data none
		puts "Faking spectrum with parameter $ipar = $param."
		fakeit none & &y & & ./data/output/fakespec.fak & $exposuretime &
		# Uncomment next line to use external response matrices
		# fakeit none & $file_response & $file_arf & y & & ./data/output/fakespec.fak & $exposuretime &
		puts "Dumping spectrum to: fakespec_$ipar-$param.txt"
		fdump infile=./data/output/fakespec.fak outfile=./data/output/fakespec_$ipar-[format "%4.3f" $param].txt columns='COUNTS' rows=1-1024 prhead=no
		}
	# Write log-file for Fortran code to use
	set fout [open "./data/output/parameters.dat" w]
	puts $fout "$ipar $param_min $param_max $exposuretime"
	close $fout

} else {
	set question "N"
	puts "OUTPUT DIRECTORY NOT EMPTY!"
	puts "Please move files you want to save to another directory before running fakespec!"
	puts "If you want to delete all content of the output folder press 'y' now."
	gets stdin question
		if {$question == "y"} then {
			rm ./data/output/*
			puts "Deleting contents of output folder. Please run fakespec again to generate new spectra."
		} else {
			puts "Output directory NOT empty. Stopping..."
		}
}
}