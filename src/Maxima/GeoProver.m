/*  GeoProver | Version 1.3a | 2007-02-09 */
/*  Author: H.-G. Graebe, Univ. Leipzig, Germany */
/*  http://www.informatik.uni-leipzig.de/~graebe */

/* 

Compiled from reduce.inline on 2014-12-07

Data structures:

	Point A  :== [a1,a2]       <=> A=(a1,a2)
	Line  a  :== [a1,a2,a3]    <=> a1*x+a2*y+a3 = 0
	Circle c :== [c0,c1,c2,c3] <=> c0*(x^2+y^2)+c1*x+c2*y+c3 = 0

*/

/* ==== Handling non degeneracy conditions ==== */

clear_ndg():= geoprover_ndg:[];
print_ndg():= geoprover_ndg;
add_ndg(d):=
  if not member(d,geoprover_ndg) then geoprover_ndg:cons(d,geoprover_ndg);

clear_ndg();

/* ==== elementary geometric constructions ==== */

/* Generators: */

is_equal(a,b):= a-b;
Normal(a):= ratsimp(a);
Point(a,b):= ratsimp(TP(a,b));
Line(a,b,c):= reduce_coords(TL(a,b,c));

reduce_coords(u):= /* Reduziere homogene Koordinaten, nennerfrei */ 
block([l,g], u:ratsimp(u),
  l:denom(first(u)), g:num(first(u)),
  for x in rest(u) do (l:lcm(l,denom(x)), g:gcd(g,num(x)) ) , 
  add_ndg(g),
  ratsimp(map(lambda([t],t*l/g),u))
);

par_point(a,b,c):=
  Point(part(a,1)-part(b,1)+part(c,1),
  part(a,2)-part(b,2)+part(c,2)); 

pp_line(a,b):= /* The line through A and B. */
  Line(part(b,2)-part(a,2),part(a,1)-part(b,1),
	part(a,2)*part(b,1)-part(a,1)*part(b,2)); 

intersection_point(a,b):= /* The intersection point of the lines a,b. */
   block([d,d1,d2], 
   d:expand(part(a,1)*part(b,2)-part(b,1)*part(a,2)),
   d1:expand(part(a,3)*part(b,2)-part(b,3)*part(a,2)),
   d2:expand(part(a,1)*part(b,3)-part(b,1)*part(a,3)),
   if d=0 then error("Lines are parallel"),
   add_ndg(num(d)),
   Point(-d1/d,-d2/d));

ortho_line(p,a):= /* The line through P orthogonal to the line a. */
  block([u:first(a), v:second(a)],
  Line(v,-u,u*second(p)-v*first(p)));

par_line(p,a):= /* The parallel to line a through P. */
  Line(part(a,1),part(a,2),
	-(part(a,1)*part(p,1)+part(a,2) *part(p,2)));

varpoint(b,a,l):= /* The point D=l*A+(1-l)*B. */
  Point(l*part(a,1)+(1-l)*part(b,1),l*part(a,2)+(1-l)*part(b,2));

line_slider(a,u):= /* Slider on the line a using parameter u.*/
  block([p,d],
  if part(a,2)=0 then 
	( p:Point(-part(a,3)/part(a,1),u), d:part(a,1))
  else 	
  	( p:Point(u,-(part(a,3)+part(a,1)*u)/part(a,2)), d:part(a,2)), 
  add_ndg(num(d)), p);

circle_slider(M,A,u):= /* Slider on the circle with center M 
   and circumfere point A using parameter u. */
  block([a1:part(A,1),a2:part(A,2),m1:part(M,1),m2:part(M,2),d:u^2 + 1], 
  add_ndg(num(d)), 
  Point((a1*(u^2-1) + 2*m1 + 2*(m2-a2)*u)/d, 
	 (a2 + 2*(m1-a1)*u + (2*m2-a2)*u^2)/d)); 

sqrdist(a,b):= /* The square of the distance between the points A and B. */
  ratsimp((part(b,1)-part(a,1))^2+(part(b,2)-part(a,2))^2);

/*======= elementary geometric properties ====== */

is_collinear(a,b,c):= /* A,B,C are on a common line. */
ratsimp(determinant(matrix(
     [part(a,1),part(a,2),1],
     [part(b,1),part(b,2),1],
     [part(c,1),part(c,2),1])));

is_concurrent(a,b,c):= /* Lines a,b,c have a common point. */
ratsimp(determinant(matrix(
	[part(a,1),part(a,2),part(a,3)],
	[part(b,1),part(b,2),part(b,3)],
	[part(c,1),part(c,2),part(c,3)])));

