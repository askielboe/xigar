program xspecpro

! To compile use: gfortran sphvol.f90 xigar_params.f90 xspecpro.f90

use sphvol
use xigar_params

implicit none

CHARACTER 							:: dummy*7, fnamein*50, fnameout*50
INTEGER,PARAMETER					:: N = nannuli !, nchannels = 1024
INTEGER								:: i, iann, j
REAL,DIMENSION(N) 				:: r, counts_integrated
REAL,DIMENSION(N)					:: rho
REAL,DIMENSION(N,N)				:: V
REAL,DIMENSION(N,nchannels)	:: counts, spectra

r = rannuli

! Calculate density profile
do i=1,N
	rho(i) = n0**2. * (r(i)/rc)**(-da) / (1.+r(i)**2./rc**2.)**(3.*db-da/2.)
	!rho(i) = n0**2 * (r(i)/rc)**(-da) / (1+r(i)**2/rc**2)**(1-da)
end do

! Calculate volume-elements
V = vol(N, alpha, beta, r)
write(*,*) "Volumes:", V

do iann = 1,N
	spectra(iann,:) = 0.
	! Read in all spectra for the given annulus
	do i = iann,N ! Loop through all shells
		if (i < 10 .AND. iann < 10) then
			write(fnamein,'(a,I1,a,I1,a)') '../data/clusters/fakec/fakec_',iann,'-',i,'.txt'
		else if (i > 9 .AND. iann < 10) then
			write(fnamein,'(a,I1,a,I2,a)') '../data/clusters/fakec/fakec_',iann,'-',i,'.txt'
		else if (i < 10 .AND. iann > 9) then
			write(fnamein,'(a,I2,a,I1,a)') '../data/clusters/fakec/fakec_',iann,'-',i,'.txt'
		else if (i > 9 .AND. iann > 9) then
			write(fnamein,'(a,I2,a,I2,a)') '../data/clusters/fakec/fakec_',iann,'-',i,'.txt'
		endif
		open(1,file=fnamein,form='formatted')		
		read(1,*) dummy ! Skip the column names
		do j = 1,nchannels
			read(1,*) dummy, counts(i,j)
		end do
		write(*,*) "Calculating: counts*", V(iann,i), " * ", rho(i) !, " / ",exposure 
		spectra(iann,:) = spectra(iann,:) + counts(i,:)*V(iann,i)*rho(i) !/exposure	
	end do
end do

write(*,*) 'Writing output files...'
! Write output to txt files
do i = 1,N
	counts_integrated(i) = 0.
	write(fnameout,'(a,I2,a)') '../data/clusters/fakec/fakec_ann',i,'.txt'
	open(2,file=fnameout, status="replace", form='FORMATTED')
	do j = 1,nchannels
			write(2,'(I4,a,F20.10)') j, ' ', spectra(i,j)
			counts_integrated(i) = counts_integrated(i) + spectra(i,j)
	end do
	close(2)
	write(*,*) "Integrated counts in annulus ", i, ": ",counts_integrated(i)
end do

! Write output to FORTRAN module files
write(fnameout,'(a)') '../data/clusters/fakec/fakec.f90'
open(2,file=fnameout, status="replace", form='FORMATTED')
write(2,'(a)') "MODULE rdata"
write(2,'(a)') "IMPLICIT NONE"
write(2,'(a,I4,a,I1,a)') "REAL,DIMENSION(",nchannels,"*",nannuli,") :: rspeclong = (/ &"
do i = 1,N-1
	do j = 1,nchannels
		write(2,'(F20.10,a)') spectra(i,j),", &"
	end do
end do
do j = 1,nchannels-1
	write(2,'(F20.10,a)') spectra(N,j),", &"
end do
write(2,'(F20.10,a)') spectra(N,nchannels),"/)"
!write(2,'(a,I1,a,I4,a)') "rspec = RESHAPE(rspec, (/ ",N,",",nchannels," /))"
write(2,'(a)') "END MODULE rdata"
close(2)

write(*,'(a,I5,a)') 'Wrote ', N*2 ,' files to xigar/data/clusters/fakec/...'
write(*,*) 'DONE PROCESSING FILES!'

end program xspecpro