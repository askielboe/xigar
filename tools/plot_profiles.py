# Plot histograms
import matplotlib.pyplot as plt

# Set resolution
res = 100

###################### Calculate true profiles ######################
r = []
TTrue = []
rhoTrue = []

## True density parameters
rcrho = 0.15
nrho = 1.
arho = 0.8
brho = 0.7 # NOT FITTED FOR

## True temperature parameters
rcT = 0.15
nT = 5. # NOT FITTED FOR
aT = 2.5
bT = 0.7

for i in range(res):
	r.append((i+1.)/res)
	TTrue.append( nT * (1 + aT * r[i]/rcT) / ((1 + (r[i] / rcT)**2)**bT) )
	rhoTrue.append( nrho**2 * (r[i]/res /rcrho)**(-1/2*arho) / (1 + (r[i]/rcrho)**2)**(3/2 * brho - 1/4*arho) )

###################### Calculate low MCMC profiles ######################
TMCMClow = []
rhoMCMClow = []

## True density parameters
rcrho = 0.13
nrho = 0.85
arho = 0.45
brho = 0.7 # NOT FITTED FOR

## True temperature parameters
rcT = 0.125
nT = 5. # NOT FITTED FOR
aT = 1.
bT = 0.5

for i in range(res):
	TMCMClow.append( nT * (1 + aT * r[i]/rcT) / ((1 + (r[i] / rcT)**2)**bT) )
	rhoMCMClow.append( nrho**2 * (r[i]/res /rcrho)**(-1/2*arho) / (1 + (r[i]/rcrho)**2)**(3/2 * brho - 1/4*arho) )

###################### Calculate mean MCMC profiles ######################
TMCMCmean = []
rhoMCMCmean = []

## True density parameters
rcrho = 0.145
nrho = 1.
arho = 0.8
brho = 0.7 # NOT FITTED FOR

## True temperature parameters
rcT = 0.145
nT = 5 # NOT FITTED FOR
aT = 1.5
bT = 0.7

for i in range(res):
	TMCMCmean.append( nT * (1 + aT * r[i]/rcT) / ((1 + (r[i] / rcT)**2)**bT) )
	rhoMCMCmean.append( nrho**2 * (r[i]/res /rcrho)**(-1/2*arho) / (1 + (r[i]/rcrho)**2)**(3/2 * brho - 1/4*arho) )

###################### Calculate max MCMC profiles ######################
TMCMCmax = []
rhoMCMCmax = []

## True density parameters
rcrho = 0.16
nrho = 1.15
arho = 1.
brho = 0.7 # NOT FITTED FOR

## True temperature parameters
rcT = 0.16
nT = 5. # NOT FITTED FOR
aT = 2.2
bT = 0.8

for i in range(res):
	TMCMCmax.append( nT * (1 + aT * r[i]/rcT) / ((1 + (r[i] / rcT)**2)**bT) )
	rhoMCMCmax.append( nrho**2 * (r[i]/res /rcrho)**(-1/2*arho) / (1 + (r[i]/rcrho)**2)**(3/2 * brho - 1/4*arho) )
	
######################        PLOTTING         ######################

## Plot Temperature

# plt.semilogx()
# 
# plt.xlabel('r') 
# plt.ylabel('T')
# 
# plt.plot(r, TTrue)
# plt.plot(r, TMCMClow, 'k:')
# plt.plot(r, TMCMCmean, 'k--')
# plt.plot(r, TMCMCmax, 'k:')

## Plot density

plt.loglog()

plt.xlabel('r') 
plt.ylabel('rho')

plt.plot(r, rhoTrue)
plt.plot(r, rhoMCMClow, 'k:')
plt.plot(r, rhoMCMCmean, 'k--')
plt.plot(r, rhoMCMCmax, 'k:')