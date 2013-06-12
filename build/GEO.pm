###################################################################
#
# FILE:    GEO.pm 
# AUTHOR:  graebe
# CREATED: 2/2000
# PURPOSE: functions to manage GEO records 
# VERSION: $Id: GEO.pm,v 1.1 2012/02/10 21:13:31 graebe Exp $

use lib (defined ($SD_HOME = $ENV{'SD_HOME'}) ? "$ENV{'SD_HOME'}/bin" : 
	 die "Environment variable SD_HOME not set");

use strict;

###################################################
package GEO;
#
#

use Record;
use TmpFile;
use Misc;
use Validate;

use GEO::TransCode;
use GEO::Preamble;

use vars qw($DESCRIPTION $FUNCTIONS);

my $GeoDir=$ENV{'GP_HOME'}; # root directory of the GeoProver distribution
 
######################################################
# description

$DESCRIPTION =
{ 
 verbose => 'Functions for GEO records',
 actions => ['CreateINTPS'],
 description => <<EOT,
Specific functions for management of GEO records.

<p>GEO records contain several tags with GeoCode values. This is
generic code which can be translated to valid input code for the CAS
for which the GeoProver package is implemented (currently Maple, MuPAD,
Mathematica, and Reduce).

<p>Such code distinguishes between symbols (the names defined in the
values of the tags <tt>vars</tt> and <tt>parameters</tt>) and
variables (the names for intermediate geometric objects). The latter
start with <tt>\$</tt> (as Perl variables do).  A special variable
<tt>\$result</tt> serves as value holder for symbolic expressions that
should coincide with those produces by the value of the (forthcoming)
<tt>GEO/result</tt> tag.

<p>As in Mathematica expressions are grouped with '()' brackets,
argument lists of functions are enclosed in '[]' brackets.

EOT
}; # end DESCRIPTION

######################################################
# Functions

$FUNCTIONS->{CreateCode} = 
{
 status => "local",
 signature => "(String,String) CreateCode(Record,CAS_Name,Array of tags)",
 description => <<EOT

<p>Create GeoProver code from a GEO record with equational proof type
to compute the underlying polynomials. 

<p>Returns two strings (preamble, code), where 'preamble' is the
initialization part (loading libraries etc.) and 'code' is the code
to run for that example. The preamble assumes the GeoProver package
installed at <tt>\$GP_HOME</tt>.

EOT
};
sub CreateCode
{
  my $r=shift;
  my $sys=shift;
  return Warn("$r->{Id} not a GEO record") unless $r->{Type} eq "GEO";
  return Warn("$sys invalid as CAS") 
    unless $sys=~/^Maple|MuPAD|Reduce|Mathematica$/; 
  my $tags=shift;
  my $preamble="Preamble::$sys";
  my $transcode="TransCode::$sys";
  my $comment="TransCode::$sys"."_Comment";

  no strict 'refs';
  my $s;
  if (defined $r->{'vars'})
  {
    my $vars=$r->{'vars'};
    $vars=~s/\[|\]//g;
    $s.=&$transcode("\$vars:=List[$vars];")."\n";
  }
  if (defined $r->{'parameters'})
  {
    my $parameters=$r->{'parameters'};
    $parameters=~s/\[|\]//g;
    $s.=&$transcode("\$parameters:=List[$parameters];")."\n";
  }
  map 
  { 
    $s.=&$comment($_)."\n".&$transcode($r->{$_})."\n" if $r->{$_}; 
  } (@$tags);
  return (&$preamble(),$s);
}

$FUNCTIONS->{CreatePolynomialCode} = 
{
 status => "local",
 signature => "(String,String) CreatePolynomialCode(Record,CAS_Name)",
 description => <<EOT

<p>Create Geo code from a GEO record with equational proof type
to compute the underlying polynomials. 

<p>Returns (preamble, code) as <sub>CreateCode</sub>.

EOT
};
sub CreatePolynomialCode
{
  my $r=shift;
  return Warn("$r->{Key} has no tag 'polynomials'") 
    unless defined $r->{'polynomials'};
  return CreateCode($r,shift,['Points','coordinates','polynomials']);
}

