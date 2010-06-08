! Apply response files to the PROJECTED SPECTRA
!--------------------------------------------------------------------------------------!
 

program response

use resp_matrix

implicit none

INTEGER						:: i, j, idummy, ia, is, IT
INTEGER,PARAMETER			::	N = 6! N = number of shells, nbins = number of bins 
INTEGER, PARAMETER			:: mresp=1024, nresp=1070
CHARACTER(LEN=1) :: adummy
 

REAL,DIMENSION(1070)	:: synthspec, prospec, dummyspec, ss
REAL,DIMENSION(1024) :: rspec
REAL,DIMENSION(mresp,nresp) :: resp


!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
! MAIN



! Reshape RESPONSE to a matrix
resp = RESHAPE( resp3, (/ 1024, 1070 /) )

	
! ----- Read in dummy spectrum. 
	open(1,file='prospec1.out',form='formatted')
		do i=1,1070
 		read(1,'(i4,a1,e15.4)') idummy,adummy,dummyspec(i)
		end do
 	close(1)

! ----- Convolution of the spectrum with response file
	ss=0
	do i=1,1024
	rspec(i)=sum(resp(i,:)*dummyspec(:))
	end do

! ------ Write out response spectrum
open(2,file='rspec1.out',form='formatted')
do i = 1,1024
write(2,'(i4, a1, e15.4)') i, ' ', rspec(i)
end do
close(2)



! ! ++++++++ Same for all the anuli ++++++++++++++++++++++++++++++++++ 
! !
! ! 
! ! ------SPECTRUM 2
! 	open(1,file='prospec2.out',form='formatted')
! 		do i=1,1070
!  		read(1,'(i4,a1,e15.4)') idummy,adummy,dummyspec(i)
! 		end do
!  	close(1)
! 
! 	ss=0
! 	do i=1,1024
! 	rspec(i)=sum(resp(i,:)*dummyspec(:))
! 	end do
! 
! 	open(2,file='rspectra/rspec2.out',form='formatted')
! 	do i = 1,1024
! 	write(2,'(i4, a1, e15.4)') i, ' ', rspec(i)
! 	end do
! 	close(2)
! 
! 
! 
! ! ------SPECTRUM 3
! 	open(1,file='prospec3.out',form='formatted')
! 		do i=1,1070
!  		read(1,'(i4,a1,e15.4)') idummy,adummy,dummyspec(i)
! 		end do
!  	close(1)
! 
! 	ss=0
! 	do i=1,1024
! 	rspec(i)=sum(resp(i,:)*dummyspec(:))
! 	end do
! 
! 	open(2,file='rspectra/rspec3.out',form='formatted')
! 	do i = 1,1024
! 	write(2,'(i4, a1, e15.4)') i, ' ', rspec(i)
! 	end do
! 	close(2)
! 	
! 	
! 	
! 	
! ! ------SPECTRUM 4	
! 		open(1,file='prospec4.out',form='formatted')
! 		do i=1,1070
!  		read(1,'(i4,a1,e15.4)') idummy,adummy,dummyspec(i)
! 		end do
!  	close(1)
! 
! 	ss=0
! 	do i=1,1024
! 	rspec(i)=sum(resp(i,:)*dummyspec(:))
! 	end do
! 
! 	open(2,file='rspectra/rspec4.out',form='formatted')
! 	do i = 1,1024
! 	write(2,'(i4, a1, e15.4)') i, ' ', rspec(i)
! 	end do
! 	close(2)
! 	
! 	
! 	
! 
! ! ------SPECTRUM 5	
! 		open(1,file='prospec5.out',form='formatted')
! 		do i=1,1070
!  		read(1,'(i4,a1,e15.4)') idummy,adummy,dummyspec(i)
! 		end do
!  	close(1)
! 
! 	ss=0
! 	do i=1,1024
! 	rspec(i)=sum(resp(i,:)*dummyspec(:))
! 	end do
! 
! 	open(2,file='rspectra/rspec5.out',form='formatted')
! 	do i = 1,1024
! 	write(2,'(i4, a1, e15.4)') i, ' ', rspec(i)
! 	end do
! 	close(2)
! 	
! 	
! 	
! 	
! ! ------SPECTRUM 6	
! 		open(1,file='prospec6.out',form='formatted')
! 		do i=1,1070
!  		read(1,'(i4,a1,e15.4)') idummy,adummy,dummyspec(i)
! 		end do
!  	close(1)
! 
! 	ss=0
! 	do i=1,1024
! 	rspec(i)=sum(resp(i,:)*dummyspec(:))
! 	end do
! 
! 	open(2,file='rspectra/rspec6.out',form='formatted')
! 	do i = 1,1024
! 	write(2,'(i4, a1, e15.4)') i, ' ', rspec(i)
! 	end do
! 	close(2)
! 	
! 	
	


end program response