//  GeoProver | Version 1.3a | 2007-02-09
//  Author: H.-G. Graebe, Univ. Leipzig, Germany
//  http://www.informatik.uni-leipzig.de/~graebe

// GeoProver interface 

geoprover:=newDomain("geoprover"):
geoprover::info:="The package GeoProver is a small package for mechanized\
 \n(plane) geometry manipulations with non-degeneracy tracing. \n":

geoprover::interface:={
hold(altitude),
hold(centroid),
hold(circumcenter),
hold(csym_point),
hold(fixedpoint),
hold(is_cc_tangent),
hold(is_concyclic),
hold(median),
hold(midpoint),
hold(on_bisector),
hold(orthocenter),
hold(other_cc_point),
hold(other_incenter),
hold(p3_angle),
hold(p3_circle),
hold(p9_center),
hold(p9_circle),
hold(p_bisector),
hold(pappus_line),
hold(pedalpoint),
hold(sqrdist_pl),
hold(sym_point),
hold(triangle_area),
hold(clear_ndg),
hold(print_ndg),
hold(add_ndg),
hold(geo_plot)}:


/*

Changes:
10 Feb 2007: iszero to all boolean evaluations added
17 Jan 2003: contains also geo_plot code
 4 Jun 2003: l[i] instead of op(a,i) or part(a,i)
14 Jun 2003: other_cc_point and is_cc_tangent moved to macro  
	     tangent_line added
29 Jun 2003: on_bisector, p3_circle moved to macro

Inline GeoProver code Version 1.3b

Data structures:

        Point A  :== [a1,a2]       <=> A=(a1,a2)
        Line  a  :== [a1,a2,a3]    <=> a1*x+a2*y+a3 = 0
	Circle c :== [c0,c1,c2,c3] <=> c0*(x^2+y^2)+c1*x+c2*y+c3 = 0

4 Jun 2003: l[i] instead of op,
	    plot part was already added

*/

/* a hook for a domain concept */

geoprover::DOM_GEO:=DOM_LIST:         /* superdomain */
geoprover::DOM_POINT:=DOM_LIST:
geoprover::DOM_LINE:=DOM_LIST:
geoprover::DOM_CIRCLE:=DOM_LIST:

// ================================================================
// ============= Handling non degeneracy conditions =============== 
// ================================================================

geoprover::clear_ndg:=
proc() begin geoprover::ndg_list:=[]: end_proc:

geoprover::clear_ndg(): // Initialization

geoprover::print_ndg:=
proc() begin print(geoprover::ndg_list) end_proc:

geoprover::add_ndg:=proc(d) 
begin 
  if contains(geoprover::ndg_list,d)=0 then
    geoprover::ndg_list:=append(geoprover::ndg_list,d) 
  end_if 
end_proc:

geoprover::reduce_coords:=proc(u)
// Divide out the content of homogeneous coordinates.
  local p,l,g,i;
begin
  p:=u[1]; l:=denom(p); g:=numer(p);
  for i from 2 to nops(u) do 
	p:=u[i]; l:=lcm(l,denom(p)); g:=gcd(g,numer(p)) end_for;
  if iszero(g) then error("gcd=0!") end_if;
  geoprover::add_ndg(g);
  map(u,x->normal(x*l/g)); 
end_proc:

// ====================================================================
// ================= elementary geometric constructions =============== 
// ====================================================================

// Generators:

geoprover::is_equal:=proc(a,b) begin normal(a-b) end_proc:

geoprover::Point:=proc(a,b):geoprover::DOM_POINT
begin [normal(a),normal(b)] end_proc:

geoprover::Line:=proc(a,b,c):geoprover::DOM_LINE
begin geoprover::reduce_coords([normal(a),normal(b),normal(c)]) 
end_proc:

geoprover::par_point:= 
proc(a:geoprover::DOM_POINT, b:geoprover::DOM_POINT,
      c:geoprover::DOM_POINT):geoprover::DOM_POINT 
// Point D that makes ABCD a parallelogram.
begin geoprover::Point(c[1]-b[1]+a[1], c[2]-b[2]+a[2]) 
end_proc:

geoprover::pp_line:=
proc(a:geoprover::DOM_POINT,b:geoprover::DOM_POINT):geoprover::DOM_LINE
// the line through A and B 
begin 
  geoprover::Line(b[2]-a[2],a[1]-b[1],
  a[2]*b[1]-a[1]*b[2]) 
end_proc:

geoprover::intersection_point:=
proc(a:geoprover::DOM_LINE,b:geoprover::DOM_LINE):geoprover::DOM_POINT
// The intersection point of the lines a,b.
   local d,d1,d2;
begin
   d:=normal(a[1]*b[2]-b[1]*a[2]);
   d1:=a[3]*b[2]-b[3]*a[2];
   d2:=a[1]*b[3]-b[1]*a[3];
   if iszero(d) then error("Lines are parallel") end_if;
   geoprover::add_ndg(numer(d));
   geoprover::Point(-d1/d,-d2/d);
end_proc:

geoprover::ortho_line:=
proc(p:geoprover::DOM_POINT,a:geoprover::DOM_LINE):geoprover::DOM_LINE
// The ortho_line from P onto the line a.
  local u,v;
begin
  u:=a[1]; v:=a[2];
  geoprover::Line(v,-u,u*p[2]-v*p[1]);
end_proc:

geoprover::par_line:=
proc(P:geoprover::DOM_POINT,a:geoprover::DOM_LINE):geoprover::DOM_LINE
// The parallel line to line a through P.
begin
  geoprover::Line(a[1],a[2],-(a[1]*P[1]+a[2] *P[2])) 
end_proc:

geoprover::varpoint:=
proc(b:geoprover::DOM_POINT,a:geoprover::DOM_POINT,l):geoprover::DOM_POINT
// The point D=l*A+(1-l)*B.
begin
  geoprover::Point(l*a[1]+(1-l)*b[1],l*a[2]+(1-l)*b[2]) 
end_proc:

geoprover::line_slider:=proc(a:geoprover::DOM_LINE,u):geoprover::DOM_POINT
// Choose a point on the line a using parameter u.
  local p,d;
begin
  if iszero(a[2]) then 
	if iszero(a[1]) then error("Line is degenerate") end_if;
	p:=geoprover::Point(-a[3]/a[1],u); d:=a[1]; 
  else 	
	p:=geoprover::Point(u,-(a[3]+a[1]*u)/a[2]);
	d:=a[2]; 
  end_if;
  geoprover::add_ndg(numer(d));
  p;
end_proc:

geoprover::sqrdist:=proc(a:geoprover::DOM_POINT,b:geoprover::DOM_POINT)
// The square of the distance between the points A and B.
begin  
  normal((b[1]-a[1])^2+(b[2]-a[2])^2) 
end_proc:

geoprover::eq_dist:=proc(a:geoprover::DOM_POINT,b:geoprover::DOM_POINT,
	c:geoprover::DOM_POINT,d:geoprover::DOM_POINT)
// distances AB and CD are equal.
begin  
  normal(geoprover::sqrdist(a,b)-geoprover::sqrdist(c,d)) 
end_proc:

// =================================================================
// ================= elementary geometric properties ===============
// =================================================================

geoprover::is_collinear:=
proc(a:geoprover::DOM_POINT,b:geoprover::DOM_POINT,c:geoprover::DOM_POINT)
// A,B,C are on a common line.
begin
  normal(linalg::det(Dom::Matrix()(
		   [[a[1],a[2],1],
		    [b[1],b[2],1],
		    [c[1],c[2],1]]))) 
end_proc:

geoprover::is_concurrent:=
proc(a:geoprover::DOM_LINE,b:geoprover::DOM_LINE,c:geoprover::DOM_LINE)
// Lines a,b,c have a common point.
begin
  normal(linalg::det(Dom::Matrix()(
	[[a[1],a[2],a[3]],
	 [b[1],b[2],b[3]],
	 [c[1],c[2],c[3]]]))) 
end_proc:

