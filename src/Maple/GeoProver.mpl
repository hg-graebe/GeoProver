#  GeoProver | Version 1.3a | 2007-02-09
#  Author: H.-G. Graebe, Univ. Leipzig, Germany
#  http://www.informatik.uni-leipzig.de/~graebe

# GeoProver interface

geoprover[altitude]:=proc() `geoprover/altitude`(args) end:
geoprover[centroid]:=proc() `geoprover/centroid`(args) end:
geoprover[circumcenter]:=proc() `geoprover/circumcenter`(args) end:
geoprover[csym_point]:=proc() `geoprover/csym_point`(args) end:
geoprover[fixedpoint]:=proc() `geoprover/fixedpoint`(args) end:
geoprover[is_cc_tangent]:=proc() `geoprover/is_cc_tangent`(args) end:
geoprover[is_concyclic]:=proc() `geoprover/is_concyclic`(args) end:
geoprover[median]:=proc() `geoprover/median`(args) end:
geoprover[midpoint]:=proc() `geoprover/midpoint`(args) end:
geoprover[on_bisector]:=proc() `geoprover/on_bisector`(args) end:
geoprover[orthocenter]:=proc() `geoprover/orthocenter`(args) end:
geoprover[other_cc_point]:=proc() `geoprover/other_cc_point`(args) end:
geoprover[other_incenter]:=proc() `geoprover/other_incenter`(args) end:
geoprover[p3_angle]:=proc() `geoprover/p3_angle`(args) end:
geoprover[p3_circle]:=proc() `geoprover/p3_circle`(args) end:
geoprover[p9_center]:=proc() `geoprover/p9_center`(args) end:
geoprover[p9_circle]:=proc() `geoprover/p9_circle`(args) end:
geoprover[p_bisector]:=proc() `geoprover/p_bisector`(args) end:
geoprover[pappus_line]:=proc() `geoprover/pappus_line`(args) end:
geoprover[pedalpoint]:=proc() `geoprover/pedalpoint`(args) end:
geoprover[sqrdist_pl]:=proc() `geoprover/sqrdist_pl`(args) end:
geoprover[sym_point]:=proc() `geoprover/sym_point`(args) end:
geoprover[triangle_area]:=proc() `geoprover/triangle_area`(args) end:
geoprover[clear_ndg]:=proc() `geoprover/clear_ndg`(args) end:
geoprover[print_ndg]:=proc() `geoprover/print_ndg`(args) end:
geoprover[add_ndg]:=proc() `geoprover/add_ndg`(args) end:
geoprover[geo_plot]:=proc() `geoprover/geo_plot`(args) end:

# GeoProver inline code Version 1.3b
# 17 Jan 2003: contains also geo_plot code
# 4 June 2003: l[i] instead of op(i,a) or part(a,i)
# 14 June 2003: 
#    other_cc_point and is_cc_tangent moved to the macro part 
#    tangent_line added
# 29 Jun 2003: on_bisector, p3_circle moved to macros

# ============= Handling non degeneracy conditions ===============

`geoprover/clear_ndg`:=proc() global `geoprover/ndg_list`; 
  `geoprover/ndg_list`:=NULL end; 

`geoprover/clear_ndg`():  # Initialization 

`geoprover/print_ndg`:=proc() global `geoprover/ndg_list`;
  print([`geoprover/ndg_list`]) end;

`geoprover/add_ndg`:=proc(d) global `geoprover/ndg_list`; 
  if not member(d,[`geoprover/ndg_list`]) then
	`geoprover/ndg_list`:=d,`geoprover/ndg_list` fi 
  end;

# ============= some algebraic manipulations ===============

`geoprover/reduce_coords`:=proc(u)
  local p,l,g,i;
  p:=u[1]; l:=denom(p); g:=numer(p);
  for i from 2 to nops(u) do 
	p:=u[i]; l:=lcm(l,denom(p)); g:=gcd(g,numer(p)) od;
  `geoprover/add_ndg`(g);
  map(x->normal(x*l/g),u); 
  end;