is_parallel(a,b):= /* 0 <=> the lines a,b are parallel. */
  ratsimp(part(a,1)*part(b,2)-part(b,1)*part(a,2));

is_orthogonal(a,b):= /* 0 <=> the lines a,b are orthogonal. */
  ratsimp(part(a,1)*part(b,1)+part(a,2)*part(b,2));

on_line(p,a):= /* Substitute point P into the line a. */
  ratsimp(part(p,1)*part(a,1)+part(p,2)*part(a,2)+part(a,3));

eq_dist(a,b,c,d):= ratsimp(sqrdist(a,b)-sqrdist(c,d));

/* 

	#########################################
	#					#
	#      Non linear geometric objects	#
	#					#
	#########################################

*/

/* ======= angles ======= */

l2_angle(a,b):=
/* tan of the angle between the lines a and b. */
  block([d:ratsimp(part(a,1)*part(b,1)+part(a,2)*part(b,2))], 
  add_ndg(num(d)),
  ratsimp((part(a,2)*part(b,1)-part(b,2)*part(a,1))/d)
);

angle_sum(a,b):=
/* a=tan(\alpha), b=tan(\beta). Returns tan(\alpha+\beta) */
  block([d:(1-a*b)], add_ndg(num(d)), ratsimp((a+b)/d)
);

eq_angle(a,b,c,d,e,f):=
  num(ratsimp(p3_angle(a,b,c)-p3_angle(d,e,f)));
  
rotate(C, A, angle):=
  block([ac1,ac2],
  ac1:part(A,1)-part(C,1), ac2:part(A,2)-part(C,2),
  ratsimp(Point(part(C,1)+ac1*cos(angle*%pi)-ac2*sin(angle*%pi),
    part(C,2)+ac1*sin(angle*%pi)+ac2*cos(angle*%pi)))
);

/* ========== symmetric lines and points */

sym_line(a,l):=
/* The line symmetric to a wrt. the line l. */
  block([a1,a2,a3,l1,l2,l3,u,u1,u2,u3],
  a1:part(a,1), a2:part(a,2), a3:part(a,3), 
  l1:part(l,1), l2:part(l,2), l3:part(l,3), 
  u3: -2*(a1*l1 + a2*l2)*l3 + a3*(l1^2 + l2^2),
  u:l1^2 - l2^2, u1:- a1*u - 2*a2*l1*l2, u2:- 2*a1*l1*l2 + a2*u,
  Line(u1,u2,u3)
);


/* ===================== circles */

Circle(c1,c2,c3,c4):= reduce_coords(TC(c1,c2,c3,c4));

pc_circle(M,A):=
/* Circle with center M and Point A on circumference. */
  Circle(1, -2*part(M,1), -2*part(M,2),
	    part(A,1)*(2*part(M,1)-part(A,1)) +
	    part(A,2)*(2*part(M,2)-part(A,2)));

circle_center(c):=
/* The center of the circle c */
  block(add_ndg(num(part(c,1))),
  Point(-part(c,2)/2/part(c,1) ,-part(c,3)/(2*part(c,1)))
);
 
circle_sqradius(c):=
/* The squared radius of the circle c. */
  block(add_ndg(num(part(c,1))),
   ratsimp(((part(c,2)^2+part(c,3)^2) - 4*part(c,4)*part(c,1)) / 
	(2*part(c,1))^2)
);

on_circle(P,c):=
  block([p1:part(P,1), p2:part(P,2)],
  ratsimp(part(c,1)*(p1^2+p2^2)+part(c,2)*p1+part(c,3)*p2+part(c,4))
);

/* Intersecting with circles */

other_cl_point(P,c,l):=
/* circle c and line l intersect at P. The procedure returns their
 second intersection point. */
  if on_line(P,l) != 0 then error("Point not on the line")
  else if on_circle(P,c) != 0 then 
	error( "Point not on the circle")
  else block([c1,c2,c3,l1,l2,d,d1,p1,p2],
  c1:part(c,1), c2:part(c,2), c3:part(c,3), 
  l1:part(l,1), l2:part(l,2), p1:part(P,1), p2:part(P,2),
  d:c1*(l1^2 + l2^2), add_ndg(num(d)), d1:c1*(l1^2-l2^2),
  Point((d1*p1+((2*c1*p2 + c3)*l1-c2*l2)*l2)/d, 
	(- d1*p2+((2*c1*p1 + c2)*l2-c3*l1)*l1)/d)
);
  

