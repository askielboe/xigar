proc xspecpro { args } {

   source ../settings.tcl
   # Supress output (uncomment the next line to get all output).
   chatter 5

	# Uncomment next line to use external response matrices
	
	# source sphvol.tcl
	source $XIGAR/config/fakec.tcl
	
	set f "$XIGAR/data/clusters/fakec"
	#set falt "data/clusters/fakec"
	
	# Calculate temp and density profiles from parameters
	# for {set i 1} {$i <= $N} {incr i} {
	# 	set temp_profile($i) [expr pow(([lindex $r $i]/$rt),(-$ta))/pow(1+pow([lindex $r $i]/$rt,$tb),($tc/$tb))]
	# 	puts $temp_profile($i)
	# 	set density_profile($i) [expr pow($n0,2.) * pow([lindex $r $i]/$rc,-$da) / pow(1.+pow([lindex $r $i]/$rc,2.),($db-$da))]
	# 	puts $density_profile($i)
	# }
	
	set i 1
	foreach item $r {
		set r $item
		set temp_profile($i) [expr $tnorm*pow(($r/$rt),(-$ta))/pow(1+pow($r/$rt,$tb),($tc/$tb))]
		set density_profile($i) [expr pow($n0,2.) * pow($r/$rc,-$da) / pow(1.+pow($r/$rc,2.),($db-$da))]
		incr i
	}
	
	# Fake profiles defines in config/fakec.tcl

	# Parameter to vary
	#set nchannels 1070
	
	# Model Parameters
	set temp 1.
	set nH 1.
	set switch 1.
	set norm 1.
	
	# # Calculate volumes for given alpha-value using sphvol
	# set newvolumes [sphvol $alpha]
	# array unset vol
	# array set vol $newvolumes

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if {[exec ls $f] == ""} then {
	
	#dummy 0.3 11. $nchannels lin
		
	for {set iann 1} {$iann <= $N} {incr iann} {
			
		# Set correct response matrix for the given bin
		set file_response $XIGAR/data/clusters/$cname/$cprefix$iann.wrmf
		set file_arf $XIGAR/data/clusters/$cname/$cprefix$iann.warf
		
		for {set i $iann} {$i <= $N} {incr i} {
			if {$i > $N} then break

			model none

			model mekal & $temp_profile($i) & $nH & $abundance & $redshift & $switch & 1 &
			addcomp 2 wabs & $Hcolumn
			#addcomp 3 constant & [expr 1./$exposure]

			puts "Faking spectrum for annulus: $iann, shell: $i, filename: fakec_temp.tmp"
			fakeit none & $file_response & $file_arf & y & & $f/fakec_$iann-$i.tmp & $exposure &
			
			puts "DUMPING spectrum to file: fakec_$iann-$i.txt"
			fdump infile=$f/fakec_$iann-$i.tmp outfile=$f/fakec_$iann-$i.txt columns='COUNTS' rows=1-1070 prhead=no
		}
	}

} else {
	set question "N"
	puts "OUTPUT DIRECTORY NOT EMPTY!"
	puts "Please move files you want to save to another directory before running fakespec!"
	puts "If you want to delete all content of the output folder press 'y' now."
	gets stdin question
		if {$question == "y"} then {
			rm $f/*
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
	source $XIGAR/config/$cname.tcl
	
	for {set i 1} {$i <= $N} {incr i} {
		puts "Dumping spectrum to: $cprefix$i.txt"
		rm $XIGAR/data/clusters/$cname/$cprefix$i.txt
		fdump infile=$XIGAR/data/clusters/$cname/$cprefix$i.pi outfile=$XIGAR/data/clusters/$cname/$cprefix$i.txt columns='COUNTS' rows=1-$nchannels prhead=no
	}
	puts "DONE dumping $N files!"
}