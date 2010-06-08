proc writeparams { args } {
	set cname $args
	
	source ./config/$cname.tcl
	
# Write FORTRAN xspec-parameters file
set fout [open "xigar_params.f90" w]
	#puts $fout "Varied parameter, minimum, maximum, exposure time. \n"
	puts $fout "module xigar_params"
	puts $fout "implicit none"
	puts $fout "CHARACTER :: cname*[string length $cname]='$cname', cprefix*[string length $cprefix]='$cprefix'"
	puts $fout "INTEGER,PARAMETER :: nchannels=$nchannels, nchannels2=$nchannels2, nspectra=$nspectra, nannuli=$N"
	puts $fout "REAL,PARAMETER :: param_min=$param_min, param_max=$param_max, exposure=$exposure, real_exposure=$real_exposure, param_break=$param_break"
	puts $fout "REAL,PARAMETER :: rt=$rt, ta=$ta, tb=$tb, tc=$tc"
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
	puts $fout "end module xigar_params"
close $fout

# Write C xspec-parameters file
set fout [open "xigar_params.h" w]
	#puts $fout "Varied parameter, minimum, maximum, exposure time. \n"
	puts $fout "const Float_t param_min=$param_min, param_max=$param_max, param_break=$param_break;"
	puts $fout "const Int_t exposure=$exposure, nchannels=$nchannels, nchannels2=$nchannels2, nspectra=$nspectra;"
close $fout
}