proc writeparams { args } {
	set cname $args
	
	source ../settings.tcl
	source $XIGAR/config/$cname.tcl
	
	# Calculate resoluted bins
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
	
# Write FORTRAN xspec-parameters file
set fout [open "$XIGAR/xigar_params.f90" w]
	#puts $fout "Varied parameter, minimum, maximum, exposure time. \n"
	puts $fout "module xigar_params"
	puts $fout "implicit none"
	puts $fout "CHARACTER :: cname*[string length $cname]='$cname', cprefix*[string length $cprefix]='$cprefix'"
	puts $fout "LOGICAL,PARAMETER :: use_external_response=.$use_external_response."
	puts $fout "INTEGER,PARAMETER :: nchannels=$nchannels, nchannels2=$nchannels2, nspectra=$nspectra, nannuli=$N, resolution=$resolution"
	puts $fout "REAL,PARAMETER :: param_min=$param_min, param_max=$param_max, exposure=$exposure, real_exposure=$real_exposure, scale=$scale, param_break=$param_break"
	puts $fout "REAL,PARAMETER :: rt=$rt, ta=$ta, tb=$tb, tc=$tc, tnorm=$tnorm"
	puts $fout "REAL,PARAMETER :: n0=$n0, rc=$rc, da=$da, db=$db"
	puts $fout "REAL,PARAMETER :: alpha=$alpha, beta=$beta"	
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
	puts $fout "REAL,DIMENSION([expr $N*$resolution]) :: rannuli_resolved= (/ &"
	for {set i 1} {$i <= [expr $N*$resolution]} {incr i} {
		if {$i < [expr $N*$resolution]} {
			puts $fout "$r_resolved($i), &"
		}
		if {$i == [expr $N*$resolution]} {
			puts $fout "$r_resolved($i) &"
		}	
	}
	puts $fout "/)"
	puts $fout "end module xigar_params"
close $fout

# Write C xspec-parameters file
set fout [open "$XIGAR/xigar_params.h" w]
	#puts $fout "Varied parameter, minimum, maximum, exposure time. \n"
	puts $fout "const Float_t param_min=$param_min, param_max=$param_max, param_break=$param_break;"
	puts $fout "const Int_t exposure=$exposure, scale=$scale,nchannels=$nchannels, nchannels2=$nchannels2, nspectra=$nspectra;"
close $fout

# Write Gnuplot
set fout [open "$XIGAR/tools/xigar_plot_t.gnu" w]
	puts $fout "set xlabel 'r'"
	puts $fout "set ylabel 'T'"
	puts $fout "set xrange \[[lindex $r 0]:[lindex $r [expr $N-1]]\]"
	puts $fout "T(x) = $tnorm*(x/$rt)**(-$ta)/(1+(x/$rt)**$tb)**($tc/$tb)"
	puts $fout "plot T(x)"
close $fout

set fout [open "$XIGAR/tools/xigar_plot_rho.gnu" w]
	puts $fout "set xlabel 'r'"
	puts $fout "set ylabel 'rho'"
	puts $fout "set xrange \[[lindex $r 0]:[lindex $r [expr $N-1]]\]"
	puts $fout "rho(x) = $n0**2 * (x/$rc)**(-$da) / (1+x**2/$rc**2)**(1-$da)"
	puts $fout "plot rho(x)"
close $fout

set fout [open "$XIGAR/tools/plotmc.gnu" w]
   # puts $fout "rc = $rc"
   # puts $fout "ta = $ta"
   # puts $fout "tb = $tb"
   # puts $fout "tc = $tc"
   # puts $fout "n0 = $n0"
   # puts $fout "da = $da"
   # puts $fout "db = $db"
   # puts $fout "alpha = $alpha"
   # REMEMBER TO CHANGE THESE IF THE ORDER OF THE PARAMETER CHANGES IN PARAMS_XRAY.INI !!!!
	puts $fout "set log y"
	puts $fout "plot 'xigar.txt' u (\$8-$alpha):2 w l, 'xigar.txt' u (\$7-$da):2 w l, 'xigar.txt' u (\$6-$n0):2 w l, 'xigar.txt' u (\$5-$tc):2 w l, 'xigar.txt' u (\$4-$ta):2 w l, 'xigar.txt' u (\$3-$rc):2 w l"

puts "SUCCESS: Wrote parameter files to: xigar_params.h and xigar_params.f90."

}