# ================= elementary geometric constructions ===============

# Data structures:
# 
# 	Point A  :== [a1,a2]       <=> A=(a1,a2)
# 	Line  a  :== [a1,a2,a3]    <=> a1*x+a2*y+a3 = 0
#	Circle c :== [c0,c1,c2,c3] <=> c0*(x^2+y^2)+c1*x+c2*y+c3 = 0

`type/Point`:=list;
`type/Line`:=list;
`type/Circle`:=list;
`type/Scalar`:=anything;
`type/Boolean`:=anything;

`geoprover/is_equal`:=proc(a,b) normal(a-b) end;

`geoprover/Point`:=proc(a,b) [normal(a),normal(b)] end;
`geoprover/Line`:=proc(a,b,c) 
  `geoprover/reduce_coords`([normal(a),normal(b),normal(c)]) end;

`geoprover/par_point`:=proc(a::Point,b::Point,c::Point)
  `geoprover/Point`(c[1]-b[1]+a[1], c[2]-b[2]+a[2]) end;

`geoprover/pp_line`:=proc(a::Point,b::Point)
  `geoprover/Line`(b[2]-a[2],a[1]-b[1],
	a[2]*b[1]-a[1]*b[2]) end; 

`geoprover/intersection_point`:=proc(a::Line,b::Line)
   local d,d1,d2;
   d:=normal(a[1]*b[2]-b[1]*a[2]);
   d1:=a[3]*b[2]-b[3]*a[2];
   d2:=a[1]*b[3]-b[1]*a[3];
   if d=0 then ERROR("Lines are parallel") fi;
   `geoprover/add_ndg`(numer(d));
   `geoprover/Point`(-d1/d,-d2/d);
   end;

`geoprover/ortho_line`:=proc(p::Point,a::Line)
  local u,v; u:=a[1]; v:=a[2];
  `geoprover/Line`(v,-u,u*p[2]-v*p[1]);
  end;

`geoprover/par_line`:=proc(P::Point,a::Line)
  `geoprover/Line`(a[1],a[2],
	-(a[1]*P[1]+a[2] *P[2])) end;

`geoprover/varpoint`:=proc(b::Point,a::Point,l)
  `geoprover/Point`(l*a[1]+(1-l)*b[1],
	l*a[2]+(1-l)*b[2]) end;

`geoprover/line_slider`:=proc(a::Line,u)
  local p,d;
  if a[2]=0 then 
	p:=`geoprover/Point`(-a[3]/a[1],u); d:=a[1]; 
  else 	
	p:=`geoprover/Point`(u,-(a[3]+a[1]*u)/a[2]);
	d:=a[2]; 
  fi;
  `geoprover/add_ndg`(numer(d));
  p;
  end;

`geoprover/sqrdist`:=proc(a::Point,b::Point)
  normal((b[1]-a[1])^2+(b[2]-a[2])^2) end;

`geoprover/is_collinear`:=proc(a::Point,b::Point,c::Point)
linalg[det](linalg[matrix](
	[[a[1],a[2],1],
	[b[1],b[2],1],
	[c[1],c[2],1]])) end;

`geoprover/is_concurrent`:=proc(a::Line,b::Line,c::Line)
linalg[det](linalg[matrix](
	[[a[1],a[2],a[3]],
	[b[1],b[2],b[3]],
	[c[1],c[2],c[3]]])) end;

`geoprover/is_parallel`:=proc(a::Line,b::Line)
  normal(a[1]*b[2]-b[1]*a[2]) end;

`geoprover/is_orthogonal`:=proc(a::Line,b::Line)
  normal(a[1]*b[1]+a[2]*b[2]) end;

`geoprover/on_line`:=proc(p::Point,a::Line)
  normal(p[1]*a[1]+p[2]*a[2]+a[3]) end;

`geoprover/eq_dist`:=proc(a::Point,b::Point,c::Point,d::Point)
  normal(`geoprover/sqrdist`(a,b)-`geoprover/sqrdist`(c,d)) end;

# ===================== angles ================ 

