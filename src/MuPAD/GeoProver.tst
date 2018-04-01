// GeoProver test file for MuPAD, created on Jan 18 2003
read("GeoProver.mu"): 
export(groebner): export(geoprover):
read("supp.mu"):
PRETTYPRINT:=FALSE:

// Example Arnon
// 
// The problem:
// Let $ABCD$ be a square and $P$ a point on the line parallel to $BD$
// through $C$ such that $l(BD)=l(BP)$, where $l(BD)$ denotes the
// distance between $B$ and $D$. Let $Q$ be the intersection point of
// $BF$ and $CD$. Show that $l(DP)=l(DQ)$.
// 
// The solution:

_vars:=geoList(x1, x2, x3);
// Points
_A:=Point(0,0); _B:=Point(1,0); 
_C:=Point(1,1); _D:=Point(0,1); 
_P:=Point(x1,x2);
// coordinates 
_Q:=varpoint(_D,_C,x3);
// polynomials
_polys:=geoList(on_line(_P,par_line(_C,pp_line(_B,_D))),
  eq_dist(_B,_D,_B,_P), on_line(_Q,pp_line(_B,_P)));
// conclusion
_con:=eq_dist(_D,_P,_D,_Q);
// solution
_gb:=geo_gbasis(_polys,_vars);
_result:=geo_normalf(_con,_gb,_vars);


// Example CircumCenter_1
// 
// The problem:
// The intersection point of the midpoint perpendiculars is the
// center of the circumscribed circle.
// 
// The solution:

_parameters:=geoList(a1, a2, b1, b2, c1, c2);
// Points
_A:=Point(a1,a2);
_B:=Point(b1,b2);
_C:=Point(c1,c2);
// coordinates
_M:=intersection_point(p_bisector(_A,_B),
  p_bisector(_B,_C));
// conclusion
_result:=geoList( eq_dist(_M,_A,_M,_B), eq_dist(_M,_A,_M,_C) );


// Example EulerLine_1
// 
// The problem:
// Euler's line: The center $M$ of the circumscribed circle,
// the orthocenter $H$ and the barycenter $S$ are collinear and $S$
// divides $MH$ with ratio 1:2.
// 
// The solution:

_parameters:=geoList(a1, a2, b1, b2, c1, c2);
// Points
_A:=Point(a1,a2);
_B:=Point(b1,b2);
_C:=Point(c1,c2);
// coordinates
_S:=intersection_point(median(_A,_B,_C),median(_B,_C,_A));
_M:=intersection_point(p_bisector(_A,_B),
  p_bisector(_B,_C));
_H:=intersection_point(altitude(_A,_B,_C),altitude(_B,_C,_A));
// conclusion
_result:=geoList(is_collinear(_M,_H,_S), sqrdist(_S,fixedpoint(_M,_H,1/3)));


// Example Brocard_3
// 
// The problem:
// Theorem about the Brocard points:
// Let $\Delta\,ABC$ be a triangle. The circles $c_1$ through $A,B$ and
// tangent to $g(AC)$, $c_2$ through $B,C$ and tangent to $g(AB)$, and
// $c_3$ through $A,C$ and tangent to $g(BC)$ pass through a common
// point.
// 
// The solution:

_parameters:=geoList(u1, u2);
// Points
_A:=Point(0,0);
_B:=Point(1,0);
_C:=Point(u1,u2);
// coordinates
_M1:=intersection_point(altitude(_A,_A,_C),p_bisector(_A,_B));
_M2:=intersection_point(altitude(_B,_B,_A),p_bisector(_B,_C));
_M3:=intersection_point(altitude(_C,_C,_B),p_bisector(_A,_C));
_c1:=pc_circle(_M1,_A);
_c2:=pc_circle(_M2,_B);
_c3:=pc_circle(_M3,_C);
_P:=other_cc_point(_B,_c1,_c2);
// conclusion
_result:= on_circle(_P,_c3);


// Example Feuerbach_1
// 
// The problem:
// Feuerbach's circle or nine-point circle: The midpoint $N$ of $MH$ is
// the center of a circle that passes through nine special points, the
// three pedal points of the altitudes, the midpoints of the sides of the
// triangle and the midpoints of the upper parts of the three altitudes.
// 
// The solution:

_parameters:=geoList(u1, u2, u3);
// Points
_A:=Point(0,0);
_B:=Point(u1,0);
_C:=Point(u2,u3);
// coordinates
_H:=intersection_point(altitude(_A,_B,_C),altitude(_B,_C,_A));
_D:=intersection_point(pp_line(_A,_B),pp_line(_H,_C));
_M:=intersection_point(p_bisector(_A,_B),
  p_bisector(_B,_C));
