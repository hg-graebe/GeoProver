# usage: perl build.pl action @ARGS
# action is one of buildCode buildTests buildHelp buildReadme

use TransCode;
use Preamble;
use XML::DOM;

## == initialization

my $parser=new XML::DOM::Parser;

my $SD_HOME="/home/graebe/git/SD/symbolicdata/data";
my $GeoProverHome="/home/graebe/git/Software/GeoProver/src"; 
my $GeoTestHome="/home/graebe/git/SD/data/XMLResources/GeoProofSchemes"; 
my $GeoCodeTable=getGeoCode("GeoCode.rdf");

# print showGeoCodeTable($GeoCodeTable); # for testing

my @examples=("Arnon", "CircumCenter_1", "EulerLine_1",
	      "Brocard_3", "Feuerbach_1", "FeuerbachTangency_1",
	      "GeneralizedFermatPoint_1", "TaylorCircle_1",
	      "Miquel_1", "PappusPoint_1", "IMO.36_1", "IMO.43_2");

my $Date="2007-02-09"; # Misc::GetDate();

my $Version = <<EOT;
GeoProver | Version 1.3a | $Date
Author: H.-G. Graebe, Univ. Leipzig, Germany
http://www.informatik.uni-leipzig.de/~graebe
EOT

## == end initialization

my $act=shift; eval &$act(); 
## == end main

use strict;

# ======== some global variables ==================

my (@interface, @code, $inlinecode);

# @interface contains for the default function definitions the code interface
# definitions for the given CAS (if any), @code the code itself.  $inlinecode
# is the CAS dependent inline code.

# ======== The actions part ===============

sub buildCode {
  for my $sysname (@ARGV)
  {
    my $sys=getPlatform($sysname);
    die "$sysname invalid as target\n" unless $sys;
    my $out;
    @interface=(); @code=();
    { no strict 'refs';
      # Add package infor as comment
      $out=join("\n", map &{"TransCode::$sysname"."_Comment"}(" $_"), 
		split(/\n/, $Version));
      $out.="\n\n";
      # Initialize the global arrays @interface and @code
      map &{"codeprepare$sysname"}($GeoCodeTable->{$_}), 
	(sort keys %$GeoCodeTable);
      # Get the inline code
      $inlinecode=readFile($sys->{inline});
      # create the package for the given CAS
      $out.=&{"codecreate$sysname"}();
    }
    # write the result to the target file.
    createFile($out,$sys->{target});
  }
}

sub buildHelp {
   my $help;
   for my $a (keys %$GeoCodeTable)
   {
     $help->{$a}=preparehelp($GeoCodeTable->{$a});
   }
   for my $sysname (@ARGV)
   {
     my $sys=getPlatform($sysname);
     die "$sysname invalid as target\n" unless $sys;
     no strict 'refs'; 
     &{"createhelp$sysname"}($help);
   }
}

sub buildReadme {
  my $r=readHelp();
  my $s=<<EOT;
<html>
<head>
<title>GeoProver version $r->{version}</title>
</head>
<body>
<h1 align="center">$r->{title} <p> Version $r->{version}</h1>

<p> Freezed at $r->{date}

<h3 align="center">
<table>
<tr><td> AUTHOR   <td>: <td>$r->{author}
<tr><td> ADDRESS  <td>: <td>$r->{address}
<tr><td> URL    <td>: <td><url>$r->{url}</url>
<tr><td> EMAIL    <td>: <td>$r->{email}
</table>
</h3>

<h4>Key Words</h4>

$r->{keywords}

<h4>Introduction</h4>

$r->{Introduction}

<h4>Bibliography</h4>

$r->{Bibliography}

<h4>Acknowledgements</h4>

$r->{Acknowledgements}

</body>
</html>
EOT

  $s=~s|<url>(.*?)</url>|<a href=\"$1\">$1</a>|gs;
   
   createFile($s,"Readme.html");
}

sub buildTests {   
  for my $sysname (@ARGV)
  {
    my $sys=getPlatform($sysname);
    die "$sysname invalid as target\n" unless $sys;
    my @u=(@examples);
    no strict 'refs'; 
    my $out=&{"TransCode::".$sysname."_Comment"}
      ("GeoProver test file for $sysname, created on $Date")."\n";
    $out.=$sys->{Preamble}."\n";
    map {$out.=createTest($_,$sysname); } (@u);
    if ($sysname eq "Mathematica")
    {
      $out=~s/:=/=/gs;
      $out=~s/;\s*/\n/gs;
    }
    $out.=$sys->{QuitCommand}."\n";
    createFile($out,"$sysname/New.tst");
   }
}

