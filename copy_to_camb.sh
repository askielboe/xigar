source settings.sh
# Copy general xigar files (parameters)
rsync -t $XIGAR/xigar_params.f90 $COSMO/source/xigar_params.f90
# Copy common code
rsync -t $XIGAR/common/sphvol.f90 $COSMO/source/sphvol.f90
# Copy cosmomc source code
rsync -t $XIGAR/cosmomc/xigar.f90 $COSMO/source/xigar.f90
rsync -t $XIGAR/cosmomc/fit_params.f90 $COSMO/source/fit_params.f90
# Copy cosmomc settings
rsync -t $XIGAR/cosmomc/params_xray.ini $COSMO/params_xray.ini
# Copy data
rsync -t $XIGAR/data/spectra/rdata.f90 $COSMO/source/rdata.f90
rsync -t $XIGAR/data/response/resp_matrix.f90 $COSMO/source/resp_matrix.f90
# Copy files for monitoring fit convergence
rsync -t $XIGAR/cosmomc/empty.txt $COSMO/empty.txt
rsync -t $XIGAR/cosmomc/worstxraylike.txt $COSMO/worstxraylike.txt
# Copy 'makefile'
rsync -t $XIGAR/cosmomc/domake.sh $COSMO/domake.sh