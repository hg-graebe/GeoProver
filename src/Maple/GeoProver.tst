# GeoProver test file for Maple, created on Jan 18 2003
read("GeoProver.mpl"):
read("supp.mpl"):
with(geoprover):
interface(prettyprint=0):

# Example Arnon
# 
# The problem:
# Let $ABCD$ be a square and $P$ a point on the line parallel to $BD$
# through $C$ such that $l(BD)=l(BP)$, where $l(BD)$ denotes the
# distance between $B$ and $D$. Let $Q$ be the intersection point of
# $BF$ and $CD$. Show that $l(DP)=l(DQ)$.
# 
# The solution:

vars_:=List(x1, x2, x3);
# Points
A_:=Point(0,0); B_:=Point(1,0); P_:=Point(x1,x2);
# coordinates
D_:=rotate(A_,B_,1/2);
C_:=par_point(D_,A_,B_); 
Q_:=varpoint(D_,C_,x3);
# polynomials
polys_:=List(on_line(P_,par_line(C_,pp_line(B_,D_))),
  eq_dist(B_,D_,B_,P_), on_line(Q_,pp_line(B_,P_)));
# conclusion
con_:=eq_dist(D_,P_,D_,Q_);
# solution
gb_:=geo_gbasis(polys_,vars_);
result_:=geo_normalf(con_,gb_,vars_);


# Example CircumCenter_1
# 
# The problem:
# The intersection point of the midpoint perpendiculars is the
# center of the circumscribed circle.
# 
# The solution:

parameters_:=List(a1, a2, b1, b2, c1, c2);
# Points
A_:=Point(a1,a2);
B_:=Point(b1,b2);
C_:=Point(c1,c2);
# coordinates
M_:=intersection_point(p_bisector(A_,B_),
  p_bisector(B_,C_));
# conclusion
result_:=List( eq_dist(M_,A_,M_,B_), eq_dist(M_,A_,M_,C_) );


# Example EulerLine_1
# 
# The problem:
# Euler's line: The center $M$ of the circumscribed circle,
# the orthocenter $H$ and the barycenter $S$ are collinear and $S$
# divides $MH$ with ratio 1:2.
# 
# The solution:

parameters_:=List(a1, a2, b1, b2, c1, c2);
# Points
A_:=Point(a1,a2);
B_:=Point(b1,b2);
C_:=Point(c1,c2);
# coordinates
S_:=intersection_point(median(A_,B_,C_),median(B_,C_,A_));
M_:=intersection_point(p_bisector(A_,B_),
  p_bisector(B_,C_));
H_:=intersection_point(altitude(A_,B_,C_),altitude(B_,C_,A_));
# conclusion
result_:=List(is_collinear(M_,H_,S_), sqrdist(S_,fixedpoint(M_,H_,1/3)));


# Example Brocard_3
# 
# The problem:
# Theorem about the Brocard points:
# Let $\Delta\,ABC$ be a triangle. The circles $c_1$ through $A,B$ and
# tangent to $g(AC)$, $c_2$ through $B,C$ and tangent to $g(AB)$, and
# $c_3$ through $A,C$ and tangent to $g(BC)$ pass through a common
# point.
# 
# The solution:

parameters_:=List(u1, u2);
# Points
A_:=Point(0,0);
B_:=Point(1,0);
C_:=Point(u1,u2);
# coordinates
M1_:=intersection_point(altitude(A_,A_,C_),p_bisector(A_,B_));
M2_:=intersection_point(altitude(B_,B_,A_),p_bisector(B_,C_));
M3_:=intersection_point(altitude(C_,C_,B_),p_bisector(A_,C_));
c1_:=pc_circle(M1_,A_);
c2_:=pc_circle(M2_,B_);
c3_:=pc_circle(M3_,C_);
P_:=other_cc_point(B_,c1_,c2_);
# conclusion
result_:= on_circle(P_,c3_);


# Example Feuerbach_1
# 
# The problem:
# Feuerbach's circle or nine-point circle: The midpoint $N$ of $MH$ is
# the center of a circle that passes through nine special points, the
# three pedal points of the altitudes, the midpoints of the sides of the
# triangle and the midpoints of the upper parts of the three altitudes.
# 
# The solution:

parameters_:=List(u1, u2, u3);
# Points
A_:=Point(0,0);
B_:=Point(u1,0);
C_:=Point(u2,u3);
# coordinates
H_:=intersection_point(altitude(A_,B_,C_),altitude(B_,C_,A_));
D_:=intersection_point(pp_line(A_,B_),pp_line(H_,C_));
M_:=intersection_point(p_bisector(A_,B_),
  p_bisector(B_,C_));