geoprover::is_parallel:=proc(a:geoprover::DOM_LINE,b:geoprover::DOM_LINE)
// 0 <=> the lines a,b are parallel.
begin  
  normal(a[1]*b[2]-b[1]*a[2]) 
end_proc:

geoprover::is_orthogonal:=proc(a:geoprover::DOM_LINE,b:geoprover::DOM_LINE)
// 0 <=> the lines a,b are orthogonal.
begin
  normal(a[1]*b[1]+a[2]*b[2]) 
end_proc:

geoprover::on_line:=proc(p:geoprover::DOM_POINT,a:geoprover::DOM_LINE)
// Substitute point P into the line a.
begin  
  normal(p[1]*a[1]+p[2]*a[2]+a[3]) 
end_proc:

// ================================================================
// ================= nonlinear geometric objects ==================
// ================================================================

// ====================== angles ==================================

geoprover::l2_angle:=proc(a:geoprover::DOM_LINE,b:geoprover::DOM_LINE)
// tan of the angle between the lines a and b.
  local d; 
begin
  d:=normal(a[1]*b[1]+a[2]*b[2]); 
  if iszero(d) then error("tan is indefinite") end_if;
  geoprover::add_ndg(numer(d));
  normal((a[2]*b[1]-b[2]*a[1])/d);
end_proc:

geoprover::p3_angle:=
proc(A:geoprover::DOM_POINT,B:geoprover::DOM_POINT,C:geoprover::DOM_POINT)
// tan of the angle between the lines BA and BC
begin  
  geoprover::l2_angle(geoprover::pp_line(B,A),geoprover::pp_line(B,C)) 
end_proc:

geoprover::angle_sum:=proc(a,b)
// a=tan(\alpha), b=tan(\beta). Returns tan(\alpha+\beta)
  local d;
begin 
  d:=normal(1-a*b); geoprover::add_ndg(numer(d)); 
  if iszero(d) then error("tan is indefinite") end_if;
  normal((a+b)/d);
end_proc:

geoprover::eq_angle:=
proc(a:geoprover::DOM_POINT,b:geoprover::DOM_POINT,c:geoprover::DOM_POINT,
	d:geoprover::DOM_POINT,e:geoprover::DOM_POINT,f:geoprover::DOM_POINT)
// Angles ABC and DEF are equal.
begin 
  numer(normal(geoprover::p3_angle(a,b,c)-geoprover::p3_angle(d,e,f))) 
end_proc:

geoprover::rotate:= 
proc(C:geoprover::DOM_POINT, A:geoprover::DOM_POINT, angle)
begin
  geoprover::Point(
    C[1]+(A[1]-C[1])*cos(angle*PI)-(A[2]-C[2])*sin(angle*PI),
    C[2]+(A[1]-C[1])*sin(angle*PI)+(A[2]-C[2])*cos(angle*PI)) 
end_proc:

// ================ symmetric lines and points ====================

geoprover::sym_line:=
proc(a:geoprover::DOM_LINE,l:geoprover::DOM_LINE):geoprover::DOM_LINE
// The line symmetric to a wrt. the line l.
  local a1,a2,a3,l1,l2,l3,u;
begin
  a1:=a[1]; a2:=a[2]; a3:=a[3]; 
  l1:=l[1]; l2:=l[2]; l3:=l[3]; 
  u:=normal(l1^2 - l2^2);
  geoprover::Line(- a1*u - 2*a2*l1*l2, - 2*a1*l1*l2 + a2*u, 
		- 2*(a1*l1 + a2*l2)*l3 + a3*(l1^2 + l2^2));
end_proc:

// ================================================================
// ====================== circles =================================
// ================================================================

geoprover::circle_slider:=
proc(M:geoprover::DOM_POINT,A:geoprover::DOM_POINT,u):geoprover::DOM_POINT
  local d,a1,a2,m1,m2; 
begin a1:=A[1]; a2:=A[2]; m1:=M[1]; m2:=M[2];
  d:=normal(u^2+1); geoprover::add_ndg(numer(d));
  geoprover::Point((a1*(u^2-1) + 2*m1 + 2*(m2-a2)*u)/d, 
	 (a2 + 2*(m1-a1)*u + (2*m2-a2)*u^2)/d);
