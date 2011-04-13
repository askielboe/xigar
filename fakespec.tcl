proc fakespec { args } {

source settings.tcl

# Supress output (uncomment the next line to get all output).
chatter 5

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# BEGIN > DEFINITIONS - CHANGE THESE TO YOUR SPECIFIC TASK! #

	# Uncomment next line to use external response matrices
	# set file_response "1666_3.wrmf"
	# set file_arf "1666_3.warf"
	
	# Model Parameters
	set temp 1.
	set nH 1.
	set switch 1.
	set norm 1.
	
# END > DEFINITIONS                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if {[exec ls ./tmp/] == ""} then {
	
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
	
	# Change the response files according to the current bin.
	# puts "Changing response files to: $file_prefix$ibin.wrmf and $file_prefix$ibin.warf."
	# set file_response ./data/clusters/$cname/$file_prefix$ibin.wrmf
	# set file_arf ./data/clusters/$cname/$file_prefix$ibin.warf
	
	# ----------------------- USING DUMMY RESPONSE -----------------------
	# dummy 0.3 11. $nchannels2 lin
	# ----------------------- USING DUMMY RESPONSE -----------------------
	
	# ----------------------- USING CONSTANT RESPONSE -----------------------
	set file_response $XIGAR/data/clusters/$cname/1666_3.wrmf
	set file_arf $XIGAR/data/clusters/$cname/1666_3.warf
	# ----------------------- USING CONSTANT RESPONSE -----------------------
	
	# Initiate the model (ignoring parameters for now)
	model none
	model mekal & $temp & $nH & $abundance & $redshift & $switch & $norm &
	
	# Add the galactic absorbtion
	addcomp 2 wabs & $Hcolumn

	# Run through all parameters generating spectra and dumping to unique ACSII files
	#for {set ibin 1} {$ibin <= $nbin} {incr ibin} {
		             
		for {set param $param_min} {$param <= $param_max} {set param [expr $param + $stepsize]} {
			newpar $ipar & $param
			
			# puts "Faking spectrum with parameter $ipar = $param."
			data none
			
			# ----------------------- USING DUMMY RESPONSE -----------------------
			# fakeit none & & n & & ./tmp/fakespec.fak & $exposure &
			# fdump infile=./tmp/fakespec.fak outfile=./tmp/fakespec_[format "%4.3f" $param].txt columns='COUNTS' rows=1-$nchannels2 prhead=no
			
			# ----------------------- USING CONSTANT RESPONSE -----------------------
			fakeit none & $file_response & $file_arf & n & & ./tmp/fakespec.fak & $exposure &
			fdump infile=./tmp/fakespec.fak outfile=./tmp/fakespec_[format "%4.3f" $param].txt columns='COUNTS' rows=1-$nchannels prhead=no
			
			puts "Dumping spectrum to: fakespec_$param.txt"
						
			# puts "Dumping spectrum to: fakespec_$ibin-$ipar-$param.txt"
			# fdump infile=./data/output/fakespec.fak outfile=./data/output/fakespec_$ibin-$ipar-[format "%4.3f" $param].txt columns='COUNTS' rows=1-1070 prhead=no
		}
	#}
	
   # @writeparams.tcl
   # [writeparams $cname]

} else {
	set question "N"
	puts "OUTPUT DIRECTORY NOT EMPTY!"
	puts "Please move files you want to save to another directory before running fakespec!"
	puts "If you want to delete all content of the output (tmp) folder press 'y' now."
	gets stdin question
		if {$question == "y"} then {
			rm ./tmp/*
			puts "Deleting contents of output (tmp) folder. Please run fakespec again to generate new spectra."
		} else {
			puts "Output directory NOT empty. Stopping..."
		}
}
}
proc dumpspec { args } {
	chatter 5
	
	puts "Please enter the name of the cluster."
	gets stdin cname
	source ./config/$cname.tcl
	
	for {set i 1} {$i <= $N} {incr i} {
		puts "Dumping spectrum to: $cprefix$i.txt"
		rm ./data/clusters/$cname/$cprefix$i.txt
		fdump infile=./data/clusters/$cname/$cprefix$i.pi outfile=./data/clusters/$cname/$cprefix$i.txt columns='COUNTS' rows=1-$nchannels2 prhead=no
	}
	puts "DONE dumping $N files!"
}