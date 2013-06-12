# GeoProver Package 
# Author: Hans-Gert Graebe, Univ. Leipzig, Germany
# email: graebe@informatik.uni-leipzig.de
# Web page: www.informatik.uni-leipzig.de/~compalg/software/
# Version: $Id: Preamble.pm,v 1.1 2012/02/10 21:13:31 graebe Exp $

use strict;

package Preamble;

my $geo="$ENV{'GP_HOME'}"; # location of the Geo software
my $supp="$ENV{'SD_HOME'}/bin/GEO"; # location of the supp files

sub Maple 
{
  return <<EOT;
read("$geo/Maple/GeoProver.mpl"):
read("$supp/supp.mpl"):
with(geoprover):
interface(prettyprint=0):
EOT
}
   
sub Mathematica
{
  return <<EOT;
Needs["GeoProver`","$geo/Mathematica/GeoProver.m"];
<<"$supp/supp.m";
Off[General::spell1];
\$HistoryLength=0;
EOT
}
   
sub MuPAD # works for version 2.0 and later 
{
  return <<EOT;
LIBPATH:=LIBPATH, "$geo/MuPAD":
loadlib("GeoProver"): 
export(groebner): export(geoprover):
read("$supp/supp.mu"):
PRETTYPRINT:=FALSE:
EOT
}
   
sub Reduce 
{
  return <<EOT;
load cali,geoprover;
off nat;
in "$supp/supp.red"\$
EOT
}
   
1;
