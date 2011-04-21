X-igar v0.1 x 10^-23
====================

Minimum requirements
--------------------

* [COSMOMC](http://cosmologist.info/cosmomc/)
* [ROOT](http://root.cern.ch/drupal/content/downloading-root)
* [XSPEC + FTOOLS](http://heasarc.nasa.gov/docs/software/lheasoft/download.html) -- `remember to select FTOOLS along with XSPEC`
* FORTRAN compiler

Setup
-----

* Edit settings.sh and settings.tcl to point to the correct directories.
* Make the following directories: tmp, data, data/fakec, data/spectra.
* Right now you will need the following response files in order to fake spectra: Cluster: A2218, 1666_3.wrmf and 1666_3.warf. Put these files in data/clusters/A2218. (NOT INCLUDED)

Usage
-----
Global settings:
* Edit config/fakec.tcl to match your preferences

Generating fake observational data to use as real observational data in COSMOMC:
* Source xspecpro/xspecpro.sh
* Copy data/clusters/fakec/fakec.f90 to data/spectra/rdata.f90

Generate parameters for use in COSMOMC to synthesize spectra:
* Run xigar.sh

Running the MCMC (COSMOMC):
* Edit cosmomc/params_xray.ini to match your preferences
* Source copy-to-camb.sh
* Go to COSMOMC directory and run domake.sh
* Run the Monte Carlo: ./cosmomc params_xray.ini

Comments
--------
* You can check the status of the fit while cosmomc is running by comparing spectrum.txt and rspec.txt (ie. gnuplot> plot 'spectrum.txt','rspec.txt').
* If the fit looks bad check the fit range in cosmomc/xigar.f90 (startoff and cutoff variables)!

Credits
-------
Thanks to all developers and contributors of/to COSMOMC, ROOT, HEASOFT, FORTRAN, TCL, GNUPLOT, TEXTMATE, TOWER, GITHUB and MAC OS X.
Thanks to Steen, Martina, Teddy and Signe (from http://dark.nbi.ku.dk) for providing encouragement, ideas and data.