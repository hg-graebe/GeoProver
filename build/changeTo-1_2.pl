# Purpose: Update files to GeoProver 1.2 syntax

# Usage: perl changeTo-1_2.pl <args>

# Warning: This is a very raw substitution only. The output should
# be postprocessed by hand.  Make a 'diff' with the (automatically
# created) backup file to evaluate the changes.

# Note that 'circle_slider' and 'pc_circle' have different syntax
# and take as second parameters now a point and not the radius of
# the circle.  This must be updated by hand.

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
  s/\bcc_tangent/is_cc_tangent/gs;
  s/\bcl_tangent/is_cl_tangent/gs;
  s/\bc1_circle/pc_circle/gs;
  s/\bcollinear/is_collinear/gs;
  s/\bconcurrent/is_concurrent/gs;
  s/\borthogonal/is_orthogonal/gs;
  s/\bp4_circle/is_p4_circle/gs;
  s/\bparallel/is_parallel/gs;
  s/\bperpendicular/ortho_line/gs;
  s/\bpoint_on_bisector/is_point_on_bisector/gs;
  s/\bpoint_on_circle/is_point_on_circle/gs;
  s/\bpoint_on_line/is_point_on_line/gs;
  s/\bchoose_pc/circle_slider/gs;
  s/\bchoose_pl/line_slider/gs;
  s/\bsymline/sym_line/gs;
  s/\bsympoint/sym_point/gs;
  s/\bp_sympoint/csym_point/gs;

  # s/\#[^\n]*\n//gs;
  # s/\n\s+/\n  /gs;
}

