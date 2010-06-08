program test

! To compile use: gfortran xigar_params.f90 fit_params.f90 sphvol.f90 resp_matrix.f90 xraylike.f90

use xigar_params
use fit_params
use sphvol
use resp_matrix

implicit none

INTEGER, PARAMETER				:: mresp=1024, nresp=1070
REAL,DIMENSION(mresp,nresp) 	:: resp

INTEGER								:: i, j, idummy, ia, is
INTEGER,PARAMETER					::	N = nannuli, nbins = nchannels ! N = number of shells, nbins = number of bins 

REAL,DIMENSION(nbins)			::	subspectrum, rdummy
REAL,DIMENSION(N)					:: a, T, rho
REAL,DIMENSION(N,N)				:: V
REAL,DIMENSION(N,nchannels)	:: prospec, rspec
REAL,DIMENSION(N,nchannels)	:: prospecraw
REAL									:: chisquare, alphanew
REAL									:: exp
REAL,PARAMETER						:: e = 2.71828183, Pi = 3.1415926535897932385

! --------------------------------- FITTING PARAMETERS ------------------------------- !
! a (1D array):	Radii for the observational annuli.
a = rannuli
! T (1D array):	Temperature profile for the cluster (in annuli bins).
T = (/ 7.1676579, 6.8666706, 6.6758351, 6.5216861, 6.3921208, 6.2625418 /) ! keV
! rho (1D array):	Density profile for the cluster (in annuli bins).
rho = (/ 1.60122525E-07,  4.42100934E-08,  1.89802947E-08,  9.41740463E-09,  5.15803444E-09,  2.79031509E-09 /)

! -------------------------------- CONSTANT PARAMETERS ------------------------------- !
! exp (scalar):	Constant spectrum normalization (exposure). !exp = 4179.6
!exp = 4179600.2
!exp = 0.00001

! ----------------------------------- MAIN PROGRAM ----------------------------------- !
alphanew = 2.6
! Calculate volume-elements
V = vol(N, alphanew, beta, a)

! Do the projection (YEAH!)
do i=1,N
prospecraw(i,:) = 0.
	do j=i,N
		prospecraw(i,:) = prospecraw(i,:) + usynthspec(T(j),rho(j))*V(i,j)
	end do
end do

! Reshape response files into matrices
resp = RESHAPE( resp3, (/ 1024, 1070 /) )

do i=1,N ! OBS: RESPONSE NEEDS TO CHANGE FOR EACH ANNULUS (i) OF COURSE
	do j=1,nchannels
		prospec(i,j)=sum(resp(j,1:1024)*prospecraw(i,1:1024))
	end do
	!prospec(i,nchannels) = 0.
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
do i = 1,nchannels
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(1,i)
end do
close(1)

open(1,file='prospec2.out',form='formatted')
do i = 1,nchannels
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(2,i)
end do
close(1)

open(1,file='prospec3.out',form='formatted')
do i = 1,nchannels
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(3,i)
end do
close(1)

open(1,file='prospec4.out',form='formatted')
do i = 1,nchannels
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(4,i)
end do
close(1)

open(1,file='prospec5.out',form='formatted')
do i = 1,nchannels
	write(1,'(i4, a1, e15.4)') i, ' ', prospec(5,i)
end do
close(1)

open(1,file='prospec6.out',form='formatted')
do i = 1,nchannels
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
	REAL,intent(in)				:: T, rho
	REAL,DIMENSION(nchannels)	:: usynthspec
	INTEGER							:: i

	if (T < param_break) then ! Limits: Lowpar: t = 0..3 keV, Highpar: t = 3..15 keV
		do i = 1,nchannels
			usynthspec(i) = lowpar1(i) * T**3. + lowpar2(i) * T**2. + lowpar3(i)*T + lowpar4(i)
			usynthspec(i) = e**usynthspec(i) * rho
			!write(*,*) nchannels, i, usynthspec(i)
		end do
	else if (T >= param_break) then
		do i = 1,nchannels
			usynthspec(i) = highpar1(i) * T**3. + highpar2(i) * T**2. + highpar3(i)*T + highpar4(i)
			usynthspec(i) = e**usynthspec(i) * rho
			!write(*,*) nchannels, i, usynthspec(i)
		end do
	end if
end function usynthspec

end program test