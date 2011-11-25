program xspecpro

! To compile use: gfortran sphvol.f90 xigar_params.f90 xspecpro.f90
! Some definitions:
! nannuli: The total number of observational annuli.
! rannuli: The radius defining each circular annulus.
! N: The total number of spectra. This number is equal to the resolution times the number of annuli.
! bin: Used as a counter to loop through all spectra.

use sphvol
use xigar_params

implicit none

CHARACTER 						:: dummy*7, fnamein*50, fnameout*50
!INTEGER,PARAMETER				:: N = nannuli !, nchannels = 1024
!!! Define resolution in each bin !!!
!! INTEGER,PARAMETER				:: resolution = 10 DEFINED IN SETTINGS FILE!
INTEGER,PARAMETER				:: N = nannuli*resolution
REAL								:: r_bin_size, r_bin_step, counts_total
REAL,DIMENSION(N)				:: r_resolved
!!! Define resolution in each bin !!!
INTEGER							:: i, iann, j, bin
REAL,DIMENSION(N) 			:: r, counts_integrated
REAL,DIMENSION(N)				:: rho
REAL,DIMENSION(N,N)			:: V
REAL,DIMENSION(nannuli,nchannels) :: spectra_summed
REAL,DIMENSION(N,nchannels)		:: counts, spectra
CHARACTER*13	 				:: format_string
INTEGER							:: n_int1, n_int2

!!! Define resolution in each bin !!! Calculate new high-resoluted bins !!! Define resolution in each bin !!!
bin = 1
do i = 1,nannuli
	if (i > 1) then
		r_bin_size = rannuli(i)-rannuli(i-1)
		r_bin_step = r_bin_size/resolution
		do j = 1,resolution
			r_resolved(bin) = rannuli(i-1) + j * r_bin_step
			write(*,*) "r_resolved(",bin,") = ",r_resolved(bin)
			bin = bin + 1
		end do
	else
		r_bin_size = rannuli(i)
		r_bin_step = r_bin_size/resolution
		do j = 1,resolution
			r_resolved(bin) = 0. + j * r_bin_step
			write(*,*) "r_resolved(",bin,") = ",r_resolved(bin)
			bin = bin + 1
		end do
	end if
end do
r = r_resolved
!!! Define resolution in each bin !!! Calculate new high-resoluted bins !!! Define resolution in each bin !!!

!r = rannuli

! Calculate density profile
open(1,file='../data/clusters/fakec/density_profile.txt', status="replace", form='FORMATTED')
do i=1,N
	! rho(i) = 1.
	! rho(i) = n0**2. * (r(i)/rc)**(-da) / (1.+r(i)**2./rc**2.)**(3.*db-da/2.)
	rho(i) = n0 * (r(i)/rc)**(-da/2.) / (1.+r(i)**2./rc**2.)**(3./2.*db-da/4.)
	write(*,*) "Rho(r=",r(i),") = ",rho(i)
	!rho(i) = n0**2 * (r(i)/rc)**(-da) / (1+r(i)**2/rc**2)**(1-da)
	write(1,'(F20.10)') rho(i)
end do
close(1)

! Calculate volume-elements
write(*,*) "Calling V = vol(N, alpha, beta, r) = vol(",N,",",alpha,",",beta,"r)"
V = vol(N, alpha, beta, r)
!write(*,*) "Volumes:", V

write(*,*) "Summing",N,"spectra..."

! Summing over resoluted bins
do iann = 1,N
	spectra(iann,:) = 0.
	! Read in all spectra for the given annulus
	do i = iann,N ! Loop through all shells
		! DYNAMIC FORMAT CONSTRUCTION
		! Get number of digits in iann and i and construct format
		n_int1 = log10(REAL(iann)) + 1.
		n_int2 = log10(REAL(i)) + 1.
		format_string = '(a,I ,a,I ,a)'
		write(format_string(5:5),'(I1)') n_int1
		write(format_string(10:10),'(I1)') n_int2
		write(fnamein,format_string) '../data/clusters/fakec/fakec_',iann,'-',i,'.txt'
		open(1,file=fnamein,form='formatted')		
		read(1,*) dummy ! Skip the column names
		do j = 1,nchannels
			read(1,*) dummy, counts(i,j)
		end do
		!write(*,*) "Calculating: counts*", V(iann,i), " * ", rho(i), "^2" !, " / ",exposure 
		spectra(iann,:) = spectra(iann,:) + counts(i,:)*V(iann,i)*rho(i)**2 / exposure * scale
	end do