_N:=midpoint(_M,_H);
// conclusion
_result:=geoList( eq_dist(_N,midpoint(_A,_B),_N,midpoint(_B,_C)),
  eq_dist(_N,midpoint(_A,_B),_N,midpoint(_H,_C)),
  eq_dist(_N,midpoint(_A,_B),_N,_D) );


// Example FeuerbachTangency_1
// 
// The problem:
// For an arbitrary triangle $\Delta\,ABC$ Feuerbach's circle (nine-point
// circle) is tangent to its 4 tangent circles.
// 
// The solution:

_vars:=geoList(x1, x2);
_parameters:=geoList(u1, u2);
// Points
_A:=Point(0,0);
_B:=Point(2,0);
_C:=Point(u1,u2);
_P:=Point(x1,x2);
// coordinates
_M:=intersection_point(p_bisector(_A,_B), p_bisector(_B,_C));
_H:=intersection_point(altitude(_A,_B,_C),altitude(_B,_C,_A));
_N:=midpoint(_M,_H);
_c1:=pc_circle(_N,midpoint(_A,_B));
_Q:=pedalpoint(_P,pp_line(_A,_B));
// polynomials
_polys:=geoList(on_bisector(_P,_A,_B,_C), on_bisector(_P,_B,_C,_A));
// conclusion
_con:=is_cc_tangent(pc_circle(_P,_Q),_c1);
// solution
_gb:=geo_gbasis(_polys,_vars);
_result:=geo_normalf(_con,_gb,_vars);


// Example GeneralizedFermatPoint_1
// 
// The problem:
// A generalized theorem about Napoleon triangles:
// Let $\Delta\,ABC$ be an arbitrary triangle and $P,Q$ and $R$ the third
// vertex of isosceles triangles with equal base angles erected
// externally on the sides $BC, AC$ and $AB$ of the triangle. Then the
// lines $g(AP), g(BQ)$ and $g(CR)$ pass through a common point.
// 
// The solution:

_vars:=geoList(x1, x2, x3, x4, x5);
_parameters:=geoList(u1, u2, u3);
// Points
_A:=Point(0,0);
_B:=Point(2,0);
_C:=Point(u1,u2);
_P:=Point(x1,x2);
_Q:=Point(x3,x4);
_R:=Point(x5,u3);
// polynomials
_polys:=geoList(eq_dist(_P,_B,_P,_C), 
  eq_dist(_Q,_A,_Q,_C),  
  eq_dist(_R,_A,_R,_B), 
  eq_angle(_R,_A,_B,_P,_B,_C), 
  eq_angle(_Q,_C,_A,_P,_B,_C));
// conclusion
_con:=is_concurrent(pp_line(_A,_P), pp_line(_B,_Q), pp_line(_C,_R));
// solution
_sol:=geo_solve(_polys,_vars);
_result:=geo_eval(_con,_sol);


// Example TaylorCircle_1
// 
// The problem:
// Let $\Delta\,ABC$ be an arbitrary triangle. Consider the three
// altitude pedal points and the pedal points of the perpendiculars from
// these points onto the the opposite sides of the triangle. Show that
// these 6 points are on a common circle, the {\em Taylor circle}.
// 
// The solution:

_parameters:=geoList(u1, u2, u3);
// Points
_A:=Point(u1,0);
_B:=Point(u2,0);
_C:=Point(0,u3);
// coordinates
_P:=pedalpoint(_A,pp_line(_B,_C));
_Q:=pedalpoint(_B,pp_line(_A,_C));
_R:=pedalpoint(_C,pp_line(_A,_B));
_P1:=pedalpoint(_P,pp_line(_A,_B));
_P2:=pedalpoint(_P,pp_line(_A,_C));
_Q1:=pedalpoint(_Q,pp_line(_A,_B));
_Q2:=pedalpoint(_Q,pp_line(_B,_C));
_R1:=pedalpoint(_R,pp_line(_A,_C));
_R2:=pedalpoint(_R,pp_line(_B,_C));
// conclusion
_result:=geoList( is_concyclic(_P1,_P2,_Q1,_Q2), 
  is_concyclic(_P1,_P2,_Q1,_R1),
  is_concyclic(_P1,_P2,_Q1,_R2));


// Example Miquel_1
// 
// The problem:
// Miquels theorem: Let $\Delta\,ABC$ be a triangle. Fix arbitrary points
// $P,Q,R$ on the sides $AB, BC, AC$. Then the three circles through each
// vertex and the chosen points on adjacent sides pass through a common
// point.
// 
// The solution:

