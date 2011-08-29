module sphvol

implicit none

! ! FUNCTION & PARAMETER DEFINITION
! proc func_b {a alpha} {
! 	set beta 1.
! 
! 	# Define b(a) = a*(beta + alpha * a)
! 	set b [expr $a*($beta + $alpha*$a)] ; # Spherical center, elliptical exterior
! 	# set b [expr $a*(1 + $alpha - $alpha*$a)] ; # Elliptic center, spherical exterior
! 	return $b
! }

!a = (/ 39.6749, 60.9293, 80.7667, 102.021, 124.692, 153.032 /)

contains

function vol(i, alpha, beta, a)

REAL,PARAMETER						:: e = 2.71828183, Pi = 3.1415926535897932385
INTEGER								:: counter
INTEGER, intent(in)				:: i
REAL, intent(in)					:: alpha, beta
REAL,DIMENSION(i), intent(in)	:: a
REAL,DIMENSION(i)					::	b
REAL,DIMENSION(i,i)				:: vol
INTEGER								:: is, ia

! b = 1./0.7*a
b = a*(beta + alpha*a)
! b = a*Exp(alpha*Log(a)+beta)
!b = a*(alpha*Log(a) + beta)
! b = Log10(a)*a**2+beta*a
!write(*,*) b

!! Prevent the cluster from going from prolate to oblate, instead we enforce prolate -> spherical.
! do counter = 1, i
! 	if (b(counter) < a(counter)) then
! 		b(counter) = a(counter)
! 	end if
! end do

ia = 1
do
	if (ia > i) exit
	is = 1
	do
		if (is > i) exit
		if (is < ia) then
			vol(ia,is) = 0. !do Nothing (volume is not defined because the shell never crosses the annulae). We set this to zero to catch wrong reaults in the main code.
		else if (ia == 1 .and. is == 1) then ! The innermost volume (for is = 1 and ia = 1) is simply the volume of the spherodial core.
			vol(ia,is) = vs(1,1)
		else if (ia == 1) then
			vol(ia,is) = vcut(ia,is) - vcut(ia,is-1)
		else if (ia == is) then
			vol(ia,is) = vs(ia,is) - vcut(ia-1,is)
		else
			vol(ia,is) = vcut(ia,is) - vcut(ia-1,is) - (vcut(ia,is-1) - vcut(ia-1,is-1))
		end if		
		is = is + 1
	end do
	ia = ia + 1
end do

contains

! open(1,file='sphvol.out',form='formatted')
! do ia = 1,i
! 	do is = 1,i
! 		if (is >= ia) write(*,'(i4,i4,e15.5)') ia, is, vol(ia,is)
! 	end do
! end do
! close(1)

! Define functions
function vs(ia, is)
	INTEGER, intent(in)	:: ia, is
	REAL 					:: vs
	vs = 4./3. * Pi * a(is)**2. * b(is)
end function vs

function ve(ia, is)
	INTEGER, intent(in)	:: ia, is 
	REAL					:: k, ve
	k = 1.-a(ia)**2./a(is)**2.
	ve = 1./3.*Pi*a(is)**2*b(is)*(2.-3.*sqrt(k) + sqrt(k)**3.)
end function ve

function vc(ia, is)
	INTEGER, intent(in)	:: ia, is
	REAL					:: k, vc
	k = 1.-a(ia)**2./a(is)**2.
	vc = 2.*Pi*a(ia)**2.*b(is)*sqrt(k)
end function

function vcut(ia, is)
	INTEGER, intent(in)	:: ia, is
	REAL					:: vcut
	vcut = 2.*ve(ia, is) + vc(ia, is)
end function

! function vshell(a, b, amin, bmin)
! 	INTEGER, intent(in)	:: a, b, amin, bmin
! 	REAL					:: vshell
! 	vshell = vcut(a, b) - vcut(amin, bmin)
! end function

end function vol

end module sphvol