`geoprover/l2_angle`:=proc(a::Line,b::Line)
  local d; d:=normal(a[1]*b[1]+a[2]*b[2]); 
  `geoprover/add_ndg`(numer(d));
  normal((a[2]*b[1]-b[2]*a[1])/d);
  end;

`geoprover/angle_sum`:=proc(a,b)
  local d; d:=normal(1-a*b); `geoprover/add_ndg`(numer(d)); 
  normal((a+b)/d);
  end;

`geoprover/eq_angle`:=
proc(a::Point,b::Point,c::Point,d::Point,e::Point,f::Point)
  normal(`geoprover/p3_angle`(a,b,c)-`geoprover/p3_angle`(d,e,f)) 
end;

`geoprover/sym_line`:=proc(a::Line,l::Line)
  local a1,a2,a3,l1,l2,l3,u;
  a1:=a[1]; a2:=a[2]; a3:=a[3]; 
  l1:=l[1]; l2:=l[2]; l3:=l[3]; 
  u:=normal(l1^2 - l2^2);
  `geoprover/Line`(- a1*u - 2*a2*l1*l2, - 2*a1*l1*l2 + a2*u, 
		- 2*(a1*l1 + a2*l2)*l3 + a3*(l1^2 + l2^2));
  end;

`geoprover/rotate` := proc(C::Point, A::Point, angle)
  `geoprover/Point`(
    C[1]+(A[1]-C[1])*cos(angle*Pi)-(A[2]-C[2])*sin(angle*Pi),
    C[2]+(A[1]-C[1])*sin(angle*Pi)+(A[2]-C[2])*cos(angle*Pi)) 
  end:

# ===================== circles ================ 

`geoprover/circle_slider`:=proc(M::Point,A::Point,u)
  local d,a1,a2,m1,m2; 
  a1:=A[1]; a2:=A[2]; m1:=M[1]; m2:=M[2];
  d:=normal(u^2+1); `geoprover/add_ndg`(numer(d));
  `geoprover/Point`((a1*(u^2-1) + 2*m1 + 2*(m2-a2)*u)/d, 
	 (a2 + 2*(m1-a1)*u + (2*m2-a2)*u^2)/d);
  end;

`geoprover/Circle`:=proc(c1,c2,c3,c4)
  `geoprover/reduce_coords`([normal(c1),normal(c2),normal(c3),normal(c4)]) 
end;

`geoprover/pc_circle`:=proc(M::Point,A::Point) 
  `geoprover/Circle`(1, -2*M[1], -2*M[2], 
	A[1]*(2*M[1]-A[1]) + A[2]*(2*M[2]-A[2])) end;

`geoprover/circle_center`:=proc(c::Circle)
  `geoprover/add_ndg`(numer(c[1]));
  `geoprover/Point`(-c[2]/2/c[1] ,-c[3]/(2*c[1]));
  end;

`geoprover/circle_sqradius`:=proc(c::Circle)
  `geoprover/add_ndg`(numer(c[1]));
  normal(((c[2]^2+c[3]^2) - 4*c[4]*c[1]) / 
	(2*c[1])^2);
  end;

`geoprover/on_circle`:=proc(P::Point,c::Circle)
  local p1,p2; p1:=P[1]; p2:=P[2];
  normal(c[1]*(p1^2+p2^2)+c[2]*p1+c[3]*p2+c[4]);
  end;

`geoprover/other_cl_point`:=proc(P::Point,c::Circle,l::Line)
  local c1,c2,c3,l1,l2,d,d1,p1,p2;
  if `geoprover/on_line`(P,l) <> 0 then 
     ERROR( "Point not on the line") 
  elif `geoprover/on_circle`(P,c) <> 0 then 
	ERROR( "Point not on the circle")
  else 
  c1:=c[1]; c2:=c[2]; c3:=c[3]; 
  l1:=l[1]; l2:=l[2]; p1:=P[1]; p2:=P[2];
  d:=normal(c1*(l1^2 + l2^2)); `geoprover/add_ndg`(numer(d)); 
  d1:=normal(c1*(l1^2-l2^2));
  `geoprover/Point`((d1*p1+((2*c1*p2 + c3)*l1-c2*l2)*l2)/d, 
	(- d1*p2+((2*c1*p1 + c2)*l2-c3*l1)*l1)/d);
  fi end;

