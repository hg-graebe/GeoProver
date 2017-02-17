###################################################################
#
# FILE:    TransCode.pm 
# AUTHOR:  graebe
# CREATED: 2/2000
# PURPOSE: translate GeoCode to different target CAS
# VERSION: 2012/02/10 

use strict;

package TransCode;

sub Reduce_Comment { local $_=shift; s.(^|\n).$1% .gs; return $_; }
sub Maple_Comment { local $_=shift; s.(^|\n).$1\# .gs; return $_; }
sub MuPAD_Comment { local $_=shift; s.(^|\n).$1// .gs; return $_; }
sub Mathematica_Comment { return "(* ".shift()." *)"; }
sub Maxima_Comment { return "/* ".shift()." */"; }

sub Reduce 
{ 
  my $s=shift; 
  $s=~tr/\[\]/\(\)/;
  $s=~s/\$(\w+)/uhu($1)/eg; # special
  return $s; 
}

sub uhu
{ # mark capital letters to avoid name clashes
  local $_=shift;
  s/([A-Z])/$1_/g;
  return $_."_";
}

sub Maxima
{ 
  my $s=shift; 
  $s=~tr/\[\]/\(\)/;
  $s=~s/\$(\w+)/$1\_/g; 
  return $s; 
}

sub Maple 
{ 
  my $s=shift; 
  $s=~tr/\[\]/\(\)/;
  $s=~s/\$(\w+)/$1\_/g; 
  return $s; 
}

sub MuPAD 
{
  my $s=shift;
  $s=~s/List\[/geoList\[/gs; # since List is now a key word 
  $s=~tr/\[\]/\(\)/;
  $s=~s/\$(\w+)/_$1/gs; 
  return $s;
}

sub Mathematica 
{
  my $s=shift;
  $s=~s/_//gs;
  $s=~s/Point/point/gs;
  #$s=~s/:=/=/gs;
  #$s=~s/;\s*/\n/gs;
  return $s;
}

1;

