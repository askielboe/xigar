program response

use xspec_params

implicit none

!REAL,DIMENSION(nbins)		::	lowpar1, lowpar2, lowpar3, lowpar4
!REAL,DIMENSION(nbins)		::	highpar1, highpar2, highpar3, highpar4

INTEGER						:: i, j, idummy, ia, is, IT
INTEGER,PARAMETER			::	N = 6, nbins = nchannels ! N = number of shells, nbins = number of bins 
INTEGER, PARAMETER			:: mresp=1024, nresp=1070
! I cut this off at the last bin since I get some weird numbers there.
! Other than that ot works fine.
REAL,DIMENSION(nbins)	::	subspectrum, rdummy
real, DIMENSION(1024,1070) :: x,q

REAL,DIMENSION(1070)	:: synthspec, prospec, dummyspec
REAL,DIMENSION(1024) :: rspec
REAL,DIMENSION(nresp,mresp) :: resp
REAL							:: chisquare, ss

!!------Read in response matrix
open(1,file='response_matrix.txt',form='formatted')
		do j=1,1024
			read(1,*) (x(j,i),i=1,1070)
		end do
close(1)

!! Read in dummy spectrum
 	open(1,file='test.spectrum.txt',form='formatted')
 		do i = 1,nbins
 			read(1,'(i4, f15.0)') idummy, dummyspec(i)
 		end do
 	close(1)

!! Convolution of the spectrum with response file

do i=1,1024
! 	rspec(i) = 0.
! 	do j=1,1070
! 		rspec(i) = rspec(i) + x(i,j)*dummyspec(j)
! 	end do
	rspec(i)=dot_product(x(i,:),dummyspec(:))
end do

!Write out rspec
open(1,file='rspec.txt',form='formatted')
	do i = 1,1024
		write(1,'(i4, a1, e15.4)') i, ' ', rspec(i)
	end do
close(1)

end program response