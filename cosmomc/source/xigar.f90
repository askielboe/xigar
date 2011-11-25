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

	INTEGER,PARAMETER			:: N = nannuli*resolution
	REAL,intent(in) 			:: par1, par2, par3
	INTEGER 					:: i
	REAL,DIMENSION(N)			:: temp_profile, r
	REAL						:: tzero
	REAL						:: rtmc
	REAL						:: a
	REAL						:: b 
	REAL						:: c
	LOGICAL						:: outrange
	
	r = rannuli_resolved
	tzero = 5.
	rtmc = par1
	a = par2
	b = par3
	!c = 0.01
	
	outrange = .false.
	
	do i = 1,N
		! OLD PROFILE
		! temp_profile(i) = tzero*(r(i)/rtmc)**(-a)/(1+(r(i)/rtmc)**b)**(c/b)
		! NEW PROFILE
		temp_profile(i) = tzero*(1.+a*r(i)/rtmc)/((1.+(r(i)/rtmc)**2.)**b)
		! write(*,*) "temp_profile(",i,") = ",temp_profile(i)

! 		! OUTRANGE METHOD 1:
! 		if (temp_profile(i) < 0.3 .OR. temp_profile(i) > 11.) then
! 			outrange = .true.
! 			exit
! 		end if

		! OUTRANGE METHOD 2:
		if (temp_profile(i) < 0.3) then
			temp_profile(i) = 0.3
		else if (temp_profile(i) > 12.) then
			temp_profile(i) = 12.
		end if


	end do
	
	if (outrange .eqv. .true.) then
		do i = 1,N
			temp_profile(i) = 0.
		end do
	end if
	
end function temp_profile

function density_profile(par1, par2, par3, par4)

	use xigar_params

	!INTEGER,PARAMETER			:: nannuli = 6
	INTEGER,PARAMETER			:: N = nannuli*resolution
	REAL,intent(in) 			:: par1, par2, par3, par4
	INTEGER 						:: i
	REAL,DIMENSION(N) 		:: density_profile, r
	REAL							:: n0mc
	REAL							:: rcmc
	REAL							:: alphamc
	REAL							:: betamc
	
	r = rannuli_resolved
	n0mc = par1
	rcmc = par2
	alphamc = par3
	betamc = par4
	! betamc = 0.7 ! debsity beta

	do i = 1,N
		! OLD PROFILE density_profile(i) = n0mc**2 * (r(i)/rcmc)**(-alphamc) / (1+r(i)**2/rcmc**2)**(1-alphamc)
		! NEW PROFILE
		density_profile(i) = n0mc * (r(i)/rcmc)**(-alphamc/2.) / (1+r(i)**2/rcmc**2)**(3./2.*betamc-alphamc/4.)
		! write(*,*) "n0mc, rcmc, alphamc, betamc = ",n0mc,rcmc,alphamc,betamc
		! write(*,*) "density_profile(",r(i),") = ", density_profile(i)
	end do

end function density_profile

function xraylike(Params)

	use xigar_params
	use fit_params
	use rdata
	!use real_data
	!use real_spectrum
	
	! TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY
	REAL,DIMENSION(nannuli,nchannels) :: rspec
	! TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY - TEMPORARY

	REAL,DIMENSION(9),intent(in)	:: Params

	INTEGER								:: i,j,bin
	INTEGER,PARAMETER					:: startoff = 25, cutoff = 350 ! Define range in which the fit tries to converge
	INTEGER,PARAMETER					:: N = nannuli*resolution, nbins = nchannels

	REAL,DIMENSION(N)					:: T, Treal, rho, rhoreal
	REAL									:: alphamc, betamc
	
	REAL,DIMENSION(cutoff-startoff)	:: spectrum_summed, rspec_summed
	REAL,DIMENSION(nannuli,nchannels)	:: spectrum, rspec_nannuli
	REAL									:: xraylike, bestxraylike, chisquare, reallike
	
	! write(*,*) "FUNCTION: XRAYLIKE CALLED"
	
	!T = (/ 7.1676579, 6.8666706, 6.6758351, 6.5216861, 6.3921208, 6.2625418 /)
	T = temp_profile(Params(1),Params(2),Params(3))
! 	if (T(1) == 0) then ! If themperature is out of range, stop and return likelihood = 0.
! 		xraylike = 10.E10
! 		return
! 	end if
	
	! Get profiles from MCMC parameters
	rho = density_profile(Params(4),Params(1),Params(5),Params(6))
	alphamc = Params(7)
	betamc = Params(8)
	
	! Generate spectrum using parameters
	spectrum = prospec(T,rho,alphamc,betamc)
	
	! Reshape and sum 'real' spectrum for comparison
	rspec = TRANSPOSE(RESHAPE(rspeclong, (/ nchannels,nannuli /)))
