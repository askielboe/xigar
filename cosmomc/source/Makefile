#You may need to edit the library paths for MKL for Intel
#Beware of using optmizations that lose accuracy - may give errors when running

##Uncomment the next line to include dr7 LRG
EXTDATA = 
#EXTDATA = LRG

#set WMAP empty not to compile with WMAP
#WMAP = 
#WMAP = /home/aml1005/WMAP7/likelihood_v4

#Only needed for WMAP
#cfitsio = 
#cfitsio = /usr/local/cfitsio/intel10/64/3.040

#GSL only needed for DR7 LRG
#GSLPATH = 
#GSLPATH = /home/aml1005/libs/gsl

IFLAG = -I
INCLUDE=

#Intel MPI (assuming mpif77 set to point to ifort)
#change -lmkl_ia32 to -lmkl_p3 for MKL versions earlier than 6 (6 needed for ifc 8+) 
# F90C     = mpif90
# FFLAGS = -O2 -ip -W0 -WB -openmp -fpp -DMPI -vec_report0
# LAPACKL = -L/usr/local/intel/mkl/9.1/lib/em64t -lmkl_lapack -lmkl_em64t -lguide -lpthread

#HPCF settings. Use Inteal 9 or 10.1+, not 10.0
#F90C     = mpif90
#FFLAGS = -O2 -Vaxlib -W0 -WB -openmp -fpp -DMPI -vec_report0
#LAPACKL = -L/usr/local/Cluster-Apps/intel/mkl/10.2.2.025/lib/em64t -lmkl_lapack -lmkl -lguide -lpthread
#GSLPATH = /usr/local/Cluster-Apps/gsl/1.9
#cfitsio = /usr/local/Cluster-Users/cpac/cmb/2.1.0/cfitsio
#INCLUDE=

#COSMOS: use "module load cosmolib latest" 
#use "runCosmomc" (globally installed) to run, defining required memory usage
# ifeq ($(COSMOHOST),cosmos)
# F90C = ifort
# FFLAGS = -openmp -O3 -w -fpp2 -DMPI
# LAPACKL = -mkl=sequential -lmkl_lapack -lmpi
# cfitsio = $(CFITSIO)
# WMAP = $(COSMOLIB)/WMAP7
# GSLPATH = $(GSL_ROOT)
# endif

#Intel fortran 8, check you have the latest update from the Intel web pages
#See Makefile_intel for ifc 7.1 or lower (some versions have problems)
#F90C     = ifort
#FFLAGS = -O2 -Vaxlib -ip -W0 -WB -openmp -fpp
#LAPACKL = -L/opt/intel/mkl61/lib/32 -lmkl_lapack -lmkl_ia32 -lguide -lpthread

#G95; make sure LAPACK and MPI libs also compiled with g95
#F90C     = mpif90
#FFLAGS = -O2 -DMPI
#LAPACKL = /LAPACK/lapack_LINUX.a /LAPACK/blas_LINUX.a

#GFortran: if pre v4.3 add -D__GFORTRAN__
F90C     = gfortran
FFLAGS = -O3 -ffree-form -x f95-cpp-input -D__GFORTRAN__
LAPACKL = -Wl,-framework -Wl,accelerate

#SGI, -mp toggles multi-processor. Use -O2 if -Ofast gives problems.
#Not various versions of the compiler are buggy giving erroneous seg faults with -mp.
#Version 7.3 is OK, currently version 7.4 is bugged, as are some earlier versions.
#F90C     = f90
#LAPACKL = -lcomplib.sgimath
#FFLAGS  = -Ofast -mp

#Digital/Compaq fortran, -omp toggles multi-processor
#F90C    = f90
#FFLAGS  = -omp -O4 -arch host -math_library fast -tune host -fpe1
#LAPACKL  = -lcxml

#Absoft ProFortran, single processor, set -cpu:[type] for your local system 
#F90C     = f95
#FFLAGS = -O2 -s -cpu:athlon -lU77 -w -YEXT_NAMES="LCS" -YEXT_SFX="_" 
#LAPACKL =  -llapack -lblas -lg2c 
#IFLAG = -p

#NAGF95, single processor:
#F90C     = f95
#FFLAGS = -DNAGF95 -O3
#LAPACKL = -llapack -lblas -lg2c

#PGF90
#F90C = pgf90
#FFLAGS = -O2 -DESCAPEBACKSLASH
#LAPACKL = -llapack -lblas


#Sun, single processor:
#F90C     = f90
#FFLAGS = -fast -ftrap=%none
#LAPACKL = -lsunperf -lfsu
#LAPACKL = -lsunperf -lfsu -lsocket -lm
#IFLAG = -M

#Sun MPI
#F90C = mpf90
#FFLAGS =  -O4 -openmp -ftrap=%none -dalign -DMPI
#LAPACKL = -lsunperf -lfsu -lmpi_mt
#IFLAG = -M

#Sun parallel enterprise:
#F90C     = f95
#FFLAGS =  -O4 -xarch=native64 -openmp -ftrap=%none
#LAPACKL = -lsunperf -lfsu
#IFLAG = -M