$FUNCTIONS->{CreateSolution} = 
{
 status => "local",
 signature => "(String,String) CreateSolution(Record,CAS_Name)",
 description => <<EOT

<p> Create GeoProver code from a GEO record to compute the
solution. If the prooftype is "constructive", then the conclusion
should simplify to 0.  If the prooftype is "equational", then a
solution tag should be present.  Both is <i>not</i> checked.

<p>Returns (preamble, code) as <sub>CreateCode</sub>.

EOT
};
sub CreateSolution
{
  return CreateCode(@_,['Points','coordinates', 'polynomials', 'constraints', 
			'conclusion', 'solution']);
}

$FUNCTIONS->{CreateINTPS} = 
{
 status => "local",
 signature => "Record CreateINTPS(Record)",
 description => <<EOT
Returns an INTPS record with the primitive parts of the polynomials
generated from the <tt>polynomial</tt> tag value of the GEO record if
such a tag exists. Used as action in <tt>symbolicdata</tt>.

<p>Requires the MuPAD GeoProver package to be installed. For
details, see the GEO table description.

EOT
};
sub CreateINTPS
{
  my $r=shift;
  return Warn("$GeoDir: MuPAD code not installed but required") 
    unless -e "$GeoDir/MuPAD";

  # create the polynomials using MuPAD
  my @l=CreatePolynomialCode($r,'MuPAD');
  return undef unless @l;
  my $s=$l[0].$l[1];
  my $tmp=TmpFile::GetTmpFileName();
  {
    # assumes GeoCode variables $polys, $vars to be used.
    no strict 'refs';
    my $transcode="TransCode::MuPAD";
    my $polys=&$transcode("\$polys");
    $s.=&$transcode(<<EOT
\$polys:=map(\$polys,numer);
\$polys:=map(\$polys,polylib::primpart,\$vars);
write(Text,"$tmp",\$polys);
quit;
EOT
);
  }
  open(FH,"| mupad >/dev/null") or return Warn("Can't start MuPAD:$!");
  print FH $s;
  close(FH);

  # compose the output
  my $t; 
  my $u=$r->{'Key'};
  $u=~s/\//_/g;
  $t->{'Id'}="INTPS/Geometry/$u";
  $t->{'Key'}="Geometry/$u";
  $t->{'Type'}="INTPS";
  $t->{'Crossref'}="GEO/$r->{'Key'}";
  map $t->{$_}=$r->{$_}, ('vars','parameters');

  # get the polynomials
  { 
    open(FH,"<$tmp") or return Warn("Can't open tmp file $tmp:$!");
    local $/; $_=<FH>; m|\[(.*)\]|s; $s=$1; $s=~s/[\\\s]//gs; 
    close(FH);
  }
  # print "$s\n";
  $t->{'basis'}=join(",\n",split(/\s*,\s*/,$s));
  $t=Record->new($t);
  #$t->Out("-");
  local $main::opt->{'fix'}=1;
  local $main::opt->{'confirm'}=0;
  return undef unless ValidateRecord($t,3);
  $t->DeleteChangeLog();
  $t->AddChangeLogEntry("created by GEO::CreateINTPS");
  $t->{'_changed'}=0;
  return $t;
}

sub InitEx 
{ 
  # Initialize GeoProver computation: write input to the file
  # $comp->{stdin}.
  my $comp=shift; 
  my @l=CreateSolution($comp->{Ex}, $comp->{CASCONFIG}->{CAS});
  return (1,"") unless @l;
  my $s=$l[0].$l[1];
  open(FH,">$comp->{stdin}") or 
    return Error("Cant open $comp->{stdin} for writing: $!");
  print FH $s;
  close FH;
  return(0,"");

}


1; # Should be the last line