end_proc:

geoprover::Circle:=proc(c1,c2,c3,c4):geoprover::DOM_CIRCLE
begin
  geoprover::reduce_coords([normal(c1),normal(c2),normal(c3),normal(c4)])
end_proc:

geoprover::pc_circle:=
proc(M:geoprover::DOM_POINT,A:geoprover::DOM_POINT):geoprover::DOM_CIRCLE
// Circle from center M and circumfere point A.
begin  
 geoprover::Circle(1, -2*M[1], -2*M[2],
    A[1]*(2*M[1]-A[1]) + A[2]*(2*M[2]-A[2]))
end_proc:

geoprover::circle_center:=proc(c:geoprover::DOM_CIRCLE):geoprover::DOM_POINT
// The center of the circle c.
begin  
  geoprover::add_ndg(numer(c[1]));
  geoprover::Point(-c[2]/2/c[1] ,-c[3]/(2*c[1]));
end_proc:

geoprover::circle_sqradius:=proc(c:geoprover::DOM_CIRCLE)
// The squared radius of the circle c.
begin
  geoprover::add_ndg(numer(c[1]));
  normal(((c[2]^2+c[3]^2) - 4*c[4]*c[1]) / 
	(2*c[1])^2);
end_proc:

geoprover::on_circle:=proc(P:geoprover::DOM_POINT,c:geoprover::DOM_CIRCLE)
// Checks if P is on circle c  
local p1,p2; 
begin
  p1:=P[1]; p2:=P[2];
  normal(c[1]*(p1^2+p2^2)+c[2]*p1+c[3]*p2+c[4]);
end_proc:

// ============= intersecting with circles ========================

geoprover::other_cl_point:=
proc(P:geoprover::DOM_POINT,c:geoprover::DOM_CIRCLE,
	l:geoprover::DOM_LINE):geoprover::DOM_POINT
// circle c and line l intersect at P. The procedure returns their
// second intersection point.
  local c1,c2,c3,l1,l2,d,d1,p1,p2;
begin
  if not iszero(geoprover::on_line(P,l)) then error( "Point not on the line")
  elif not iszero(geoprover::on_circle(P,c)) then 
	error( "Point not on the circle")
  else 
     c1:=c[1]; c2:=c[2]; c3:=c[3]; 
     l1:=l[1]; l2:=l[2]; p1:=P[1]; p2:=P[2];
     d:=normal(c1*(l1^2 + l2^2));
	if iszero(d) then error("circle or line degenerate") end_if;
     geoprover::add_ndg(numer(d)); 
     d1:=normal(c1*(l1^2-l2^2));
     geoprover::Point((d1*p1+((2*c1*p2 + c3)*l1-c2*l2)*l2)/d, 
	  (- d1*p2+((2*c1*p1 + c2)*l2-c3*l1)*l1)/d);
  end_if
end_proc:

geoprover::radical_axis:=proc(c1:geoprover::DOM_CIRCLE,
	c2:geoprover::DOM_CIRCLE):geoprover::DOM_LINE
// Radical axis of the circles c1 and c2, i.e. the line through the
// intersection points of the two circles if they intersect. 
  local i;
begin 
  geoprover::Line(normal(c1[1]*c2[i]-c1[i]*c2[1])$i=2..4 ); 
end_proc:

geoprover::is_cl_tangent:=
proc(c:geoprover::DOM_CIRCLE,l:geoprover::DOM_LINE)
// Line l is tangent to the circle c.
  local c1,c2,c3,c4,l1,l2,l3;
begin
  c1:=c[1]; c2:=c[2]; c3:=c[3]; c4:=c[4]; 
  l1:=l[1]; l2:=l[2]; l3:=l[3]; 
  normal(4*c1*( (- c1*l3 + c2*l1 + c3*l2)*l3 - c4*(l1^2 + l2^2))  
	+ (c2*l2 - c3*l1)^2); 
