source settings.sh
# Copy general xigar files (parameters)
rsync -t xigar_params.f90 $COSMO/source/xigar_params.f90
# Copy common code
rsync -t ./common/sphvol.f90 $COSMO/source/sphvol.f90
# Copy cosmomc source code
rsync -t ./cosmomc/xigar.f90 $COSMO/source/xigar.f90
rsync -t ./cosmomc/fit_params.f90 $COSMO/source/fit_params.f90
# Copy cosmomc settings
rsync -t ./cosmomc/params_xray.ini $COSMO/params_xray.ini
# Copy data
rsync -t ./data/spectra/rdata.f90 $COSMO/source/rdata.f90
rsync -t ./data/response/resp_matrix.f90 $COSMO/source/resp_matrix.f90