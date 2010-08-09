import numpy as np
from pylab import *

# Set temperature profile parameters
tnorm = 130.
rt = 5.
ta = 1.2
tb = 2.
tc = 0.01

# Set density profile parameters
# n0 = 100., rc = 0.01, da = 1., db = 0.5
n0 = 1.3
rc = 5.
da = 0.9
db = 2.

rmin = 1
rmax = 10
rstep = 1

x = np.arange(rmin,rmax,rstep)
temp = []
rho = []

for r in x:
   temp.append( ((r/rt)**(-ta))/(1.+(r/rt)**tb)**(tc/tb) )
   rho.append( n0**2. * (r/rc)**(-da) / ( (1. + (r/rc)**2.)**(3.*db - da/2) ) )

def doplot():
   figure(1)
   plot(x,temp,0,rmax, label="temp")
   legend()
   
   figure(2)
   semilogy(x,rho,0,rmax, label="density")
   legend()

