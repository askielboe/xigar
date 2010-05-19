FC     = gfortran

response: response.o xigar_params.o resp_matrix.o
	$(FC) -o response response.o xigar_params.o resp_matrix.o

resp_matrix.o:
	$(FC) -c resp_matrix.f90

xigar_params.o:
	$(FC) -c ../xigar_params.f90

response.o: resp_matrix.o xigar_params.o
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
	rm -rf *.out
	rm -rf *.mod
	rm -rf *.so
	rm -rf *.d
	rm -rf ./data/output/*
	rm -rf ./data/profiles/*