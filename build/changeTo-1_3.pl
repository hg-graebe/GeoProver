# Purpose: Update files to GeoProver 1.3 syntax

# Usage: perl changeTo-1_3.pl <args>

# Warning: This is a very raw substitution only. The output should
# be postprocessed by hand.  Make a 'diff' with the (automatically
# created) backup file to evaluate the changes.

# Note that 'varpoint' has changed semantically (u -> 1-u) and is
# not covered with that file.

map processfile($_), @ARGV;

sub processfile {
  my $fn=shift;
  system("cp $fn $fn.bak");
  open(FH,$fn) or die;
  local $/;
  $_=<FH>;
  close(FH);
  changes();
  open(FH,">$fn") or die;
  print FH $_;
  close(FH);
}

sub changes 
{
  s/\bis_p4_circle/is_concyclic/gs;
  s/\beqdist\b/eq_dist/gs;
  s/\bis_point_on_/on_/gs;
  s/\bmidpoint_perpendicular/p_bisector/gs;

  # s/\#[^\n]*\n//gs;
  # s/\n\s+/\n  /gs;
}