##################################################
#
# GeoProver stuff for different platforms.

sub getPlatform {
  my $sys=shift;
  my $platforms=
  {
 'Reduce' =>  
 { 
  target => "Reduce/GeoProver.red",
  inline => "Inline/reduce.inline",
  help   => "Reduce/GeoProver.html",
  QuitCommand => "showtime;\nquit;\n",
  Preamble => <<EOT,
load cali,geoprover;
off nat; on echo;
in "supp.red"\$
EOT
 },

 'Maple' => 
 { 
  target => "Maple/GeoProver.mpl",
  inline => "Inline/maple.inline",
  help   => "Maple/GeoProver.mhp",
  QuitCommand => "quit;\n",
  Preamble => <<EOT,
read("GeoProver.mpl"):
read("supp.mpl"):
with(geoprover):
interface(prettyprint=0):
EOT
 },

 'MuPAD' => 
 { 
  target => "MuPAD/GeoProver.mu",
  inline => "Inline/mupad.inline",
  help   => "MuPAD/GeoProver.html",
  QuitCommand => "quit;\n",
  Preamble => <<EOT,
read("GeoProver.mu"): 
export(groebner): export(geoprover):
read("supp.mu"):
PRETTYPRINT:=FALSE:
EOT
 },

 'Mathematica' => 
 { 
  target => "Mathematica/GeoProver.m",
  inline => "Inline/mathematica.inline",
  QuitCommand => "Quit[]\n",
  Preamble => <<EOT,
Needs["GeoProver`","GeoProver.m"];
<<"supp.m";
Off[General::spell1];
\$PrePrint=InputForm;
EOT
 },
  };
  return $platforms->{$sys};
}

##################################################
#
# Build GeoProver and Help for different platforms.

# --------- Maple --------------

