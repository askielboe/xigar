program profile

use xigar_params

implicit none

!-------------------------------------------------------------------

! SET THE PARAMTER TO THE ONE YOU OF CHOISE
! (1: Temp, 2: nH, 3: Abundance, 4: redshift, 6: norm)
!INTEGER					::ipar 

! SET THE NUMBER OF SPECTRA (this is nspectra from TCL script + 1)
!INTEGER,PARAMETER		:: nspectra=101

! SET THE MAX AND MIN VALUE OF CHOSEN PARAMETER
!REAL						:: param_min, param_max, exposure

!-------------------------------------------------------------------

!INTEGER,PARAMETER								:: nchannels=1070 
INTEGER,DIMENSION(nspectra+1,nchannels)	:: channel, count
INTEGER												:: i, n, ichannel
REAL,DIMENSION(nspectra+1)						:: params
REAL													:: param, stepsize
CHARACTER 											:: dummy*7, fnamein*50, fnameout*50

!-------------------------------------------------------------------
! Read in parameters from TCL logfile
! open(1,file='./data/output/parameters.dat', status='old', form='FORMATTED')
! read(1,*) param_min, param_max, exposure, nchannels, nspectra
! close(1)
!-------------------------------------------------------------------

stepsize = (param_max-param_min)/(nspectra)

params(1) = param_min
do n = 2, nspectra+1
	params(n) = params(n-1)+stepsize
end do

n = 1
	
	do while (params(n) < 9.999 .AND. n <= nspectra+1)
		write(fnamein,'(a,F5.3,a)') './tmp/fakespec_',params(n),'.txt'
		write(*,'(a,a)') 'Reading file: ', fnamein		
		open(1,file=fnamein,form='formatted')
		read(1,*) dummy ! Skip the column names
		do i = 1,nchannels
			read(1,*) channel(n,i), count(n,i)
		end do
		close(1)
		n = n + 1
	end do

	do while (params(n) < 99.999 .AND. n <= nspectra+1)
		write(fnamein,'(a,F6.3,a)') './tmp/fakespec_',params(n),'.txt'
		write(*,'(a,a)') 'Reading file: ', fnamein
		open(1,file=fnamein,form='formatted')
		read(1,*) dummy ! Skip the column names
		do i = 1,nchannels
			read(1,*) channel(n,i), count(n,i)
		end do
		close(1)
		n = n + 1
	end do

	do while (params(n) < 999.999 .AND. n <= nspectra+1)
		write(fnamein,'(a,F7.3,a)') './tmp/fakespec_',params(n),'.txt'
		write(*,'(a,a)') 'Reading file: ', fnamein
		open(1,file=fnamein,form='formatted')
		read(1,*) dummy ! Skip the column names
		do i = 1,nchannels
			read(1,*) channel(n,i), count(n,i)
		end do
		close(1)
		n = n + 1
	end do

! Write output to file
write(*,*) 'Writing output files...'
!do ichannel = 1,nchannels2
do ichannel = 1,nchannels
	write(fnameout,'(a,I5,a)') './tmp/profile_',ichannel,'.txt'
	open(2,file=fnameout, status="replace", form='FORMATTED')
	do n = 1,nspectra
			write(2,'(F7.3,a,F20.10)') params(n), ' ', count(n,ichannel)/exposure
	end do
	close(2)
end do

write(*,'(a,I5,a)') 'Wrote ', nchannels2 ,' files to ./tmp/'
write(*,*) 'DONE PROCESSING FILES!'

end program profile