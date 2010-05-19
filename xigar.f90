module xigar

implicit none

!INTEGER						:: i, j, idummy, ia, is
!INTEGER,PARAMETER			::	N = 6, nbins = nchannels ! N = number of shells, nbins = number of bins 
! I cut this off at the last bin since I get some weird numbers there.
! Other than that ot works fine.
! REAL,DIMENSION(nbins)	::	subspectrum, rdummy
! REAL,DIMENSION(N)			:: a, T, rho
! REAL,DIMENSION(N,N)		:: V
! REAL,DIMENSION(N,nbins)	:: synthspec, prospec, rspec
! REAL							:: chisquare
! REAL							:: exp, alpha, beta
! REAL,PARAMETER				:: e = 2.71828183, Pi = 3.1415926535897932385

! -------------------------------- CONSTANT PARAMETERS ------------------------------- !
! exp (scalar):	Constant spectrum normalization (exposure). !exp = 4179.6
!exp = 4179600.2
!exp = 0.00001

! ! T (1D array):	Temperature profile for the cluster (in annuli bins).
! T = (/ 8., 10., 8., 6., 4., 1. /) ! keV
! ! rho (1D array):	Density profile for the cluster (in annuli bins).
! rho = (/ 10., 9., 7., 4., 1., 0.1 /)
! ! alpha (scalar):	Axis-ratio runction parameter.
! alpha = 10.
! ! beta (scalar):	Axis-ratio runction parameter.
! beta = 1.

contains

function temp_profile(par)

	use xigar_params

	REAL,intent(in) :: par
	INTEGER :: i
	REAL,DIMENSION(nannuli) :: temp_profile
	
	do i = 1,nannuli
		temp_profile(i) = par*i
	end do
	
end function temp_profile

function density_profile(par)

	use xigar_params

	REAL,intent(in) :: par
	INTEGER :: i
	REAL,DIMENSION(nannuli) :: density_profile

	do i = 1,nannuli
		density_profile(i) = par*i
	end do

end function density_profile

function xraylike(Params)

	use xigar_params
	use fit_params
	!use real_spectrum

	REAL,DIMENSION(7),intent(in)	:: Params

	INTEGER								:: i,j
	INTEGER,PARAMETER					::	N = nannuli, nbins = nchannels

	REAL,DIMENSION(N)					:: T, rho
	REAL									:: alpha, beta
	
	REAL,DIMENSION(N,nbins)			:: spectrum
	REAL									:: xraylike, chisquare
	
	T = temp_profile(Params(1))
	rho = density_profile(Params(2))
	
	alpha = Params(3)
	beta = Params(4) ! Or maybe a constant?
	
	spectrum = prospec(T,rho,alpha,beta)
	
	chisquare = 0.
! 	do i=1,N
! 		do j=1,nbins
! 			chisquare = chisquare + ( (spectrum(i,j)-rspec(i,j)) / sqrt(spectrum(i,j)) )**2 
! 		end do
! 	end do

	xraylike=chisquare

end function xraylike

function prospec(T,rho,alpha,beta)

	use xigar_params
	use fit_params
	use sphvol

	REAL :: xraylike

	INTEGER						:: i,j
	INTEGER,PARAMETER			::	N = nannuli, nbins = nchannels
	REAL,DIMENSION(N,nbins)	:: synthspec, prospec, rspec
	REAL,DIMENSION(nbins)	::	subspectrum, rdummy
	REAL,DIMENSION(N)			:: a, T, rho
	REAL,DIMENSION(N,N)		:: V
	REAL							:: exp, alpha, beta

	! a (1D array):	Radii for the observational annuli.
	a = rannuli

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

end function prospec

function usynthspec(T, rho) ! Calculate unit-volume synthetic spectrum for given temperature and density

	use xigar_params
	use fit_params
	!use sphvol

	REAL							:: exp, alpha, beta
	INTEGER,PARAMETER			::	N = nannuli, nbins = nchannels
	REAL,intent(in)			:: T, rho
	REAL,DIMENSION(nbins)	:: usynthspec
	INTEGER						:: i
	REAL,PARAMETER				:: e = 2.71828183, Pi = 3.1415926535897932385

	if (T < param_break) then ! Limits: Lowpar: t = 0..3 keV, Highpar: t = 3..15 keV
		do i = 1,nbins
			usynthspec(i) = lowpar1(i) * T**3. + lowpar2(i) * T**2. + lowpar3(i)*T + lowpar4(i)
			usynthspec(i) = e**usynthspec(i) * rho
		end do
	else if (T >= param_break) then
		do i = 1,nbins
			usynthspec(i) = highpar1(i) * T**3. + highpar2(i) * T**2. + highpar3(i)*T + highpar4(i)
			usynthspec(i) = e**usynthspec(i) * rho
		end do
	end if
end function usynthspec

end module xigar