N_:=midpoint(M_,H_);
# conclusion
result_:=List( eq_dist(N_,midpoint(A_,B_),N_,midpoint(B_,C_)),
  eq_dist(N_,midpoint(A_,B_),N_,midpoint(H_,C_)),
  eq_dist(N_,midpoint(A_,B_),N_,D_) );


# Example FeuerbachTangency_1
# 
# The problem:
# For an arbitrary triangle $\Delta\,ABC$ Feuerbach's circle (nine-point
# circle) is tangent to its 4 tangent circles.
# 
# The solution:

vars_:=List(x1, x2);
parameters_:=List(u1, u2);
# Points
A_:=Point(0,0);
B_:=Point(2,0);
C_:=Point(u1,u2);
P_:=Point(x1,x2);
# coordinates
M_:=intersection_point(p_bisector(A_,B_), p_bisector(B_,C_));
H_:=intersection_point(altitude(A_,B_,C_),altitude(B_,C_,A_));
N_:=midpoint(M_,H_);
c1_:=pc_circle(N_,midpoint(A_,B_));
Q_:=pedalpoint(P_,pp_line(A_,B_));
# polynomials
polys_:=List(on_bisector(P_,A_,B_,C_), on_bisector(P_,B_,C_,A_));
# conclusion
con_:=is_cc_tangent(pc_circle(P_,Q_),c1_);
# solution
gb_:=geo_gbasis(polys_,vars_);
result_:=geo_normalf(con_,gb_,vars_);


# Example GeneralizedFermatPoint_1
# 
# The problem:
# A generalized theorem about Napoleon triangles:
# Let $\Delta\,ABC$ be an arbitrary triangle and $P,Q$ and $R$ the third
# vertex of isosceles triangles with equal base angles erected
# externally on the sides $BC, AC$ and $AB$ of the triangle. Then the
# lines $g(AP), g(BQ)$ and $g(CR)$ pass through a common point.
# 
# The solution:

vars_:=List(x1, x2, x3, x4, x5);
parameters_:=List(u1, u2, u3);
# Points
A_:=Point(0,0);
B_:=Point(2,0);
C_:=Point(u1,u2);
P_:=Point(x1,x2);
Q_:=Point(x3,x4);
R_:=Point(x5,u3);
# polynomials
polys_:=List(eq_dist(P_,B_,P_,C_), 
  eq_dist(Q_,A_,Q_,C_),  
  eq_dist(R_,A_,R_,B_), 
  eq_angle(R_,A_,B_,P_,B_,C_), 
  eq_angle(Q_,C_,A_,P_,B_,C_));
# conclusion
con_:=is_concurrent(pp_line(A_,P_), pp_line(B_,Q_), pp_line(C_,R_));
# solution
sol_:=geo_solve(polys_,vars_);
result_:=geo_eval(con_,sol_);


# Example TaylorCircle_1
# 
# The problem:
# Let $\Delta\,ABC$ be an arbitrary triangle. Consider the three
# altitude pedal points and the pedal points of the perpendiculars from
# these points onto the the opposite sides of the triangle. Show that
# these 6 points are on a common circle, the {\em Taylor circle}.
# 
# The solution:

parameters_:=List(u1, u2, u3);
# Points
A_:=Point(u1,0);
B_:=Point(u2,0);
C_:=Point(0,u3);
# coordinates
P_:=pedalpoint(A_,pp_line(B_,C_));
Q_:=pedalpoint(B_,pp_line(A_,C_));
R_:=pedalpoint(C_,pp_line(A_,B_));
P1_:=pedalpoint(P_,pp_line(A_,B_));
P2_:=pedalpoint(P_,pp_line(A_,C_));
Q1_:=pedalpoint(Q_,pp_line(A_,B_));
Q2_:=pedalpoint(Q_,pp_line(B_,C_));
R1_:=pedalpoint(R_,pp_line(A_,C_));
R2_:=pedalpoint(R_,pp_line(B_,C_));
# conclusion
result_:=List( is_concyclic(P1_,P2_,Q1_,Q2_), 
  is_concyclic(P1_,P2_,Q1_,R1_),
  is_concyclic(P1_,P2_,Q1_,R2_));


# Example Miquel_1
# 
# The problem:
# Miquels theorem: Let $\Delta\,ABC$ be a triangle. Fix arbitrary points
# $P,Q,R$ on the sides $AB, BC, AC$. Then the three circles through each
# vertex and the chosen points on adjacent sides pass through a common
# point.
# 
# The solution:

