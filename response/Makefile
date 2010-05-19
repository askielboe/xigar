FC     = gfortran

response: response.o xigar_params.o resp_matrix.o
	$(FC) -o response response.o xigar_params.o resp_matrix.o

resp_matrix.o: resp_matrix.f90
	$(FC) -c resp_matrix.f90

xigar_params.o: ../xigar_params.f90
	$(FC) -c ../xigar_params.f90

response.o: response.f90 resp_matrix.o xigar_params.o
	$(FC) -c response.f90

# %: %.o
# 	$(FC) $(FCFLAGS) -o $@ $^ $(LDFLAGS)
# 
# %.o: %.f90
# 	$(FC) $(FCFLAGS) -c $<
# 
# %.o: %.F90
# 	$(FC) $(FCFLAGS) -c $<
	
clean:
	rm -rf *.o
	rm -rf *.mod