sub codeprepareMaple
{
  my $r=shift;
  my $call=$r->{call};
  $call=~/^(.*)\[/;
  my $name=$1; 
  $call=TransCode::Maple($');
  $call=~s|\)::\w*|\)|gs;
  push(@interface, "geoprover[$name]:=proc() `geoprover/$name`(args) end:");
  return unless $r->{code};
  my $code=$r->{code};
  $code=~s|(\w*)\[|`geoprover/$1`(|gs; # )]
  push(@code, "`geoprover/$name`:=proc($call\n\t"
       .TransCode::Maple($code)." end:");
}

sub codecreateMaple
{
  my $out="# GeoProver interface\n\n";
  map push(@interface, "geoprover[$_]:=proc() `geoprover/$_`(args) end:"), 
    ('clear_ndg', 'print_ndg', 'add_ndg', 'geo_plot');
  $out.=join("\n",@interface);
  $out.="\n\n";
  $out.=$inlinecode;
  $out.="\n# GeoProver code generated from database \n\n";
  $out.=join("\n",@code);
  $out.="\n# GeoProver code end.\n";
  return $out;
}

sub createhelpMaple
{
  my $help=shift;
  my ($a,$r,$s,$name);
  my @l=map TransCode::Maple($_), (sort keys %$help);
  my $i=0;
  map { 
    $s.=sprintf("\n%10s") unless $i++%3; $s.=sprintf("%-23s",$_); 
  } @l;
  my $inlinehelp=readHelp();

  my $out=<<EOT;
<PACKAGE="GeoProver">
<HELP NAME="GeoProver">
 $inlinehelp->{title} 

 Version $inlinehelp->{version} 

 AUTHOR   : $inlinehelp->{author}
 ADDRESS  : $inlinehelp->{address}
 URL      : $inlinehelp->{url}

 SYNTAX : geoprover[<function>] (args);   or   <function> (args);

 SYNOPSIS :

 - To use functions from the package "GeoProver", type "with(geoprover);"

 - For help with a particular function do:  help(geoprover, <function>);

 - For examples see the files GeoProver.mws or GeoProver.tst

 SHORT DESCRIPTION: 

$inlinehelp->{Introduction}

$inlinehelp->{BasicDataTypes}

 - The following functions on these data types are available: 
$s

 ACKNOWLEDGEMENTS:

$inlinehelp->{Acknowledgements}

</HELP>
EOT
  
  for $a (@l) #(sort keys %$help)
  {
    # print "help processing $a\n";
    $r=$help->{$a};
    $name=TransCode::Maple($r->{topic});
    $s=$r->{parameters2};
    $out.= <<EOT;
<HELP name="$a">
Topic: $name - $r->{verbose}

Calling Sequence: $a($s)

Parameters: $r->{parameters1}

Description: $r->{description}

Examples: See GeoProver.mws and GeoProver.tst

See also: GeoProver
</HELP>
EOT
  }
  createFile($out,getPlatform("Maple")->{help})
}

# --------- Reduce --------------

sub codeprepareReduce
{
  my $r=shift; 
  return unless $r->{code}; 
  my $c="algebraic procedure ".$r->{call}.";\n\t".$r->{code}.";\n";
  $c=~s/::\w*//gs;
  push(@code, TransCode::Reduce($c));
}

sub codecreateReduce
{
  my $out="module geoprover; \n\n";
  $out.=$inlinecode;
  $out.="\n% GeoProver code generated from database \n\n";
  $out.=join("\n",@code);
  $out.="\nendmodule; % GeoProver \n\nend;\n\n";
  return $out;
}

sub createhelpReduce
{
  my $help=shift;
  my ($a,$r,$s,$name);
  my $inlinehelp=readHelp();
  my $out=<<EOT;
<html>
<head>
<title>GeoProver v. $inlinehelp->{version}</title>
</head>
<body>
<h1 align="center">$inlinehelp->{title} 
<p> Version $inlinehelp->{version}</h1>

 <h3 align="center">
<table>
<tr><td>AUTHOR   <td>: <td>$inlinehelp->{author}
<tr><td> ADDRESS  <td>: <td>$inlinehelp->{address}
<tr><td> URL    <td>: 
<td> <a href="$inlinehelp->{url}">$inlinehelp->{url}</a> 
</table>
</h3>

<h4>Introduction</h4>

$inlinehelp->{Introduction}

<h4>Basic Data Types</h4>

$inlinehelp->{BasicDataTypes}

<h4>Available functions</h4>

<p><table border align="center" cellpadding=8 width="80%">
EOT
  
  for $a (sort keys %$help)
  {
    $r=$help->{$a};
    $name=TransCode::Reduce($a);
    $s=$r->{parameters3};
    $out.= <<EOT;
<tr><td align="center"> $name($s) <td> $r->{description}
EOT
  }
  $out.= <<EOT;
</table>

<h4>Acknowledgements</h4>

$inlinehelp->{Acknowledgements}

</body>
</html>
EOT
  createFile($out,getPlatform("Reduce")->{help})
}

# --------- MuPAD --------------

sub codeprepareMuPAD
{
  my $r=shift;
  my $call=$r->{call};
  $call=~/^(.*)\[/;
  my $name=$1; 
  $call=TransCode::MuPAD($');
  $call=~s|::Point|:geoprover::DOM_POINT|gs;
  $call=~s|::Line|:geoprover::DOM_LINE|gs;
  $call=~s|::Circle|:geoprover::DOM_CIRCLE|gs;
  $call=~s|::Angle||gs;
  $call=~s|::Distance||gs;
  $call=~s|::Scalar||gs;
  $call=~s|::Boolean||gs;
  push(@interface, "hold($name)");
  return unless $r->{code};
  my $code=$r->{code};
  $code=~s|(\w*)\[|geoprover::$1\(|gs;
  push(@code, "geoprover::$name:=\nproc($call\nbegin\n"
       .TransCode::MuPAD($code)."\nend_proc:");
}

sub codecreateMuPAD
{
  my $out="// GeoProver interface \n\n";
  map push(@interface, "hold($_)"), 
    ('clear_ndg', 'print_ndg', 'add_ndg', 'geo_plot');
$out.=<<EOT;
geoprover:=newDomain("geoprover"):
geoprover::info:="The package GeoProver is a small package for mechanized\\
 \\n(plane) geometry manipulations with non-degeneracy tracing. \\n":

EOT
  $out.="geoprover::interface:={\n".join(",\n",@interface)."}:\n";
  $out.="\n\n";
  $out.=$inlinecode;
  $out.="\n// GeoProver code generated from database \n\n";
  $out.=join("\n\n",@code);
  $out.="\n\n// GeoProver code end.\n";
  return $out;
}

sub createhelpMuPAD
{
  my $help=shift;
  my ($a,$r,$s,$name);
  my $inlinehelp=readHelp();
  my $out=<<EOT;
<html>
<head>
<title>GeoProver v. $inlinehelp->{version}</title>
</head>
<body>
<h1 align="center">$inlinehelp->{title} 
<p> Version $inlinehelp->{version}</h1>

<h3 align="center">
<table>
<tr><td>AUTHOR   <td>: <td>$inlinehelp->{author}
<tr><td> ADDRESS  <td>: <td>$inlinehelp->{address}
<tr><td> URL    <td>: 
<td> <a href="$inlinehelp->{url}">$inlinehelp->{url}</a> 
</table>
</h3>

<h4>Introduction</h4>

$inlinehelp->{Introduction}

<h4>Basic Data Types</h4>

$inlinehelp->{BasicDataTypes}

<h4>Available functions</h4>

<p><table border align="center" cellpadding=8 width="80%">
EOT
  
  for $a (sort keys %$help)
  {
    $r=$help->{$a};
    $name=TransCode::MuPAD($a);
    $s=$r->{parameters3};
    $out.= <<EOT;
<tr><td align="center"> $name($s) <td> $r->{description}
EOT
  }
  $out.= <<EOT;
</table>

<h4>Acknowledgements</h4>

$inlinehelp->{Acknowledgements}

</body>
</html>
EOT
  createFile($out,getPlatform("MuPAD")->{help})
}

# --------- Mathematica --------------

sub codeprepareMathematica
{
  my $r=shift;
  my $name=TransCode::Mathematica($r->{Key});
  # print "Name is $name\n";
  push(@interface, $name."::usage:=\"$r->{verbose}\";");
  return unless $r->{code};
  my $call=$r->{call};
  $call=~s/\]::\w*/\]/gs;
  $call=TransCode::Mathematica($call);
  $call=~s/::Scalar/_/gs;
  $call=~s/::point/_GPPoint/gs;
  $call=~s/::/_GP/gs;
  my $code=$r->{code};
  push(@code, "$call:=\n  ".TransCode::Mathematica($code).";");
}

sub codecreateMathematica
{
  my $out="BeginPackage[\"GeoProver`\"]\n\n"
    ."(* GeoProver usage *)\n\n";
  map push(@interface, $_."::usage:=\"degeneracy tracing\";"), 
    ('clearndg', 'printndg', 'addndg');
  $out.=join("\n",@interface);
  $out.="\n\n";
  $out.=$inlinecode;
  $out.="\n(* GeoProver code generated from database *)\n\n";
  $out.=join("\n\n",@code);
  $out.="\n\nEnd[] (* Private *)\nEndPackage[]\n";
  return $out;
}

sub createhelpMathematica
{
  return; # since help is integrated in the package code.
}

##################################################
#
# Extract Help from the sources.

sub preparehelp
{
  my $r=shift;
  my (@u1,@u2,@u3,$cs,$s);
  # print "processing $r->{Key}\n";
  ($cs=$r->{call})=~s/(\w+)::(\w*)/
    push(@u1,"$1 - $2");push(@u2,$1);push(@u3,"$1:$2");/egs;
  $s->{'topic'}=$r->{Key};
  $s->{'verbose'}=$r->{verbose};
  $s->{'parameters1'}=join(", ",@u1);
  $s->{'parameters2'}=join(", ",@u2);
  $s->{'parameters3'}=join(", ",@u3);
  $s->{'description'}=$r->{description};
  return $s;
}

##################################################
#
# Create the test suites

sub createTest
{
  my ($id,$sysname)=@_; 
  my $r=readXML("$GeoTestHome/$id.xml");
  # print "processing .$r->{Key}.\n";
  # verbal description to be added
  # my $c=$r->Hash("CRef"); my @l=(keys %$c);
  # $c=(@l ? Record->new($ENV{"SD_HOME"}."/Data/$l[0].sd")->{problem} 
  #    : "\nNo verbal problem description available");
  my $s; 
  { no strict 'refs';
    $s=&{"TransCode::".$sysname."_Comment"}
      ("Example $r->{Key}"
       #."\n\nThe problem:\n$c\n\n"
       ."\n\nThe solution:")."\n\n";
  }
  $s.=CreateSolution($r,$sysname);
  return $s."\n\n";
}

##################################################
#
# some auxiliary procedures

sub readXML {
  my $fn=shift;
  # print "Reading $fn\n";
  my $doc=$parser->parsefile($fn) or die;
  my $root=$doc->getDocumentElement;
  my $r;
  my $id=$root->getAttribute("id");
  my ($a,$key)=split(/\//,$id,2);
  $r->{Key}=$key;
  map {
    $r->{$_->getNodeName}=getTextContent($_);
  } $root->getElementsByTagName("*");
  return $r;
}

sub getTextContent {
  my $node=shift;
  local $_=$node->toString(1);
  # strip off tags
  s/<[^>]*>\s*//g;
  s/\s*<\/[^>]*>//g;
  return $_;
}

sub readHelp {
  my $doc=$parser->parsefile("$GeoProverHome/Inline/help.xml");
  my $r;
  map {
    my $s=$_->toString(1);
    $s=~s/^\s*<[^>]*>//s; $s=~s/<\/[^>]*>\s*$//s;
    $r->{$_->getName}=$s;
  } $doc->getDocumentElement->getChildNodes;
  return $r;
}

sub readFile 
{
  my $fn=shift;
  $fn="$GeoProverHome/$fn";
  open(FH,$fn) or die "Can't read file $fn: $!\n";
  local $/=undef;
  $_=<FH>;
  close(FH);
  return $_;
}

sub createFile
{
  my ($s,$fn)=@_;
  $fn="$GeoProverHome/$fn";
  if (-e $fn)
  {
    print "Making backup of $fn to $fn.bak\n";
    system("cp $fn $fn.bak");
  }
  open(FH,">$fn") or die "Can't open $fn for writing: $!\n";
  print FH $s;
  close(FH);
  print "Output written to file $fn\n";
}

# from GEO/GEO.pm, to be fixed there

sub CreateSolution
{ 
  return CreateCode(@_,['Points','coordinates', 'polynomials', 'constraints',
                        'conclusion', 'solution']);
}

sub CreateCode
{
  my $r=shift;
  my $sys=shift;
  my $tags=shift;
  my $preamble="Preamble::$sys";
  my $transcode="TransCode::$sys";
  my $comment="TransCode::$sys"."_Comment";

  no strict 'refs';
  my $s;
  if (defined $r->{'vars'})
  {
    my $vars=join(",", split(/\s+/,$r->{'vars'}));
    $s.=&$transcode("\$vars:=List[$vars];")."\n";
  }
  if (defined $r->{'parameters'})
  {
    my $parameters=join(",", split(/\s+/,$r->{'parameters'}));
    $s.=&$transcode("\$parameters:=List[$parameters];")."\n";
  }
  map
  {
    $s.=&$comment($_)."\n".&$transcode($r->{$_})."\n" if $r->{$_};
  } (@$tags);
  return (&$preamble(),$s);
}

sub getGeoCode {
  my $doc=$parser->parsefile(shift) or die;
  my $h;
  map {
    my $s=$_->toString();
    $s=~s|<rdfs:label>([^<]*)</rdfs:label>||s;
    my $name=$1; 
    $s=~s|<sd:call>([^<]*)</sd:call>||s;
    my $call=$1; 
    if ($s=~s|<sd:defaultDefinition>([^<]*)</sd:defaultDefinition>||s) {
      my $default=$1;
      $h->{$name}{"call"}=$call; 
      $h->{$name}{"code"}=$default;
    }
  } $doc->getElementsByTagName("sd:GeoCodeFunction");
  return $h;
}

sub showGeoCodeTable { # for testing purposes
  my $h=shift;
  my $out;
  map {
    $out.=<<EOT;
  Name: $_
  Call: $h->{$_}{"call"}
  Code: $h->{$_}{"default"}

EOT
  } (sort keys %$h); 
  return $out;
}

1;
