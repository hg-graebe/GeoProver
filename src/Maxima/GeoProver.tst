/*
  GeoProver test file for Maxima, created 02/2017, fixed 01/2018.
*/

/* Example Arnon

The problem:
Let $ABCD$ be a square and $P$ a point on the line parallel to $BD$
through $C$ such that $l(BD)=l(BP)$, where $l(BD)$ denotes the
distance between $B$ and $D$. Let $Q$ be the intersection point of
$BF$ and $CD$. Show that $l(DP)=l(DQ)$.
*/

load(functs);
batchload("GeoProver.m");
batchload("supp.m");
clear_ndg();

vars_:[x1, x2, x3];

A:Point(0,0); B:Point(1,0); P:Point(x1,x2);
D:rotate(A,B,1/2);
C:par_point(D,A,B); 
Q:varpoint(D,C,x3);

polys_:[on_line(P,par_line(C,pp_line(B,D))),
  eq_dist(B,D,B,P), on_line(Q,pp_line(B,P))];

con_:eq_dist(D,P,D,Q);

gb_:geo_gbasis(polys_,vars_);
result_:geo_normalf(con_,gb_,vars_);


/* Example CircumCenter_1

The problem:
The intersection point of the midpoint perpendiculars is the
center of the circumscribed circle.
*/

parameters_:[a1, a2, b1, b2, c1, c2];

A:Point(a1,a2);
B:Point(b1,b2);
C:Point(c1,c2);

M:intersection_point(p_bisector(A,B), p_bisector(B,C));

result_:[ eq_dist(M,A,M,B), eq_dist(M,A,M,C)];


/* Example EulerLine_1

The problem:
Euler's line: The center $M$ of the circumscribed circle,
the orthocenter $H$ and the barycenter $S$ are collinear and $S$
divides $MH$ with ratio 1:2.
*/


parameters_:[a1, a2, b1, b2, c1, c2];

A:Point(a1,a2);
B:Point(b1,b2);
C:Point(c1,c2);
S:intersection_point(median(A,B,C),median(B,C,A));
M:intersection_point(p_bisector(A,B), p_bisector(B,C));
H:intersection_point(altitude(A,B,C),altitude(B,C,A));

result_:[is_collinear(M,H,S), sqrdist(S,fixedpoint(M,H,1/3))];

/* Example Brocard_3

The problem:
Theorem about the Brocard points:
Let $\Delta\,ABC$ be a triangle. The circles $c_1$ through $A,B$ and
tangent to $g(AC)$, $c_2$ through $B,C$ and tangent to $g(AB)$, and
$c_3$ through $A,C$ and tangent to $g(BC)$ pass through a common
point. */

parameters_:[u1, u2];

A:Point(0,0);
B:Point(1,0);
C:Point(u1,u2);
M_1_:intersection_point(altitude(A,A,C),p_bisector(A,B));
M_2_:intersection_point(altitude(B,B,A),p_bisector(B,C));
M_3_:intersection_point(altitude(C,C,B),p_bisector(A,C));
c1_:pc_circle(M_1_,A);
c2_:pc_circle(M_2_,B);
c3_:pc_circle(M_3_,C);

P:other_cc_point(B,c1_,c2_);

result_: on_circle(P,c3_);


/* Example Feuerbach_1

The problem:
Feuerbach's circle or nine-point circle: The midpoint $N$ of $MH$ is
the center of a circle that passes through nine special points, the
three pedal points of the altitudes, the midpoints of the sides of the
triangle and the midpoints of the upper parts of the three altitudes.
*/

parameters_:[u1, u2, u3];

A:Point(0,0);
B:Point(u1,0);
C:Point(u2,u3);
H:intersection_point(altitude(A,B,C),altitude(B,C,A));
D:intersection_point(pp_line(A,B),pp_line(H,C));
M:intersection_point(p_bisector(A,B),p_bisector(B,C));
N:midpoint(M,H);

