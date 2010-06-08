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

function temp_profile(par1, par2, par3)

	use xigar_params

	REAL,intent(in) 			:: par1, par2, par3
	INTEGER 						:: i
	REAL,DIMENSION(nannuli) :: temp_profile, r
	REAL							:: rtmc
	REAL							:: a 
	REAL							:: b 
	REAL							:: c
	LOGICAL						:: outrange
	
	r=rannuli
	rtmc = par1
	a = par2
	c = par3
	b = 2.
	
	outrange = .false.
	
	do i = 1,nannuli
		temp_profile(i) = tnorm*(r(i)/rtmc)**(-a)/(1+(r(i)/rtmc)**b)**(c/b)
		if (temp_profile(i) < 0.3 .OR. temp_profile(i) > 11.) then
			outrange = .true.
			exit
		end if
	end do
	
	if (outrange .eqv. .true.) then
		do i = 1,nannuli
			temp_profile(i) = 0
		end do
	end if
	
end function temp_profile

function density_profile(par1, par2, par3)

	use xigar_params

	!INTEGER,PARAMETER			:: nannuli = 6
	REAL,intent(in) 			:: par1, par2, par3!, par4
	INTEGER 						:: i
	REAL,DIMENSION(nannuli) :: density_profile, r
	REAL							:: n0mc
	REAL							:: rcmc
	REAL							:: alphamc
	REAL							:: betamc
	
	r=rannuli
	n0mc = par1
	rcmc = par2
	alphamc = par3
	!betamc = par4

	do i = 1,nannuli
		density_profile(i) = n0mc**2 * (r(i)/rcmc)**(-alphamc) / (1+r(i)**2/rcmc**2)**(1-alphamc)
	end do

end function density_profile

function xraylike(Params)

	use xigar_params
	use fit_params
	use rdata
	!use real_data
	!use real_spectrum
	
	! TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY
	REAL,DIMENSION(6,1024) :: rspec
	! TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY

	REAL,DIMENSION(9),intent(in)	:: Params

	INTEGER								:: i,j, cutoff, startoff
	INTEGER,PARAMETER					:: N = nannuli, nbins = nchannels

	REAL,DIMENSION(N)					:: T, rho
	REAL									:: alphamc, betamc
	
	REAL,DIMENSION(N,nchannels)	:: spectrum
	REAL									:: xraylike, chisquare
	
	!T = (/ 7.1676579, 6.8666706, 6.6758351, 6.5216861, 6.3921208, 6.2625418 /)
	T = temp_profile(Params(1),Params(2),Params(3))
	rho = density_profile(Params(4),Params(1),Params(5))
	!rho = (/ 2.52048515E-08,  1.64124643E-08,  1.23813395E-08,  9.80190240E-09,  8.01975997E-09,  6.53458088E-09 /)
	
	!write(*,*) "Temp(1) = ", T(1)
	!write(*,*) "Density(1) = ", rho(1)
	
	alphamc = Params(6)
	!write(*,*) "Alpha = ", alpha
	betamc = 1. ! Params(10) ! Or maybe a constant?
	
	spectrum = prospec(T,rho,alphamc,betamc)
	
	! CALCULATE THE LIKELIHOOD
	! TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY
	rspec = TRANSPOSE(RESHAPE(rspeclong, (/ 1024,6 /)))
	! TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY
	xraylike = 0.
	
	startoff = 1
	cutoff = 500	
	
	do i=1,N
		do j=startoff,nchannels
			if (j > cutoff) exit
! 			write(*,*) "T parameters:", Params(1),Params(2),Params(3),Params(4)
! 			write(*,*) "rho parameters:", Params(5),Params(1),Params(6)
! 			if (T(1) > 0) then
!  				write(*,*) T
! 			end if
! 			write(*,*) rho
!			write(*,*) alpha			
! 			write(*,*) "i = ",i," and j = ",j
! 			write(*,*) "Calculating: (",spectrum(i,j)," - ",rspec(i,j),")^2"
			if (rspec(i,j) > 0) then
				xraylike = xraylike + ( (spectrum(i,j)-rspec(i,j)) )**2./sqrt(rspec(i,j))
			end if
