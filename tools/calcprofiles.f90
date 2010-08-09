program calcprofiles

use xigar_params

implicit none

INTEGER,PARAMETER	:: N = nannuli

REAL,DIMENSION(N) :: r

INTEGER				:: i
REAL,DIMENSION(N)	:: temp_profile, density_profile

! Calculate profiles

r = rannuli

do i = 1,nannuli
	temp_profile(i) = tnorm*(r(i)/rt)**(-ta)/(1+(r(i)/rt)**tb)**(tc/tb)
end do

do i = 1,nannuli
	!density_profile(i) = n0**2. * (r(i)/rc)**(-da) / (1.+r(i)**2./rc**2.)**(3*db-da/2.)
	density_profile(i) = n0**2 * (r(i)/rc)**(-da) / (1+r(i)**2/rc**2)**(1-da)
end do

write(*,*) "Temp profile: ", temp_profile
write(*,*) "Density profile: ", density_profile

end program calcprofiles