end_proc:

geoprover::tangent_line:=
proc(P:geoprover::DOM_POINT,c:geoprover::DOM_CIRCLE) 
// tangent line through a Point P on the circle c.
begin
  if not iszero(geoprover::on_circle(P,c)) then 
	error("Point not on the circle") end_if;
  geoprover::Line(2*c[1]*P[1]+c[2], 2*c[1]*P[2]+c[3],
		c[2]*P[1]+c[3]*P[2]+2*c[4]);
end_proc:

// =========GeoProver's undocumented Plot addendum ============

/*

geo_plot(Options ..., Scenes ...)

Options == usual MuPAD plot options.

Scene ==  [List of GeoProver objects, range <,Color>]

*/

geoprover::geo_plot:=proc()
  local sceneopt, j, obj_seq;
begin
  sceneopt:= Axes = None, Scaling = Constrained, 
	     select(args(),testtype,"_equal");
  obj_seq:=select(args(),testtype,DOM_LIST);
  obj_seq:=map(obj_seq,op@geoprover::plot1@op);
  plot::Scene2d(sceneopt, obj_seq) 
end_proc:

geoprover::plot1:=proc(Objects:DOM_LIST,
        Range:"_equal",color=(Color=RGB::Black))
begin
  map(Objects,geoprover::plot2,Range,color);
end_proc:

geoprover::plot2:=proc(geo_obj:DOM_LIST,range,color)
begin
  if nops(geo_obj)=2 then
	geoprover::plot_point(geo_obj,color);
  elif nops(geo_obj)=3 then
	geoprover::plot_line(geo_obj,range,color);
  else
	if iszero(geo_obj[1]) then
		geoprover::plot_line([geo_obj[2..4]],range,color);
	else
		geoprover::plot_circle(geo_obj,color);
	end_if;
  end_if;
end_proc:

geoprover::plot_point:=proc(o:geoprover::DOM_POINT,c)
begin plot::Point2d(o,c) end_proc:

geoprover::plot_line:=proc(l:geoprover::DOM_LINE,r,c)
  local rhs;
begin
  rhs:=r[2];
  if iszero(l[2]) then
     plot::Line2d( [-l[3]/l[1],rhs[1]],[-l[3]/l[1],rhs[2]], c);
  else plot::Function2d(-(l[1]*x+l[3])/l[2],x=rhs,ViewingBoxYRange=rhs,c);
  end_if;
end_proc:

geoprover::plot_circle:=proc(p:geoprover::DOM_LINE,c)
  local M,r;
begin 
  M:=geoprover::circle_center(p);
  r:=geoprover::circle_sqradius(p);
  if bool(r<0) then error("Circle has negative sqradius") end_if; 
  r:=float(sqrt(r)); plot::Circle2d(r,M,c);
end_proc:

// =========Some more undocumented features ============

geoprover::toDegree:=proc(a)
// convert tan to degree
begin float(arctan(a)*180/PI) end_proc;


// GeoProver code generated from database 

geoprover::altitude:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_LINE
begin
geoprover::ortho_line(_A,geoprover::pp_line(_B,_C))
end_proc:

geoprover::centroid:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_POINT
begin
geoprover::intersection_point(geoprover::median(_A,_B,_C),geoprover::median(_B,_C,_A))
end_proc:

geoprover::circumcenter:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_POINT
begin
geoprover::intersection_point(geoprover::p_bisector(_A,_B),geoprover::p_bisector(_B,_C))
end_proc:

geoprover::csym_point:=
proc(_P:geoprover::DOM_POINT,_Q:geoprover::DOM_POINT):geoprover::DOM_POINT
begin
geoprover::varpoint(_Q,_P,-1)
end_proc:

geoprover::fixedpoint:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_u):geoprover::DOM_POINT
begin
geoprover::varpoint(_A,_B,_u)
end_proc:

geoprover::is_cc_tangent:=
proc(_c1:geoprover::DOM_CIRCLE,_c2:geoprover::DOM_CIRCLE)
begin
geoprover::is_cl_tangent(_c1,geoprover::radical_axis(_c1,_c2))
end_proc:

