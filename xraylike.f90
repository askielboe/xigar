program test

use params
use sphvol

implicit none

!REAL,DIMENSION(nbins)		::	lowpar1, lowpar2, lowpar3, lowpar4
!REAL,DIMENSION(nbins)		::	highpar1, highpar2, highpar3, highpar4

INTEGER						:: i, j, idummy, ia, is
INTEGER,PARAMETER			::	N = 6, nbins = 1069 ! N = number of shells, nbins = number of bins 
! I cut this off at the last bin since I get some weird numbers there.
! Other than that ot works fine.
REAL,DIMENSION(nbins)	::	subspectrum, rdummy
REAL,DIMENSION(N)			:: a, T, rho
REAL,DIMENSION(N,N)		:: V
REAL,DIMENSION(N,nbins)	:: synthspec, prospec, rspec
REAL							:: chisquare
REAL							:: exp, alpha, beta
REAL,PARAMETER				:: e = 2.71828183, Pi = 3.1415926535897932385

! --------------------------------- FITTING PARAMETERS ------------------------------- !
! a (1D array):	Radii for the observational annuli.
a = (/ 39.6749, 60.9293, 80.7667, 102.021, 124.692, 153.032 /)
! T (1D array):	Temperature profile for the cluster (in annuli bins).
T = (/ 8., 10., 8., 6., 4., 1. /) ! keV
! rho (1D array):	Density profile for the cluster (in annuli bins).
rho = (/ 10., 9., 7., 4., 1., 0.1 /)
! alpha (scalar):	Axis-ratio runction parameter.
alpha = 10.
! beta (scalar):	Axis-ratio runction parameter.
beta = 1.

! -------------------------------- CONSTANT PARAMETERS ------------------------------- !
! exp (scalar):	Constant spectrum normalization (exposure). !exp = 4179.6
exp = 4179600.2
!exp = 0.00001

! ----------------------------------- MAIN PROGRAM ----------------------------------- !

! Calculate synthetic-(unit-volume)-spectra
do i = 1, N
	synthspec(i,:) = usynthspec(T(i),rho(i))
end do

! Calculate volume-elements
V = vol(N, alpha, beta, a)

! Do the projection (YEAH!)
do i=1,N
prospec(i,:) = 0.
	do j=i,N
		prospec(i,:) = prospec(i,:) + usynthspec(T(j),rho(j))*V(i,j)
	end do
end do

! -------------------------------- CALCULATE CHI-SQUARE ----------------------------- !

! ! Read in real spectrum
! do i=1,N
! 	open(1,file='test.out.real',form='formatted')
! 	do j = 1,nbins
! 		read(1,'(i4, f15.0)') idummy, rspec(i,j)
! 	end do
! 	close(1)
! end do
! 
! chisquare = 0.
! do i=1,N
! 	do j=1,nbins
! 		chisquare = chisquare + ( (prospec(i,j)-rspec(i,j)) / sqrt(prospec(i,j)) )**2 
! 	end do
! end do
! 
! write(*,*) chisquare

! Subtract the two spectra and calculate quality of fit

! Return overall chi-square to cosmomc

! ------------------------------- OUTPUT (FOR DEBUGGING) ---------------------------- !
! open(1,file='sphvol.out',form='formatted')
! do ia = 1,N
! 	do is = 1,N
! 		if (is >= ia) write(*,'(i4,i4,e15.5)') ia, is, vols(ia,is)
! 	end do
! end do
! close(1)

! Polynomial
! double result = par[0] * pow(v[0],3.) + par[1] * pow(v[0],2.) + par[2]*v[0] + par[3];

! do i=1,N
! 	open(1,file='prospec' // str(i) // '.out',form='formatted')
! 	do j = 1,nbins
! 		write(1,'(i3, a1, e15.4)') j, ' ', prospec(i,j)
! 	end do
! 	close(1)
! end do

!Write out prospec
open(1,file='prospec1.out',form='formatted')
do i = 1,nbins
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(1,i)
end do
close(1)

open(1,file='prospec2.out',form='formatted')
do i = 1,nbins
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(2,i)
end do
close(1)

open(1,file='prospec3.out',form='formatted')
do i = 1,nbins
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(3,i)
end do
close(1)

open(1,file='prospec4.out',form='formatted')
do i = 1,nbins
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(4,i)
end do
close(1)

open(1,file='prospec5.out',form='formatted')
do i = 1,nbins
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(5,i)
end do
close(1)

open(1,file='prospec6.out',form='formatted')
do i = 1,nbins
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(6,i)
end do
close(1)

! i = 1
! j = 4
! rdummy = usynthspec(T(j),rho(j))*V(i,j)
! open(1,file='usynthspec4.out',form='formatted')
! do i = 1,nbins
! 	write(1,'(i3, a1, e15.4)') i, ' ', rdummy(i)
! end do
! close(1)



!write(*,*) rspec

! ! Subtract synthetic and real spectrum and calculate chi-square to constant function
! do i = 1,nbins
! 	subspectrum(i) = 2.*(usynthspec(i)-rspec(i))/(usynthspec(i)+rspec(i))
! end do
! 
! open(1,file='test.out.sub',form='formatted')
! do i = 1,nbins
! 	write(1,'(i3, a1, f15.4)') i, ' ', subspectrum(i)
! end do
! close(1)

write(*,*) 'It runs!'

! -------------------------------------- FUNCTIONS ----------------------------------- !

contains

function usynthspec(T, rho) ! Calculate unit-volume synthetic spectrum for given temperature and density
	REAL,intent(in)			:: T, rho
	REAL,DIMENSION(nbins)	:: usynthspec
	INTEGER						:: i

	if (T < 3.) then ! Limits: Lowpar: t = 0..3 keV, Highpar: t = 3..15 keV
		do i = 1,nbins
			usynthspec(i) = lowpar1(i) * T**3. + lowpar2(i) * T**2. + lowpar3(i)*T + lowpar4(i)
			usynthspec(i) = e**usynthspec(i) / exp * rho
		end do
	else if (T >= 3.) then
		do i = 1,nbins
			usynthspec(i) = highpar1(i) * T**3. + highpar2(i) * T**2. + highpar3(i)*T + highpar4(i)
			usynthspec(i) = e**usynthspec(i) / exp * rho
		end do
	end if
end function usynthspec

end program test