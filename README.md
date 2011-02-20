X-igar v0.1 x 10^-23
====================

Minimum requirements
--------------------

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