! 	bin = 1
! 	do i = 1,nannuli
! 		rspec_nannuli(i,:) = 0.
! 		do j = 1,resolution
! 			rspec_nannuli(i,:) = rspec_nannuli(i,:) + rspec(bin,:)
! 			bin = bin + 1
! 		end do
! 	end do
	
	!rho = (/ 2.52048515E-08,  1.64124643E-08,  1.23813395E-08,  9.80190240E-09,  8.01975997E-09,  6.53458088E-09 /)
	
	!write(*,*) "Temp(1) = ", T(1)
	!write(*,*) "Density(1) = ", rho(1)
	
	!write(*,*) "Alpha = ", alpha
	!betamc = 3.0 ! Beta sphvol! Params(10) ! Or maybe a constant? ! Beta sphvol!
	
	! CALCULATE THE LIKELIHOOD
	
	xraylike = 0.
	
! ------------------------ OLD METHOD: SUM INDIVIDUALLY ------------------------
	
	do i=1,nannuli
		do j=startoff,cutoff
			if (j > cutoff) exit
! 			write(*,*) "T parameters:", Params(1),Params(2),Params(3),Params(4)
! 			write(*,*) "rho parameters:", Params(5),Params(1),Params(6)
! 			if (T(1) > 0) then
!  				write(*,*) T
! 			end if
! 			write(*,*) rho
! 			write(*,*) alpha			
! 			write(*,*) "i = ",i," and j = ",j
! 			write(*,*) "Calculating: (",spectrum(i,j)," - ",rspec(i,j),")^2"
			!if (spectrum(i,j) > 0) then
				xraylike = xraylike + ( (spectrum(i,j)-rspec(i,j)) )**2./rspec(i,j)
				! Monitoring output:
! 				write(*,*) "( (spectrum(i,j)-rspec(i,j)) )**2. / rspec(i,j) = ",( (spectrum(i,j)-rspec(i,j)) )**2., & 
! 				" / ",rspec(i,j)," = ", ( (spectrum(i,j)-rspec(i,j)) )**2./rspec(i,j)
! 				write(*,*) "xraylike = ",xraylike
			
		end do
		!write(*,*) "xraylike summed up to bin ",i," = ",xraylike
	end do
	xraylike = xraylike/nannuli
	!xraylike = xraylike/(cutoff-startoff)/nannuli
	!write(*,*) "xraylike = ",xraylike
	!write (*,*) Params(3)

! ------------------------ OLD METHOD: SUM INDIVIDUALLY ------------------------

! ------------------------ NEW METHOD: SUM FIRST, THEN CALCULATE LIKELIHOOD ------------------------
! ------------------------ WARNING!!! DOES NOT WORK!!! ------------------------
! do i = startoff,cutoff
! 	if (i > cutoff) exit
! 	spectrum_summed(i) = 0.
! 	rspec_summed(i) = 0.
! 	do j=1,N
! 		spectrum_summed(i) = spectrum_summed(i) + spectrum(j,i)
! 		rspec_summed(i) = rspec_summed(i) + rspec(j,i)
! 	end do
! end do
! 
! do i = startoff,cutoff
! 	xraylike = xraylike + ( (spectrum_summed(i)-rspec_summed(i)) )**2./spectrum_summed(i)
! end do
! 
! xraylike = xraylike/(cutoff-startoff)/N
! ------------------------ WARNING!!! DOES NOT WORK!!! ------------------------
! ------------------------ NEW METHOD: SUM FIRST, THEN CALCULATE LIKELIHOOD ------------------------

if (exp(-1./2.*xraylike) .ge. 0.0) then
	! Write all parameters to files in each iteration, to look for degeneracy.
! 	open(1,file='parameters.txt',access = 'append')
! 	write(1,*) exp(-1./2.*xraylike), Params	
! 	write(1,'(F20.10,F20.10,F20.10,F20.10,F20.10,F20.10,F20.10,F20.10,F20.10,F20.10)') exp(-1./2.*xraylike), Params
! 	write(*,*) exp(-1./2.*xraylike), Params
! 	close(1)

	! Calculate if this chi2 is better than previous ones. If it is, we print the spectra to files.
	open(1,file='bestxraylike.txt',form='formatted')
	read(1,*) bestxraylike
	close(1)
	!write(*,*) "COMPARING: ", xraylike, " < ", bestxraylike, " RESULT = ", (xraylike < bestxraylike)
	!if (.TRUE.) then
	if (xraylike < bestxraylike) then
		write(*,*) "NEW BEST CHI2: ", xraylike, "LIKELIHOOD: ", exp(-1./2.*xraylike)
		write(*,*) "BEST PARAMETERS: ", Params
		open(1,file='bestxraylike.txt',form='formatted')
		write(1,'(ES20.10)') xraylike
		close(1)
		!if (T(1) > 0) then
		!write(*,*) T
		! ! ! ! ! ! ! ! ! WRITE MCMC SPECTRUM ! ! ! ! ! ! ! ! !
		open(1,file='spectrum.txt',form='formatted')
		do i = startoff,cutoff
			if (i > cutoff) exit
			spectrum_summed(i) = 0.
			do j=1,nannuli
				spectrum_summed(i) = spectrum_summed(i) + spectrum(j,i)
			end do
			write(1,'(i4, a1, ES20.10)') i, ' ', spectrum_summed(i)
		end do
		close(1)
		! ! ! ! ! ! ! ! ! WRITE REAL SPECTRUM ! ! ! ! ! ! ! ! !
		open(1,file='rspec.txt',form='formatted')
		open(2,file='dummy.txt',form='formatted')
		do i = startoff,cutoff
			if (i > cutoff) exit
			rspec_summed(i) = 0.
			do j=1,nannuli
				rspec_summed(i) = rspec_summed(i) + rspec(j,i)
			end do
			write(1,'(i4, a1, ES20.10)') i, ' ', rspec_summed(i)
			write(2,'(i4, a1, ES20.10)') i, ' ', rspec_summed(i)
		end do
		close(2)
		close(1)
		! ! ! ! ! ! ! ! ! WRITE TEMP PROFILE ! ! ! ! ! ! ! ! !