end do
close(1)

!!! Define resolution in each bin !!! Sum bins !!! Define resolution in each bin !!!
! Summing over annuli

bin = 1
do i = 1,nannuli
	spectra_summed(i,:) = 0.
	do j = 1,resolution
		spectra_summed(i,:) = spectra_summed(i,:) + spectra(bin,:)
		bin = bin + 1
	end do
end do

!!! Define resolution in each bin !!! Sum bins !!! Define resolution in each bin !!!

write(*,*) 'Writing output files...'
! Write integrated counts to file
counts_total = 0.
open(3,file='../data/clusters/fakec/integrated_counts.txt', status="replace", form='FORMATTED')
! Write output to txt files
do i = 1,nannuli
	counts_integrated(i) = 0.
	write(fnameout,'(a,I2,a)') '../data/clusters/fakec/fakec_ann',i,'.txt'
	open(2,file=fnameout, status="replace", form='FORMATTED')
	do j = 1,nchannels
			write(2,'(I4,a,ES20.10)') j, ' ', spectra_summed(i,j)
			counts_integrated(i) = counts_integrated(i) + spectra_summed(i,j)
	end do
	close(2)
	write(*,*) "Integrated counts in annulus ", i, ": ",counts_integrated(i)
	write(3,'(F20.10,ES20.10)') r_resolved(i), counts_integrated(i)
	counts_total = counts_total + counts_integrated(i)
end do
close(3)

write(*,*) "----------------------------------------------------------------------"
write(*,*) "TOTAL NUMBER OF COUNTS = ", counts_total
write(*,*) "======================================================================"

! Write output to FORTRAN module files (NEW WITH RESOLUTION)
write(fnameout,'(a)') '../data/clusters/fakec/fakec.f90'
open(2,file=fnameout, status="replace", form='FORMATTED')
write(2,'(a)') "MODULE rdata"
write(2,'(a)') "IMPLICIT NONE"
write(2,'(a,I4,a,I2,a)') "REAL,DIMENSION(",nchannels,"*",nannuli,") :: rspeclong = (/ &"
do i = 1,nannuli-1
	do j = 1,nchannels
		write(2,'(ES20.10,a)') spectra_summed(i,j),", &"
	end do
end do
do j = 1,nchannels-1
	write(2,'(ES20.10,a)') spectra_summed(nannuli,j),", &"
end do
write(2,'(ES20.10,a)') spectra_summed(nannuli,nchannels),"/)"
!write(2,'(a,I1,a,I4,a)') "rspec = RESHAPE(rspec, (/ ",N,",",nchannels," /))"
write(2,'(a)') "END MODULE rdata"
close(2)

! ! Write output to FORTRAN module files (OLD NO RESOLUTION)
! write(fnameout,'(a)') '../data/clusters/fakec/fakec.f90'
! open(2,file=fnameout, status="replace", form='FORMATTED')
! write(2,'(a)') "MODULE rdata"
! write(2,'(a)') "IMPLICIT NONE"
! write(2,'(a,I4,a,I2,a)') "REAL,DIMENSION(",nchannels,"*",nannuli,") :: rspeclong = (/ &"
! do i = 1,N-1
! 	do j = 1,nchannels
! 		write(2,'(F20.10,a)') spectra(i,j),", &"
! 	end do
! end do
! do j = 1,nchannels-1
! 	write(2,'(F20.10,a)') spectra(N,j),", &"
! end do
! write(2,'(F20.10,a)') spectra(N,nchannels),"/)"
! !write(2,'(a,I1,a,I4,a)') "rspec = RESHAPE(rspec, (/ ",N,",",nchannels," /))"
! write(2,'(a)') "END MODULE rdata"
! close(2)

! Print which parameters have been used
write(*,*) "PARAMETERS USED:"
write(*,*) "alpha  = ",alpha
write(*,*) "beta = ",beta

write(*,'(a,I5,a)') 'Wrote ', N*2 ,' files to xigar/data/clusters/fakec/...'
write(*,*) 'DONE PROCESSING FILES!'

end program xspecpro