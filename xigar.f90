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

function temp_profile(par1, par2, par3, par4)

	use xigar_params

	REAL,intent(in) 			:: par1, par2, par3, par4
	INTEGER 						:: i
	REAL,DIMENSION(nannuli) :: temp_profile, r
	REAL							:: rt
	REAL							:: a 
	REAL							:: b 
	REAL							:: c
	
	r=rannuli
	rt = par1
	a = par2
	b = par3
	c = par4
		
	do i = 1,nannuli
		temp_profile(i) = (r(i)/rt)**(-a)/(1+(r(i)/rt)**b)**(c/b)
	end do
	
end function temp_profile

function density_profile(par1, par2, par3, par4)

	use xigar_params

	REAL,intent(in) 			:: par1, par2, par3, par4
	INTEGER 						:: i
	REAL,DIMENSION(nannuli) :: density_profile, r
	REAL							:: n0
	REAL							:: rc 
	REAL							:: alpha 
	REAL							:: beta 
	
	r=rannuli
	n0 = par1
	rc = par2
	alpha = par3
	beta = par4

	do i = 1,nannuli
		density_profile(i) = n0**2 * (r(i)/rc)**(-alpha) / (1+r(i)**2/rc**2)**(3*beta-alpha/2)
	end do

end function density_profile

function xraylike(Params)

	use xigar_params
	use fit_params
	!use real_data
	!use real_spectrum

	REAL,DIMENSION(9),intent(in)	:: Params

	INTEGER								:: i,j
	INTEGER,PARAMETER					::	N = nannuli, nbins = nchannels

	REAL,DIMENSION(N)					:: T, rho
	REAL									:: alpha, beta
	
	REAL,DIMENSION(N,nbins)			:: spectrum
	REAL									:: xraylike, chisquare
	
	T = temp_profile(Params(1),Params(2),Params(3),Params(4))
	rho = density_profile(Params(5),Params(6),Params(7),Params(8))
	
	alpha = Params(9)
	beta = 1. ! Params(10) ! Or maybe a constant?
	
	spectrum = prospec(T,rho,alpha,beta)
	
	!chisquare = 0.
! 	do i=1,N
! 		do j=1,nbins
! 			chisquare = chisquare + ( (spectrum(i,j)-rspec(i,j)) / sqrt(spectrum(i,j)) )**2 
! 		end do
! 	end do

	xraylike=(Params(1)-3.)**2. !+ (Params(2) - 10.)**2.

end function xraylike

function prospec(T,rho,alpha,beta)

	use xigar_params
	use fit_params
	use sphvol
	!use resp_matrix.f90

	REAL,intent(in)					:: , alpha, beta
	REAL,DIMENSION(N),intent(in) 	:: T, rho
	REAL 									:: xraylike

	INTEGER						:: i,j
	INTEGER,PARAMETER			::	N = nannuli, nbins = nchannels
	REAL,DIMENSION(N,nbins)	:: synthspec, prospec, rspec
	REAL,DIMENSION(nbins)	::	subspectrum, rdummy
	REAL,DIMENSION(N)			:: a
	REAL,DIMENSION(N,N)		:: V
	REAL							:: exp

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
	
	! ADD RESOPONSE CONVOLUTION FROM RESPONSE.F90

end function prospec

function usynthspec(T, rho) ! Calculate unit-volume synthetic spectrum for given temperature and density

	use xigar_params
	use fit_params
	use resp_matrix
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