program profile

implicit none

!-------------------------------------------------------------------

! SET THE PARAMTER TO THE ONE YOU OF CHOISE
! (1: Temp, 2: nH, 3: Abundance, 4: redshift, 6: norm)
INTEGER					:: ipar

! SET THE NUMBER OF SPECTRA (this is nspectra from TCL script + 1)
INTEGER,PARAMETER		:: nspectra=101

! SET THE MAX AND MIN VALUE OF CHOSEN PARAMETER
REAL						:: param_min, param_max, exposure

!-------------------------------------------------------------------

INTEGER,PARAMETER								:: nchannels=1024 
INTEGER,DIMENSION(nspectra,nchannels)	:: channel, count
INTEGER											:: i, n, ichannel
REAL,DIMENSION(nspectra)					:: params
REAL												:: param, stepsize
CHARACTER 										:: dummy*7, fnamein*50, fnameout*50

!-------------------------------------------------------------------
! Read in parameters from TCL logfile
open(1,file='./data/output/parameters.dat', status='old', form='FORMATTED')
read(1,*) ipar, param_min, param_max, exposure
close(1)
!-------------------------------------------------------------------

stepsize = (param_max-param_min)/(nspectra-1.)

params(1) = param_min
do n = 2, nspectra
	params(n) = params(n-1)+stepsize
end do

n = 1
	
	do while (params(n) < 9.999 .AND. n <= nspectra)
		write(fnamein,'(a,I1,a,F5.3,a)') './data/output/fakespec_',ipar,'-',params(n),'.txt'
		write(*,'(a,a)') 'Reading file: ', fnamein		
		open(1,file=fnamein,form='formatted')
		read(1,*) dummy ! Skip the column names
		do i = 1,nchannels
			read(1,*) channel(n,i), count(n,i)
		end do
		close(1)
		n = n + 1
	end do

	do while (params(n) < 99.999 .AND. n <= nspectra)
		write(fnamein,'(a,I1,a,F6.3,a)') './data/output/fakespec_',ipar,'-',params(n),'.txt'
		write(*,'(a,a)') 'Reading file: ', fnamein
		open(1,file=fnamein,form='formatted')
		read(1,*) dummy ! Skip the column names
		do i = 1,nchannels
			read(1,*) channel(n,i), count(n,i)
		end do
		close(1)
		n = n + 1
	end do

	do while (params(n) < 999.999 .AND. n <= nspectra)
		write(fnamein,'(a,I1,a,F7.3,a)') './data/output/fakespec_',ipar,'-',params(n),'.txt'
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
do ichannel = 1,nchannels
	write(fnameout,'(a,I1,a,I5,a)') './data/profiles/profile_',ipar,'_',ichannel,'.txt'
	open(2,file=fnameout, status="replace", form='FORMATTED')
	do n = 1,nspectra
			write(2,'(F7.3,a,F12.7)') params(n), ' ', count(n,ichannel)/exposure*1000
	end do
	close(2)
end do

write(*,'(a,I5,a)') 'Wrote ', nchannels ,' files to ./data/profiles/'
write(*,*) 'DONE PROCESSING FILES!'

end program profile