geoprover::is_concyclic:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT,_D:geoprover::DOM_POINT)
begin
geoprover::on_circle(_D,geoprover::p3_circle(_A,_B,_C))
end_proc:

geoprover::median:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_LINE
begin
geoprover::pp_line(_A,geoprover::midpoint(_B,_C))
end_proc:

geoprover::midpoint:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT):geoprover::DOM_POINT
begin
geoprover::fixedpoint(_A,_B,1/2)
end_proc:

geoprover::on_bisector:=
proc(_P:geoprover::DOM_POINT,_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT)
begin
geoprover::eq_angle(_A,_B,_P,_P,_B,_C)
end_proc:

geoprover::orthocenter:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_POINT
begin
geoprover::intersection_point(geoprover::altitude(_A,_B,_C),geoprover::altitude(_B,_C,_A))
end_proc:

geoprover::other_cc_point:=
proc(_P:geoprover::DOM_POINT,_c1:geoprover::DOM_CIRCLE,_c2:geoprover::DOM_CIRCLE):geoprover::DOM_POINT
begin
geoprover::other_cl_point(_P,_c1,geoprover::radical_axis(_c1,_c2))
end_proc:

geoprover::other_incenter:=
proc(_M:geoprover::DOM_POINT,_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT):geoprover::DOM_POINT
begin
geoprover::intersection_point(geoprover::ortho_line(_A,geoprover::pp_line(_M,_A)),geoprover::ortho_line(_B,geoprover::pp_line(_M,_B)))
end_proc:

geoprover::p3_angle:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT)
begin
geoprover::l2_angle(geoprover::pp_line(_B,_A),geoprover::pp_line(_B,_C))
end_proc:

geoprover::p3_circle:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_CIRCLE
begin
geoprover::pc_circle(geoprover::intersection_point(geoprover::p_bisector(_A,_B),geoprover::p_bisector(_A,_C)),_A)
end_proc:

geoprover::p9_center:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_POINT
begin
geoprover::circle_center(geoprover::p9_circle(_A,_B,_C))
end_proc:

geoprover::p9_circle:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_CIRCLE
begin
geoprover::p3_circle(geoprover::midpoint(_A,_B),geoprover::midpoint(_A,_C),geoprover::midpoint(_B,_C))
end_proc:

geoprover::p_bisector:=
proc(_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT):geoprover::DOM_LINE
begin
geoprover::ortho_line(geoprover::midpoint(_B,_C),geoprover::pp_line(_B,_C))
end_proc:

geoprover::pappus_line:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT,_D:geoprover::DOM_POINT,_E:geoprover::DOM_POINT,_F:geoprover::DOM_POINT):geoprover::DOM_LINE
begin
geoprover::pp_line(geoprover::intersection_point(geoprover::pp_line(_A,_E),geoprover::pp_line(_B,_D)),geoprover::intersection_point(geoprover::pp_line(_A,_F),geoprover::pp_line(_C,_D)))
end_proc:

geoprover::pedalpoint:=
proc(_P:geoprover::DOM_POINT,_a:geoprover::DOM_LINE):geoprover::DOM_POINT
begin
geoprover::intersection_point(geoprover::ortho_line(_P,_a),_a)
end_proc:

geoprover::sqrdist_pl:=
proc(_A:geoprover::DOM_POINT,_l:geoprover::DOM_LINE)
begin
geoprover::sqrdist(_A,geoprover::pedalpoint(_A,_l))
end_proc:

geoprover::sym_point:=
proc(_P:geoprover::DOM_POINT,_l:geoprover::DOM_LINE):geoprover::DOM_POINT
begin
geoprover::fixedpoint(_P,geoprover::pedalpoint(_P,_l),2)
end_proc:

geoprover::triangle_area:=
proc(_A:geoprover::DOM_POINT,_B:geoprover::DOM_POINT,_C:geoprover::DOM_POINT)
begin
1/2*geoprover::is_collinear(_A,_B,_C)
end_proc:

// GeoProver code end.