#IBM XL Fortran, multi-processor (run "module load lapack" then run "gmake")
# See also http://cosmocoffee.info/viewtopic.php?t=326
#F90C     = xlf90_r $(LAPACK)
#FFLAGS  = -WF,-DIBMXL -qsmp=omp -qsuffix=f=f90:cpp=F90 -O3 -qstrict -qarch=pwr3 -qtune=pwr3
#INCLUDE = -lessl
#LAPACKL =

PROPOSE = propose.o
CLSFILE = CMB_Cls_simple.o

#Can use params_H if you prefer more generic parameters
PARAMETERIZATION = params_CMB.o

#X-ray source files
XRAYSOURCE = resp_matrix.o xigar_params.o fit_params.o sphvol.o rdata.o xigar.o

F90FLAGS = -DMATRIX_SINGLE $(FFLAGS) $(IFLAG)../camb $(INCLUDE)
LINKFLAGS = -L../camb -lcamb $(LAPACKL)

DISTFILES = ParamNames.o Matrix_utils.o settings.o IO.o GetDist.o

OBJFILES=  ParamNames.o Matrix_utils.o settings.o IO.o cmbtypes.o Planck_like.o  \
	cmbdata.o WeakLen.o bbn.o bao.o lrggettheory.o mpk.o supernovae.o HST.o SDSSLy-a-v3.o \
	$(CLSFILE) paramdef.o $(PROPOSE) $(PARAMETERIZATION) $(XRAYSOURCE) calclike.o \
	conjgrad_wrapper.o EstCovmat.o postprocess.o MCMC.o driver.o


ifeq ($(EXTDATA),LRG)
F90FLAGS += -DDR71RG
OBJFILES += bsplinepk.o
GSLINC = -I$(GSLPATH)/include
LINKFLAGS += -L$(GSLPATH)/lib -lgsl -lgslcblas
endif

ifneq ($(WMAP),)
F90FLAGS += $(IFLAG)$(cfitsio)/include $(IFLAG)$(WMAP)
LINKFLAGS +=  -L$(cfitsio)/lib -L$(WMAP) -lcfitsio

OBJFILES += $(WMAP)/read_archive_map.o \
	$(WMAP)/read_fits.o \
	$(WMAP)/healpix_types.o \
	$(WMAP)/WMAP_7yr_options.o \
	$(WMAP)/WMAP_7yr_util.o \
	$(WMAP)/WMAP_7yr_tt_pixlike.o \
	$(WMAP)/WMAP_7yr_teeebb_pixlike.o \
	$(WMAP)/WMAP_7yr_likelihood.o \
	$(WMAP)/WMAP_7yr_gibbs.o \
	$(WMAP)/WMAP_7yr_tt_beam_ptsrc_chisq.o \
	$(WMAP)/br_mod_dist.o 
else
F90FLAGS += -DNOWMAP
endif

default: cosmomc

all : cosmomc getdist

settings.o: ../camb/libcamb.a
cmbtypes.o: settings.o
Planck_like.o: cmbtypes.o
cmbdata.o: Planck_like.o  $(WMAPOBJS)
WeakLen.o: cmbtypes.o
bbn.o: settings.o
bao.o: cmbtypes.o
mpk.o: cmbtypes.o lrggettheory.o
HST.o: cmbtypes.o
supernovae.o: cmbtypes.o
SDSSLy-a-v3.o: cmbtypes.o
$(CLSFILE): cmbtypes.o mpk.o HST.o bao.o IO.o
paramdef.o: $(CLSFILE)
$(PROPOSE): paramdef.o
$(PARAMETERIZATION): paramdef.o
xigar.o: resp_matrix.o xigar_params.o fit_params.o sphvol.o rdata.o
calclike.o: $(PARAMETERIZATION) xigar.o
conjgrad_wrapper.o: calclike.o
EstCovmat.o: conjgrad_wrapper.o
postprocess.o: calclike.o
MCMC.o: calclike.o
driver.o: MCMC.o

export FFLAGS
export F90C

.f.o:
	f77 $(F90FLAGS) -c $<

%.o: %.c
	$(CC) $(GSLINC) -c $*.c

%.o: %.f90
	$(F90C) $(F90FLAGS) -c $*.f90

%.o: %.F90
	$(F90C) $(F90FLAGS) -c $*.F90


cosmomc: camb $(OBJFILES)
	$(F90C) -o ../cosmomc $(OBJFILES) $(LINKFLAGS) $(F90FLAGS)


clean: cleancosmomc
	rm -f ../camb/*.o ../camb/*.obj ../camb/*.mod

cleancosmomc:
	rm -f *.o *.mod *.d *.pc *.obj ../core 


getdist: camb $(DISTFILES)
	$(F90C) -o ../getdist $(DISTFILES) $(LINKFLAGS) $(F90FLAGS) 

camb:
	cd ../camb && $(MAKE) --file=Makefile_main libcamb.a
