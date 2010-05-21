proc fakespec { args } {

# Supress output (uncomment the next line to get all output).
chatter 5

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# BEGIN > DEFINITIONS - CHANGE THESE TO YOUR SPECIFIC TASK! #

	# Uncomment next line to use external response matrices
	# set file_response "1666_3.wrmf"
	# set file_arf "1666_3.warf"
	
	# Parameter to vary
	set ipar 1			; # 1: Temp, 2: nH, 3: Abundance, 4: redshift, 6: norm
	set param_min 0.3	; # Decimals are limited to 3 places,
	set param_max 11.	; # this can be changed, but then has to be changed in the fortran code as well.
	set nspectra 100.	; # Note that we actually get nspectra+1 spectra!
	set nchannels 1070
	
	set param_break 3.; # Set the value of the break between fits in ROOT.
	
	# Model Parameters
	set temp 1.
	set nH 1.
	set switch 1.
	set norm 1.
	
	# Fakeit Parameters
	set exposure 4179600.2
	
# END > DEFINITIONS                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if {[exec ls ./data/output/] == ""} then {
	
	# Get cluster name and filename prefix for fits files from the user
		puts "Please enter name of the cluster configuration file (in the config directory):"
		gets stdin cname
		# puts "Please enter filename prefix for FITS files, including tailing _'s (ie. 1666_ for filenames: '1666_xx.pi'):"
		# gets stdin file_prefix
		# puts "Please enter number of bins / annuli in the data:"
		# gets stdin nbin

	# Read in parameters for the cluster
		#source ./data/clusters/$cname/$cname.tcl
		source ./config/$cname.tcl
	
	# Note that this way we actually get nspectra+1 spectra!
	set stepsize [expr ($param_max-$param_min)/($nspectra)]
	
	# Initiate the model (ignoring parameters for now)
	model mekal & $temp & $nH & $abundance & $redshift & $switch & $norm &
	
	# Add the galactic absorbtion
	addcomp 2 wabs & $Hcolumn

	# Run through all parameters generating spectra and dumping to unique ACSII files
	#for {set ibin 1} {$ibin <= $nbin} {incr ibin} {
		
		# Change the response files according to the current bin.
		# puts "Changing response files to: $file_prefix$ibin.wrmf and $file_prefix$ibin.warf."
		# set file_response ./data/clusters/$cname/$file_prefix$ibin.wrmf
		# set file_arf ./data/clusters/$cname/$file_prefix$ibin.warf
		
		dummy 0.3 11. $nchannels lin
		
		for {set param $param_min} {$param <= $param_max} {set param [expr $param + $stepsize]} {
			newpar $ipar & $param
			data none
		
			# puts "Faking spectrum with parameter $ipar = $param."
			fakeit none & &y & & ./data/output/fakespec.fak & $exposure &
			# Uncomment next line to use external response matrices
			# fakeit none & $file_response & $file_arf & y & & ./data/output/fakespec.fak & $exposure &
			
			puts "Dumping spectrum to: fakespec_$param.txt"
			fdump infile=./data/output/fakespec.fak outfile=./data/output/fakespec_[format "%4.3f" $param].txt columns='COUNTS' rows=1-$nchannels prhead=no
			
			# puts "Dumping spectrum to: fakespec_$ibin-$ipar-$param.txt"
			# fdump infile=./data/output/fakespec.fak outfile=./data/output/fakespec_$ibin-$ipar-[format "%4.3f" $param].txt columns='COUNTS' rows=1-1070 prhead=no
		}
	#}
	# Write FORTRAN xspec-parameters file
	set fout [open "xigar_params.f90" w]
		#puts $fout "Varied parameter, minimum, maximum, exposure time. \n"
		puts $fout "module xigar_params"
		puts $fout "implicit none"
		puts $fout "CHARACTER :: cname*[string length $cname]='$cname', cprefix*[string length $cprefix]='$cprefix'"
		puts $fout "INTEGER,PARAMETER :: nchannels=$nchannels, nspectra=$nspectra, nannuli=$N"
		puts $fout "REAL,PARAMETER :: param_min=$param_min, param_max=$param_max, exposure=$exposure, real_exposure=$real_exposure, param_break=$param_break"
		puts $fout "REAL,DIMENSION($N) :: rannuli= (/ &"
		set i 1
		foreach item $r {
			if {$i < $N} {
				puts $fout "$item, &"
			}
			if {$i == $N} {
				puts $fout "$item &"
			}
			incr i			
		}
		puts $fout "/)"
		puts $fout "end module xigar_params"
	close $fout
	
	# Write C xspec-parameters file
	set fout [open "xigar_params.h" w]
		#puts $fout "Varied parameter, minimum, maximum, exposure time. \n"
		puts $fout "const Float_t param_min=$param_min, param_max=$param_max, param_break=$param_break;"
		puts $fout "const Int_t exposure=$exposure, nchannels=$nchannels, nspectra=$nspectra;"
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
proc dumpspec { args } {
	chatter 5
	
	set nchannels 1070
	
	puts "Please enter the name of the cluster."
	gets stdin cname
	source ./config/$cname.tcl
	
	for {set i 1} {$i <= $N} {incr i} {
		puts "Dumping spectrum to: $cprefix$i.txt"
		rm ./data/clusters/$cname/$cprefix$i.txt
		fdump infile=./data/clusters/$cname/$cprefix$i.pi outfile=./data/clusters/$cname/$cprefix$i.txt columns='COUNTS' rows=1-$nchannels prhead=no
	}
	puts "DONE dumping $N files!"
}