_parameters:=geoList(c1, c2, u1, u2, u3);
// Points
_A:=Point(0,0);
_B:=Point(1,0);
_C:=Point(c1,c2);
// coordinates
_P:=varpoint(_A,_B,u1);
_Q:=varpoint(_B,_C,u2);
_R:=varpoint(_A,_C,u3);
_X:=other_cc_point(_P,p3_circle(_A,_P,_R),p3_circle(_B,_P,_Q));
// conclusion
_result:=on_circle(_X,p3_circle(_C,_Q,_R));


// Example PappusPoint_1
// 
// The problem:
// Let $A,B,C$ and $P,Q,R$ be two triples of collinear points. Then by
// the Theorem of Pappus the intersection points $g(AQ)\wedge g(BP),
// g(AR)\wedge g(CP)$ and $g(BR)\wedge g(CQ)$ are collinear. 
// 
// Permuting $P,Q,R$ we get six such {\em Pappus lines}.  Those
// corresponding to even resp. odd permutations are concurrent.
// 
// The solution:

_parameters:=geoList(u1, u2, u3, u4, u5, u6, u7, u8);
// Points
_A:=Point(u1,0);
_B:=Point(u2,0);
_P:=Point(u4,u5);
_Q:=Point(u6,u7);
// coordinates
_C:=varpoint(_A,_B,u3);
_R:=varpoint(_P,_Q,u8);
// conclusion
_result:=is_concurrent(pappus_line(_A,_B,_C,_P,_Q,_R),
  pappus_line(_A,_B,_C,_Q,_R,_P), 
  pappus_line(_A,_B,_C,_R,_P,_Q));


// Example IMO/36_1
// 
// The problem:
// Let $A,B,C,D$ be four distinct points on a line, in that order. The
// circles with diameters $AC$ and $BD$ intersect at the points $X$ and
// $Y$. The line $XY$ meets $BC$ at the point $Z$. Let $P$ be a point on
// the line $XY$ different from $Z$. The line $CP$ intersects the circle
// with diameter $AC$ at the points $C$ and $M$, and the line $BP$
// intersects the circle with diameter $BD$ at the points $B$ and
// $N$. Prove that the lines $AM, DN$ and $XY$ are concurrent.
// 
// The solution:

_vars:=geoList(x1, x2, x3, x4, x5, x6);
_parameters:=geoList(u1, u2, u3);
// Points
_X:=Point(0,1);
_Y:=Point(0,-1);
_M:=Point(x1,x2);
_N:=Point(x3,x4);
// coordinates
_P:=varpoint(_X,_Y,u3);
_Z:=midpoint(_X,_Y);
_l:=p_bisector(_X,_Y);
_B:=line_slider(_l,u1);
_C:=line_slider(_l,u2);
_A:=line_slider(_l,x5);
_D:=line_slider(_l,x6);
// polynomials
_polys:=geoList(is_concyclic(_X,_Y,_B,_N), is_concyclic(_X,_Y,_C,_M),
  is_concyclic(_X,_Y,_B,_D), is_concyclic(_X,_Y,_C,_A),
  is_collinear(_B,_P,_N), is_collinear(_C,_P,_M));
// constraints
_nondeg:=geoList(x5-u2,x1-u2,x6-u1,x3-u1);
// conclusion
_con:=is_concurrent(pp_line(_A,_M),pp_line(_D,_N),pp_line(_X,_Y));
// solution
_sol:=geo_solveconstrained(_polys,_vars,_nondeg);
_result:=geo_eval(_con,_sol);


// Example IMO/43_2
// 
// The problem:
// 
// No verbal problem description available
// 
// The solution:

_vars:=geoList(x1, x2);
_parameters:=geoList(u1);
// Points
_B:=Point(-1,0);
_C:=Point(1,0);
// coordinates
_O:=midpoint(_B,_C);
_gamma:=pc_circle(_O,_B);
_D:=circle_slider(_O,_B,u1);
_E:=circle_slider(_O,_B,x1);
_F:=circle_slider(_O,_B,x2);
_A:=sym_point(_B,pp_line(_O,_D));
_J:=intersection_point(pp_line(_A,_C), par_line(_O, pp_line(_A,_D)));
_m:=p_bisector(_O,_A);
_P1:=pedalpoint(_J,_m);
_P2:=pedalpoint(_J,pp_line(_C,_E));
_P3:=pedalpoint(_J,pp_line(_C,_F));
// polynomials
_polys:=geoList(on_line(_E,_m), on_line(_F,_m));
// constraints
_nondegs:=geoList(x1-x2);
// conclusion
_con:=geoList(eq_dist(_J,_P1,_J,_P2), eq_dist(_J,_P1,_J,_P3));
// solution
_sol:=geo_solveconstrained(_polys,_vars,_nondegs); 
_result:=geo_simplify(geo_eval(_con,_sol));


quit;