result_:[ eq_dist(N,midpoint(A,B),N,midpoint(B,C)),
  eq_dist(N,midpoint(A,B),N,midpoint(H,C)),
  eq_dist(N,midpoint(A,B),N,D) ];


/* Example FeuerbachTangency_1

The problem:
For an arbitrary triangle $\Delta\,ABC$ Feuerbach's circle (nine-point
circle) is tangent to its 4 tangent circles. */

vars_:[x1, x2];
parameters_:[u1, u2];

A:Point(0,0);
B:Point(2,0);
C:Point(u1,u2);
P:Point(x1,x2);
M:intersection_point(p_bisector(A,B), p_bisector(B,C));
H:intersection_point(altitude(A,B,C),altitude(B,C,A));
N:midpoint(M,H);
c1_:pc_circle(N,midpoint(A,B));
Q:pedalpoint(P,pp_line(A,B));

polys_:[on_bisector(P,A,B,C), on_bisector(P,B,C,A)];

con_:is_cc_tangent(pc_circle(P,Q),c1_);

gb_:geo_gbasis(polys_,vars_);
result_:geo_normalf(con_,gb_,vars_);


/* Example GeneralizedFermatPoint_1

The problem:
A generalized theorem about Napoleon triangles:
Let $\Delta\,ABC$ be an arbitrary triangle and $P,Q$ and $R$ the third
vertex of isosceles triangles with equal base angles erected
externally on the sides $BC, AC$ and $AB$ of the triangle. Then the
lines $g(AP), g(BQ)$ and $g(CR)$ pass through a common point.
*/

vars_:[x1, x2, x3, x4, x5];
parameters_:[u1, u2, u3];

A:Point(0,0);
B:Point(2,0);
C:Point(u1,u2);
P:Point(x1,x2);
Q:Point(x3,x4);
R:Point(x5,u3);

polys_:[eq_dist(P,B,P,C), 
  eq_dist(Q,A,Q,C),  
  eq_dist(R,A,R,B), 
  eq_angle(R,A,B,P,B,C), 
  eq_angle(Q,C,A,P,B,C)];

con_:is_concurrent(pp_line(A,P), pp_line(B,Q), pp_line(C,R));

gb:geo_gbasis(polys_,vars_);
geo_normalf(con_,gb,vars_);

/* Example TaylorCircle_1

The problem:
Let $\Delta\,ABC$ be an arbitrary triangle. Consider the three
altitude pedal points and the pedal points of the perpendiculars from
these points onto the the opposite sides of the triangle. Show that
these 6 points are on a common circle, the {\em Taylor circle}.
*/

parameters_:[u1, u2, u3];

A:Point(u1,0);
B:Point(u2,0);
C:Point(0,u3);

P:pedalpoint(A,pp_line(B,C));
Q:pedalpoint(B,pp_line(A,C));
R:pedalpoint(C,pp_line(A,B));
P_1_:pedalpoint(P,pp_line(A,B));
P_2_:pedalpoint(P,pp_line(A,C));
Q_1_:pedalpoint(Q,pp_line(A,B));
Q_2_:pedalpoint(Q,pp_line(B,C));
R_1_:pedalpoint(R,pp_line(A,C));
R_2_:pedalpoint(R,pp_line(B,C));

result_:[ is_concyclic(P_1_,P_2_,Q_1_,Q_2_), 
  is_concyclic(P_1_,P_2_,Q_1_,R_1_),
  is_concyclic(P_1_,P_2_,Q_1_,R_2_)];


/* Example Miquel_1

The problem:
Miquels theorem: Let $\Delta\,ABC$ be a triangle. Fix arbitrary points
$P,Q,R$ on the sides $AB, BC, AC$. Then the three circles through each
vertex and the chosen points on adjacent sides pass through a common
point. */

parameters_:[c1, c2, u1, u2, u3];

A:Point(0,0);
B:Point(1,0);
C:Point(c1,c2);

