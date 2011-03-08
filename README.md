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

Edit settings.sh and settings.tcl to point to the correct directories.

Usage
-----

Generating fake data to use in MCMC:
* Source xspecpro/xspecpro.sh

* Run xigar.sh
* Run copy-to-camb.sh
* Go to COSMOMC directory and run domake.sh
* Do ./cosmomc params_xray.ini

Comments
--------
* You can check the status of the fit while cosmomc is running by comparing spectrum.txt and rspec.txt (ie. gnuplot> plot 'spectrum.txt','rspec.txt').
* If the fit looks bad check the fit range in cosmomc/xigar.f90 (startoff and cutoff variables)!

Credits
-------
Thanks to all developers and contributors of/to COSMOMC, ROOT, HEASOFT, FORTRAN, TCL, GNUPLOT, TEXTMATE, TOWER, GITHUB and MAC OS X.
Thanks to Steen, Martina, Teddy and Signe (from http://dark.nbi.ku.dk) for providing encouragement, ideas and data.