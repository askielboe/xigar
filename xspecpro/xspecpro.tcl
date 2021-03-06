proc xspecpro { args } {

   source ../settings.tcl
   # Supress output (uncomment the next line to get all output).
   chatter 5

	# Uncomment next line to use external response matrices
	
	# source sphvol.tcl
	source ../config/fakec.tcl
	
	set f "$XIGAR/data/clusters/fakec"
	#set falt "data/clusters/fakec"

	# Calculate temp and density profiles from parameters
	# for {set i 1} {$i <= $N} {incr i} {
	# 	set temp_profile($i) [expr pow(([lindex $r $i]/$rt),(-$ta))/pow(1+pow([lindex $r $i]/$rt,$tb),($tc/$tb))]
	# 	puts $temp_profile($i)
	# 	set density_profile($i) [expr pow($n0,2.) * pow([lindex $r $i]/$rc,-$da) / pow(1.+pow([lindex $r $i]/$rc,2.),($db-$da))]
	# 	puts $density_profile($i)
	# }
	
	set bin 0
	set r_bin_size 0.
	foreach item $r {
		if {$bin > 0} then {
			set r_bin_size [expr [lindex $r $bin]-[lindex $r [expr $bin-1]]]
			puts "$r_bin_size = r($bin)-r($bin-1) = [expr [lindex $r $bin]-[lindex $r [expr $bin-1]]]"
			set r_bin_step [expr $r_bin_size/$resolution]
			puts $r_bin_step
			for {set i 1} {$i <= $resolution} {incr i} {
				set r_resolved([expr $resolution*($bin) + $i]) [expr [lindex $r [expr $bin-1]] + $i*$r_bin_step]
				puts "Setting r_resolved([expr $resolution*($bin) + $i]) = [lindex $r [expr $bin-1]] + $i*$r_bin_step = [expr [lindex $r [expr $bin-1]] + $i*$r_bin_step]"
			}			
		} else {
			set r_bin_size [lindex $r $bin]
			set r_bin_step [expr $r_bin_size/$resolution]
			for {set i 1} {$i <= $resolution} {incr i} {
				set r_resolved([expr $resolution*($bin) + $i]) [expr 0 + $i*$r_bin_step]
				puts "Setting r_resolved([expr $resolution*($bin) + $i]) = 0 + $i*$r_bin_step = [expr 0 + $i*$r_bin_step]"
			}
		}
		incr bin
	}
	#set r r_resolved
	set N [array size r_resolved]
	
	puts "TEMP profile:"
	for {set i 1} {$i <= [expr $N]} {incr i} {
		set r $r_resolved($i)
		# set temp_profile($i) 12.
		# Vikhlinin et al. 2006:
		set temp_profile($i) [expr $tnorm*((1+$ta*($r/$rt))/pow(1+pow($r/$rt,2),$tb))]
		# [expr $tnorm*pow(($r/$rt),(-$ta))/pow(1+pow($r/$rt,$tb),($tc/$tb))]
		puts "$r $temp_profile($i)"
		# COMMENT: Density is applied in FORTRAN code (xspecpro.f90)
		# set density_profile($i) [expr pow($n0,2.) * pow($r/$rc,-$da) / pow(1.+pow($r/$rc,2.),($db-0.5*$da))]
	}
	
	# # # # # # # # # # # # # Define resolution in each bin # # # # # # # # # # # #
	
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
	
	# USING CONSTANT RESPONSE
	set file_response $XIGAR/data/clusters/$cname/1666_3.wrmf
	set file_arf $XIGAR/data/clusters/$cname/1666_3.warf
	
	# vvvvvvvvvvvvvvvvvvv RUNNING WITH CONSTANT TEMPERATURE & RESPONSE vvvvvvvvvvvvvvvvvvv
	
	# data none
	# model none
	# 
	# model mekal & $temp_profile(1) & $nH & $abundance & $redshift & $switch & 1 &
	# addcomp 2 wabs & $Hcolumn
	# #addcomp 3 constant & [expr 1./$exposure]
	# 
	# fakeit none & $file_response & $file_arf & n & & $f/fakec.tmp & $exposure &
	
	# for {set iann 1} {$iann <= $N} {incr iann} {
	# 	
	# 	for {set i $iann} {$i <= $N} {incr i} {
	# 		if {$i > $N} then break
	# 		
	# 		puts "DUMPING spectrum to file: fakec_$iann-$i.txt"
	# 		fdump infile=$f/fakec.tmp outfile=$f/fakec_$iann-$i.txt columns='COUNTS' rows=1-1070 prhead=no
	# 	}
	# }
	# ^^^^^^^^^^^^^^^^^^^ RUNNING WITH CONSTANT TEMPERATURE & RESPONSE ^^^^^^^^^^^^^^^^^^^	
	
	for {set iann 1} {$iann <= $N} {incr iann} {
			
		# CHANGE RESPONSE AS A FUNCTION OF ANNULUS
		# set file_response $XIGAR/data/clusters/$cname/$cprefix$iann.wrmf
		# set file_arf $XIGAR/data/clusters/$cname/$cprefix$iann.warf
		
		for {set i $iann} {$i <= $N} {incr i} {
			if {$i > $N} then break
			
			data none
			model none
			
			model mekal & $temp_profile($i) & $nH & $abundance & $redshift & $switch & 1 &
			addcomp 2 wabs & $Hcolumn
			#addcomp 3 constant & [expr 1./$exposure]
			
			puts "Faking spectrum for annulus: $iann, shell: $i, filename: fakec_temp.tmp"
			fakeit none & $file_response & $file_arf & n & & $f/fakec_$iann-$i.tmp & $exposure &
			
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
	source ../config/$cname.tcl
	
	for {set i 1} {$i <= $N} {incr i} {
		puts "Dumping spectrum to: $cprefix$i.txt"
		rm $XIGAR/data/clusters/$cname/$cprefix$i.txt
		fdump infile=$XIGAR/data/clusters/$cname/$cprefix$i.pi outfile=$XIGAR/data/clusters/$cname/$cprefix$i.txt columns='COUNTS' rows=1-$nchannels prhead=no
	}
	puts "DONE dumping $N files!"
}