`geoprover/radical_axis`:=proc(c1::Circle,c2::Circle)
  `geoprover/Line`(seq(normal(c1[1]*c2[i]
	-c1[i]*c2[1]), i=2..4 )); 
  end;

`geoprover/is_cl_tangent`:=proc(c::Circle,l::Line)
  local c1,c2,c3,c4,l1,l2,l3;
  c1:=c[1]; c2:=c[2]; c3:=c[3]; c4:=c[4]; 
  l1:=l[1]; l2:=l[2]; l3:=l[3]; 
  normal(4*c1*( (- c1*l3 + c2*l1 + c3*l2)*l3 - c4*(l1^2 + l2^2))  
	+ (c2*l2 - c3*l1)^2); 
  end;

`geoprover/tangent_line`:=proc(P::Point,c::Circle) 
  if `geoprover/on_circle`(P,c)<>0 then 
	ERROR("Point not on the circle") fi;
  `geoprover/Line`(2*c[1]*P[1]+c[2], 2*c[1]*P[2]+c[3],
		c[2]*P[1]+c[3]*P[2]+2*c[4]);
end;

##### Implementation of (undocumented) geo_plot #####

`geoprover/geo_plot`:=proc()		
  # args[1] is a list of _specified_ geometric objects to be plotted. 
  # args[2] is a range "x=a..b"
  # args[3] is an optional color entry "color=<color>"
  local p1,p2,u,v,c; 
  u:=args[1]; v:=args[2]; 
  if not (type(v,equation) and type(rhs(v),range)) then 
	ERROR("second argument must be <var> = <a> .. <b>") fi;
  if nargs<3 then c:=(color=black) else 
      c:=args[3]; if not (type(c,equation) and lhs(c)='color') then  
	  ERROR("third argument must be color = <color>") fi;
      fi;
  p1:=map(geo_plot1,u,v,c);	
	# a list of PLOTs with local color entries 
  `plots/display`(p1);
  end;

geo_plot1:=proc(p,rg,c) local u,c1,c2; 
  # plot a single object with color c
  if nops(p)=2			# p is a Point
	then u:=geo_plot_point(p,c)
  elif nops(p)=3		# p is a Line
	then u:=geo_plot_line(p,rg,c)
  elif p[1]=0		# p is a degenerated Circle
	then u:=geo_plot_line([p[2..4]],rg,c)
  else u:=geo_plot_circle(p,c) fi; 
  c1:=select(x->x[0]='COLOUR',[op(u)]);
  c2:=select(x->x[0]<>'COLOUR',[op(2..nops(u),u)]);
  PLOT(CURVES(u[1,1],op(c1)),op(c2),VIEW(rhs(rg),rhs(rg)))
end;

geo_plot_point:=proc(p,c) local t; 
  plot([p[1]*t,p[2]*t,t=1..1],c) end;

geo_plot_line:=proc(p,range,c) local t; t:=range[1];
  if p[2]=0 then plot([-p[3]/p[1],t,range],c) 
  else plot([t,-(p[1]*t+p[3])/p[2],range],c) fi end;

geo_plot_circle:=proc(p,c) local t,M,r; 
  M:=`geoprover/circle_center`(p); 
  r:=sqrt(`geoprover/circle_sqradius`(p));
  plot([M[1]+r*sin(Pi*t/100.),M[2]+r*cos(Pi*t/100.),t=-100..100],c) 
  end; 

# Output as Maplet

geo_mplot := proc (uhu)
Maplets[Display](Maplets:-Elements:-Maplet([Maplets:-Elements:-Plotter(uhu),
Maplets:-Elements:-Button("OK",Maplets:-Elements:-Shutdown())]))
end proc;

# GeoProver code generated from database 


# GeoProver code end.