! 			write(*,*) "RESULT: ",( (spectrum(i,j)-rspec(i,j)) )**2.
		end do
	end do
	xraylike = xraylike/cutoff/N
	!write(*,*) xraylike
	write (*,*) Params(3)
	
! 	if (xraylike < 10.) then
	if (T(1) > 0) then
		write(*,*) T
		open(1,file='spectrum.txt',form='formatted')
		do i = startoff,cutoff
			write(1,'(i4, a1, e20.10)') i, ' ', spectrum(1,i)
		end do
		close(1)
			write(*,*) xraylike
		open(1,file='rspec.txt',form='formatted')
		do i = startoff,cutoff
				write(1,'(i4, a1, e20.10)') i, ' ', rspec(1,i)
			end do
		close(1)
	end if
! 	end if

! 	xraylike=(Params(1)-3.)**2. !+ (Params(2) - 10.)**2.

end function xraylike

function prospec(T,rho,alphamc,betamc)

	use xigar_params
	use fit_params
	use sphvol
	use resp_matrix

	INTEGER, PARAMETER				:: mresp=1024, nresp=1070
	REAL,DIMENSION(mresp,nresp) 	:: resp

	INTEGER,PARAMETER					::	N = nannuli, nbins = nchannels
	REAL,intent(in)					:: alphamc, betamc
	REAL,DIMENSION(N),intent(in) 	:: T, rho

	INTEGER								:: i,j
	REAL,DIMENSION(N,nchannels)	:: prospec, prospecraw
	REAL,DIMENSION(N,nchannels)	:: rspec
	!REAL,DIMENSION(nchannels)			::	subspectrum, rdummy
	REAL,DIMENSION(N)					:: a
	REAL,DIMENSION(N,N)				:: V
	REAL									:: exp

	! a (1D array):	Radii for the observational annuli.
	a = rannuli

	! Calculate volume-elements
	V = vol(N, alphamc, betamc, a)

	! Do the projection (YEAH!)
	do i=1,N
		prospecraw(i,:) = 0.
		do j=i,N
			prospecraw(i,:) = prospecraw(i,:) + usynthspec(T(j),rho(j))*V(i,j)
		end do
	end do
	
	! ADD RESOPONSE CONVOLUTION FROM RESPONSE.F90
	
	! Reshape response files into matrices
	resp = RESHAPE( resp3, (/ 1024, 1070 /) )
	
	do i=1,N ! OBS: RESPONSE NEEDS TO CHANGE FOR EACH ANNULUS (i) OF COURSE
		do j=1,nchannels
			prospec(i,j)=sum(resp(j,1:1024)*prospecraw(i,:))
		end do
		prospec(i,nchannels) = 0.
	end do

end function prospec

function usynthspec(T, rho) ! Calculate unit-volume synthetic spectrum for given temperature and density

	use xigar_params
	use fit_params
	use resp_matrix
	!use sphvol

	REAL								:: exp, alphamc, betamc
	INTEGER,PARAMETER				::	N = nannuli, nbins = nchannels
	REAL,intent(in)				:: T, rho
	REAL,DIMENSION(nchannels)	:: usynthspec
	INTEGER							:: i
	REAL,PARAMETER					:: e = 2.71828183, Pi = 3.1415926535897932385

	if (T < param_break) then ! Limits: Lowpar: t = 0..3 keV, Highpar: t = 3..15 keV
		do i = 1,nchannels
			usynthspec(i) = lowpar1(i) * T**3. + lowpar2(i) * T**2. + lowpar3(i)*T + lowpar4(i)
			usynthspec(i) = e**usynthspec(i) * rho
		end do
	else if (T >= param_break) then
		do i = 1,nchannels
			usynthspec(i) = highpar1(i) * T**3. + highpar2(i) * T**2. + highpar3(i)*T + highpar4(i)
			usynthspec(i) = e**usynthspec(i) * rho
		end do
	end if
end function usynthspec

end module xigar