!		open(1,file='temp_profile.txt',form='formatted')
!		Treal = temp_profile(0.15,2.5,0.7)
!		do i = 1,N
!			if (i > N) exit
!			write(1,'(i4, a1, e20.10, a1, e20.10)') i, ' ', Treal(i), ' ', T(i)
!		end do
!		close(1)
		!end if
	end if
end if

!Used when you want to plug in your own CMB-independent likelihood function:
!set generic_mcmc=.true. in settings.f90, then write function here returning -Ln(Likelihood)
xraylike = exp(-1./2.*xraylike)
xraylike = -Log(xraylike)

return
end function xraylike

function prospec(T,rho,alphamc,betamc)
! Functions generates spectrum of (nannuli,nchannels) using profiles from MCMC.
	use xigar_params
	use fit_params
	use sphvol
	!use resp_matrix

	!INTEGER, PARAMETER				:: mresp=nchannels, nresp=nchannels2
	!REAL,DIMENSION(mresp,nresp) 	:: resp

	INTEGER,PARAMETER					::	N = nannuli*resolution, nbins = nchannels
	REAL,intent(in)					:: alphamc, betamc
	REAL,DIMENSION(N),intent(in) 	:: T, rho

	INTEGER								:: i,j,bin
	REAL,DIMENSION(nannuli,nchannels) :: prospec
	REAL,DIMENSION(N,nchannels)	:: prospecraw
	REAL,DIMENSION(N,nchannels)	:: rspec
	!REAL,DIMENSION(nchannels)			::	subspectrum, rdummy
	REAL,DIMENSION(N)					:: a
	REAL,DIMENSION(N,N)				:: V
	REAL									:: exp

	! a (1D array):	Radii for the observational annuli.
	a = rannuli_resolved

	! Calculate volume-elements
	V = vol(N, alphamc, betamc, a)

	! Do the projection (YEAH!)
	do i=1,N
		prospecraw(i,:) = 0.
		do j=i,N
			prospecraw(i,:) = prospecraw(i,:) + usynthspec(T(j),rho(j))*V(i,j)
			!write(*,*) "V(i,j) = V(",i,",",j,") = ",V(i,j)
		end do
	end do
	
	! Sum spectra
	bin = 1
	do i = 1,nannuli
		prospec(i,:) = 0.
		do j = 1,resolution
			prospec(i,:) = prospec(i,:) + prospecraw(bin,:)
			bin = bin + 1
		end do
	end do
	
	
! 	! --------------------- ADD RESOPONSE CONVOLUTION ---------------------
! 	if (use_external_response) then
! 		!write(*,*) "APPLYING EXTERNAL RESPONSE"
!		prospec = prospecraw
! 	else if (.NOT. use_external_response) then
! 		!write(*,*) "APPLYING INTERNAL RESPONSE MATRICES"
! 		! Reshape response files into matrices
! 		resp = RESHAPE( resp3, (/ nchannels, nchannels2 /) )
! 
! 		do i=1,N ! OBS: RESPONSE NEEDS TO CHANGE FOR EACH ANNULUS (i) OF COURSE
! 			do j=1,nchannels
! 				prospec(i,j)=sum(resp(j,1:nchannels)*prospecraw(i,:))
! 			end do
! 			prospec(i,nchannels) = 0.
! 		end do
! 		
! 	
! 	end if
! 	! --------------------- ADD RESOPONSE CONVOLUTION ---------------------

end function prospec

function usynthspec(T, rho) ! Calculate unit-volume synthetic spectrum for given temperature and density

	use xigar_params
	use fit_params
	!use resp_matrix
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
			usynthspec(i) = exp(usynthspec(i)) * rho ** 2. * scale !* exposure
			!write(*,*) "usynthspec(i) = ",usynthspec(i)
		end do
	else if (T >= param_break) then
		do i = 1,nchannels
			usynthspec(i) = highpar1(i) * T**3. + highpar2(i) * T**2. + highpar3(i)*T + highpar4(i)
			usynthspec(i) = exp(usynthspec(i)) * rho ** 2. * scale !* exposure
			!write(*,*) "usynthspec(i) = ",usynthspec(i)
		end do
	end if
end function usynthspec

end module xigar