radical_axis(c1,c2):=
/* Radical axis of the circles c1 and c2, i.e. the line through the
 intersection points of the two circles if they intersect. */
  Line((part(c1,1)*part(c2,2)-part(c1,2)*part(c2,1)),
       (part(c1,1)*part(c2,3)-part(c1,3)*part(c2,1)),
       (part(c1,1)*part(c2,4)-part(c1,4)*part(c2,1))); 

is_cl_tangent(c,l):=
/* Line l is tangent to the circle c */
  block([c1,c2,c3,c4,l1,l2,l3],
  c1:part(c,1), c2:part(c,2), c3:part(c,3), c4:part(c,4), 
  l1:part(l,1), l2:part(l,2), l3:part(l,3), 
  ratsimp(- 4*c1^2*l3^2 + 4*c1*c2*l1*l3 + 4*c1*c3*l2*l3 -
	4*c1*c4*l1^2 - 4*c1*c4*l2^2 + c2^2*l2^2 - 2*c2*c3*l1*l2 +
	c3^2*l1^2)
);

tangent_line(P,c):=
  if on_circle(P,c) !=0 then error("Point not on the circle")
  else Line(2*part(c,1)*part(P,1)+part(c,2), 2*part(c,1)*part(P,2)+part(c,3),
                part(c,2)*part(P,1)+part(c,3)*part(P,2)+2*part(c,4));

/* ================ new */ 

circle_inverse(M,R,P):=
/* compute the inverse of P wrt. the circle pc_circle(M,R) */
  block([m1,m2,r1,r2,p1,p2,d],
  m1:part(M,1), m2:part(M,2), 
  r1:part(R,1), r2:part(R,2), 
  p1:part(P,1), p2:part(P,2), 
  d:(m1-p1)^2+(m2-p2)^2,
  add_ndg(d),
  ratsimp(((m1-p1)^2+(m2-p2)^2+(m1-r1)^2+(m2-r2)^2)/d)
);
/* GeoProver code generated from database */ 

altitude(A_,B_,C_):=
	ortho_line(A_,pp_line(B_,C_));

centroid(A_,B_,C_):=
	intersection_point(median(A_,B_,C_),median(B_,C_,A_));

circumcenter(A_,B_,C_):=
	intersection_point(p_bisector(A_,B_),p_bisector(B_,C_));

csym_point(P_,Q_):=
	varpoint(Q_,P_,-1);

fixedpoint(A_,B_,u_):=
	varpoint(A_,B_,u_);

is_cc_tangent(c1_,c2_):=
	is_cl_tangent(c1_,radical_axis(c1_,c2_));

is_concyclic(A_,B_,C_,D_):=
	on_circle(D_,p3_circle(A_,B_,C_));

median(A_,B_,C_):=
	pp_line(A_,midpoint(B_,C_));

midpoint(A_,B_):=
	fixedpoint(A_,B_,1/2);

on_bisector(P_,A_,B_,C_):=
	eq_angle(A_,B_,P_,P_,B_,C_);

orthocenter(A_,B_,C_):=
	intersection_point(altitude(A_,B_,C_),altitude(B_,C_,A_));

other_cc_point(P_,c1_,c2_):=
	other_cl_point(P_,c1_,radical_axis(c1_,c2_));

other_incenter(M_,A_,B_):=
	intersection_point(ortho_line(A_,pp_line(M_,A_)),ortho_line(B_,pp_line(M_,B_)));

p3_angle(A_,B_,C_):=
	l2_angle(pp_line(B_,A_),pp_line(B_,C_));

p3_circle(A_,B_,C_):=
	pc_circle(intersection_point(p_bisector(A_,B_),p_bisector(A_,C_)),A_);

p9_center(A_,B_,C_):=
	circle_center(p9_circle(A_,B_,C_));

p9_circle(A_,B_,C_):=
	p3_circle(midpoint(A_,B_),midpoint(A_,C_),midpoint(B_,C_));

p_bisector(B_,C_):=
	ortho_line(midpoint(B_,C_),pp_line(B_,C_));

pappus_line(A_,B_,C_,D_,E_,F_):=
	pp_line(intersection_point(pp_line(A_,E_),pp_line(B_,D_)),intersection_point(pp_line(A_,F_),pp_line(C_,D_)));

pedalpoint(P_,a_):=
	intersection_point(ortho_line(P_,a_),a_);

sqrdist_pl(A_,l_):=
	sqrdist(A_,pedalpoint(A_,l_));

sym_point(P_,l_):=
	fixedpoint(P_,pedalpoint(P_,l_),2);

triangle_area(A_,B_,C_):=
	1/2*is_collinear(A_,B_,C_);

clear_ndg();
load(functs);
