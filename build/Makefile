###################################################################
#
# FILE:    Makefile
# AUTHOR:  graebe
# PURPOSE: Makefile for GeoProver
# VERSION: $Id: Makefile,v 1.1 2012/02/10 21:13:31 graebe Exp $

########################
# collections 
#

All := Maple Mathematica MuPAD Reduce

Maple := $(patsubst %, GeoProver.%, mpl mws tst out mhp) README supp.mpl
Mathematica := $(patsubst %, GeoProver.%, m tst out nb) README supp.m
MuPAD := $(patsubst %, GeoProver.%, tst out html)	\
	GeoProver.mu README plottest.mu supp.mu
Reduce := $(patsubst %, GeoProver.%, red tst out html) README supp.red

#############################################
#
# targets 
#

build:
	perl build.pl buildCode ${All} 

buildhelp:	
	perl build.pl buildHelp ${All}

buildtests:	
	perl build.pl buildTests ${All}

buildreadme:	
	perl build.pl buildReadme

dist: 
	tar -cvzf GeoProver-Maple.tgz			\
		$(patsubst %, Maple/%, ${Maple})		
	tar -cvzf GeoProver-Mathematica.tgz		\
		$(patsubst %, Mathematica/%, ${Mathematica})	
	tar -cvzf GeoProver-MuPAD.tgz			\
		$(patsubst %, MuPAD/%, ${MuPAD})	
	tar -cvzf GeoProver-Reduce.tgz			\
		$(patsubst %, Reduce/%, ${Reduce})	

clean:
	find . -name "*.bak" -exec rm -f {} \;
	find . -name "*~" -exec rm -f {} \;