parameters_:=List(c1, c2, u1, u2, u3);
# Points
A_:=Point(0,0);
B_:=Point(1,0);
C_:=Point(c1,c2);
# coordinates
P_:=varpoint(A_,B_,u1);
Q_:=varpoint(B_,C_,u2);
R_:=varpoint(A_,C_,u3);
X_:=other_cc_point(P_,p3_circle(A_,P_,R_),p3_circle(B_,P_,Q_));
# conclusion
result_:=on_circle(X_,p3_circle(C_,Q_,R_));


# Example PappusPoint_1
# 
# The problem:
# Let $A,B,C$ and $P,Q,R$ be two triples of collinear points. Then by
# the Theorem of Pappus the intersection points $g(AQ)\wedge g(BP),
# g(AR)\wedge g(CP)$ and $g(BR)\wedge g(CQ)$ are collinear. 
# 
# Permuting $P,Q,R$ we get six such {\em Pappus lines}.  Those
# corresponding to even resp. odd permutations are concurrent.
# 
# The solution:

parameters_:=List(u1, u2, u3, u4, u5, u6, u7, u8);
# Points
A_:=Point(u1,0);
B_:=Point(u2,0);
P_:=Point(u4,u5);
Q_:=Point(u6,u7);
# coordinates
C_:=varpoint(A_,B_,u3);
R_:=varpoint(P_,Q_,u8);
# conclusion
result_:=is_concurrent(pappus_line(A_,B_,C_,P_,Q_,R_),
  pappus_line(A_,B_,C_,Q_,R_,P_), 
  pappus_line(A_,B_,C_,R_,P_,Q_));


# Example IMO/36_1
# 
# The problem:
# Let $A,B,C,D$ be four distinct points on a line, in that order. The
# circles with diameters $AC$ and $BD$ intersect at the points $X$ and
# $Y$. The line $XY$ meets $BC$ at the point $Z$. Let $P$ be a point on
# the line $XY$ different from $Z$. The line $CP$ intersects the circle
# with diameter $AC$ at the points $C$ and $M$, and the line $BP$
# intersects the circle with diameter $BD$ at the points $B$ and
# $N$. Prove that the lines $AM, DN$ and $XY$ are concurrent.
# 
# The solution:

vars_:=List(x1, x2, x3, x4, x5, x6);
parameters_:=List(u1, u2, u3);
# Points
X_:=Point(0,1);
Y_:=Point(0,-1);
M_:=Point(x1,x2);
N_:=Point(x3,x4);
# coordinates
P_:=varpoint(X_,Y_,u3);
Z_:=midpoint(X_,Y_);
l_:=p_bisector(X_,Y_);
B_:=line_slider(l_,u1);
C_:=line_slider(l_,u2);
A_:=line_slider(l_,x5);
D_:=line_slider(l_,x6);
# polynomials
polys_:=List(is_concyclic(X_,Y_,B_,N_), is_concyclic(X_,Y_,C_,M_),
  is_concyclic(X_,Y_,B_,D_), is_concyclic(X_,Y_,C_,A_),
  is_collinear(B_,P_,N_), is_collinear(C_,P_,M_));
# constraints
nondeg_:=List(x5-u2,x1-u2,x6-u1,x3-u1);
# conclusion
con_:=is_concurrent(pp_line(A_,M_),pp_line(D_,N_),pp_line(X_,Y_));
# solution
sol_:=geo_solveconstrained(polys_,vars_,nondeg_);
result_:=geo_eval(con_,sol_);


# Example IMO/43_2
# 
# The problem:
# 
# No verbal problem description available
# 
# The solution:

vars_:=List(x1, x2);
parameters_:=List(u1);
# Points
B_:=Point(-1,0);
C_:=Point(1,0);
# coordinates
O_:=midpoint(B_,C_);
gamma_:=pc_circle(O_,B_);
D_:=circle_slider(O_,B_,u1);
E_:=circle_slider(O_,B_,x1);
F_:=circle_slider(O_,B_,x2);
A_:=sym_point(B_,pp_line(O_,D_));
J_:=intersection_point(pp_line(A_,C_), par_line(O_, pp_line(A_,D_)));
m_:=p_bisector(O_,A_);
P1_:=pedalpoint(J_,m_);
P2_:=pedalpoint(J_,pp_line(C_,E_));
P3_:=pedalpoint(J_,pp_line(C_,F_));
# polynomials
polys_:=List(on_line(E_,m_), on_line(F_,m_));
# constraints
nondegs_:=List(x1-x2);
# conclusion
con_:=List(eq_dist(J_,P1_,J_,P2_), eq_dist(J_,P1_,J_,P3_));
# solution
sol_:=geo_solveconstrained(polys_,vars_,nondegs_); 
result_:=geo_simplify(geo_eval(con_,sol_));


quit;