P:varpoint(A,B,u1);
Q:varpoint(B,C,u2);
R:varpoint(A,C,u3);
X:other_cc_point(P,p3_circle(A,P,R),p3_circle(B,P,Q));

result_:on_circle(X,p3_circle(C,Q,R));

/* Example PappusPoint_1

The problem:
Let $A,B,C$ and $P,Q,R$ be two triples of collinear points. Then by
the Theorem of Pappus the intersection points $g(AQ)\wedge g(BP),
g(AR)\wedge g(CP)$ and $g(BR)\wedge g(CQ)$ are collinear. 

Permuting $P,Q,R$ we get six such {\em Pappus lines}.  Those
corresponding to even resp. odd permutations are concurrent. */

parameters_:[u1, u2, u3, u4, u5, u6, u7, u8];

A:Point(u1,0);
B:Point(u2,0);
P:Point(u4,u5);
Q:Point(u6,u7);

C:varpoint(A,B,u3);
R:varpoint(P,Q,u8);

result_:is_concurrent(pappus_line(A,B,C,P,Q,R),
  pappus_line(A,B,C,Q,R,P), 
  pappus_line(A,B,C,R,P,Q));

/* 
Example IMO/36_1

The problem:
Let $A,B,C,D$ be four distinct points on a line, in that order. The
circles with diameters $AC$ and $BD$ intersect at the points $X$ and
$Y$. The line $XY$ meets $BC$ at the point $Z$. Let $P$ be a point on
the line $XY$ different from $Z$. The line $CP$ intersects the circle
with diameter $AC$ at the points $C$ and $M$, and the line $BP$
intersects the circle with diameter $BD$ at the points $B$ and
$N$. Prove that the lines $AM, DN$ and $XY$ are concurrent.
*/

vars_:[x1, x2, x3, x4, x5, x6];
parameters_:[u1, u2, u3];

X:Point(0,1);
Y:Point(0,-1);
M:Point(x1,x2);
N:Point(x3,x4);

P:varpoint(X,Y,u3);
Z:midpoint(X,Y);
l_:p_bisector(X,Y);
B:line_slider(l_,u1);
C:line_slider(l_,u2);
A:line_slider(l_,x5);
D:line_slider(l_,x6);

polys_:[is_concyclic(X,Y,B,N), is_concyclic(X,Y,C,M),
  is_concyclic(X,Y,B,D), is_concyclic(X,Y,C,A),
  is_collinear(B,P,N), is_collinear(C,P,M)];

nondeg_:[x5-u2,x1-u2,x6-u1,x3-u1];

con_:is_concurrent(pp_line(A,M),pp_line(D,N),pp_line(X,Y));

gb:geo_gbasis(polys_,vars_);
p:apply("*",nondeg_);
geo_normalf(con_,gb,vars_);
geo_normalf(p*con_,gb,vars_);

/* 
Example IMO/43_2

The problem:

No verbal problem description available
*/


vars_:[x1, x2];
parameters_:[u1];

B:Point(-1,0);
C:Point(1,0);

O:midpoint(B,C);
gamma_:pc_circle(O,B);
D:circle_slider(O,B,u1);
E:circle_slider(O,B,x1);
F:circle_slider(O,B,x2);
A:sym_point(B,pp_line(O,D));
J:intersection_point(pp_line(A,C), par_line(O, pp_line(A,D)));
m_:p_bisector(O,A);
P_1_:pedalpoint(J,m_);
P_2_:pedalpoint(J,pp_line(C,E));
P_3_:pedalpoint(J,pp_line(C,F));

polys_:[on_line(E,m_), on_line(F,m_)];

con_:[eq_dist(J,P_1_,J,P_2_), eq_dist(J,P_1_,J,P_3_)];

gb:geo_gbasis(polys_,vars_);
geo_normalf(con_[1],gb,vars_);
geo_normalf(con_[2],gb,vars_);

quit;

