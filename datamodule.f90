program datamodule

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
INTEGER,DIMENSION(nchannels)				:: channel, count
INTEGER											:: i, n, ichannel
REAL,DIMENSION(nspectra+1)					:: params
REAL												:: param, stepsize
CHARACTER 										:: dummy*7, fnamein*50, fnameout*50

!-------------------------------------------------------------------
! Read in parameters from TCL logfile
! open(1,file='./data/output/parameters.dat', status='old', form='FORMATTED')
! read(1,*) param_min, param_max, exposure, nchannels, nspectra
! close(1)
!-------------------------------------------------------------------

n = 1
	
open(2,file='real_data.f90',form='formatted')
write(2,'(a)') 'MODULE rdata'
write(2,'(a)') 'IMPLICIT NONE'


	do while (n <= nannuli)
		if (n<10) then 
			write(fnamein,'(a,a,a,a,I1,a)') './data/clusters/',cname,'/',cprefix,n,'.txt'
		else
			write(fnamein,'(a,a,a,a,I2,a)') './data/clusters/',cname,'/',cprefix,n,'.txt'
		end if			
		write(*,*) cprefix
		write(*,'(a,a)') 'Reading file: ', fnamein
		open(1,file=fnamein,form='formatted')
			read(1,*) dummy ! Skip the column names
			read(1,*) dummy 
			do i = 1,1024
				read(1,*) channel(i), count(i)
			end do
		close(1)
		
		if (n<10) then 		
			write(2,'(a,I4,a,I1,a)') 'REAL,DIMENSION(',nchannels,') :: rdata',n,'= (/ &'
		else
			write(2,'(a,I4,a,I2,a)') 'REAL,DIMENSION(',nchannels,') :: rdata',n,'= (/ &'
		end if
		do i=1,nchannels-1
			write(2,'(I5,a)') count(i),', &'
		end do
		write(2,'(I5,a)') count(nchannels),' /)'
		n = n + 1
	end do

write(2,'(a)') 'END MODULE rdata'
close(2)

write(*,*) 'DONE PROCESSING FILES!'

end program datamodule