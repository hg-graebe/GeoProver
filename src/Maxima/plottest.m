/* Test file for geo_plot and Maxima */

load(functs);
batchload("GeoProver.m");
clear_ndg();

geo_plot(u):=
   if is(part(u,0)="[") then map(geo_plot,flatten(u))
   elseif is(part(u,0)='Polygon) then plotpolygon(u)
   elseif is(part(u,0)='TP) then plotpoint(u)
   elseif is(part(u,0)='TL) then plotline(u)
   elseif is(part(u,0)='TC) then plotcircle(u)
   else error(u, "invalid as input");

plotpoint(u):=[discrete, [part(u,1)], [part(u,2)]];
plotpolygon(u):=[discrete,
  makelist(part(u,k,1),k,1,length(u)),
  makelist(part(u,k,2),k,1,length(u))];
plotline(u):=block([a:part(u,1),b:part(u,2),c:part(u,3)],
  if b=0 then [parametric, -c/a, t, [t,-100,100]]
  else -(a*x+c)/b) ;
plotcircle(u):=block(
  [M:circle_center(u),r:sqrt(circle_sqradius(u))],
  [parametric, r*cos(t)+part(M,1), r*sin(t)+part(M,2), [t,-%pi,%pi]]
  );
 
/* Feuerbach's circle */

/* monochrome */  

A:Point(0,0); B:Point(10,0); C:Point(4,7);
scene0:Polygon(A,B,C,A);
scene1:[pp_line(A,B), pp_line(B,C), pp_line(A,C)];
scene2:[altitude(A,B,C), altitude(B,C,A), altitude(C,A,B)];
scene3:[p_bisector(A,B), p_bisector(B,C), p_bisector(C,A)];
scene4:[median(A,B,C), median(B,C,A), median(C,A,B)];
M:intersection_point(p_bisector(A,B),p_bisector(B,C));
H:intersection_point(altitude(A,B,C),altitude(B,C,A));
N:midpoint(M,H);
scene5:[pp_line(M,H),pc_circle(N,midpoint(A,B))];

plot2d(geo_plot([scene0,scene1,scene2,scene3,scene4,scene5]),
[x,-5,15],[y,-5,10],[color,black],
[same_xy,true],[point_type,box],[legend,false]);

/* Coloured */

P1:[scene1,rg,Color=Green];   /* the triangle */
P2:[scene2,rg,Color=Red];     /* the altitudes */
P3:[scene3,rg,Color=Blue];    /* the perpendicular bisectors */
P4:[scene4,rg,Color=Magenta]; /* the median lines */
P5:[scene5,rg,Color=Black];   /* Euler's line and Feuerbach's circle */

geo_plot(TitleFont=[36],Header="Feuerbach's circle",P1,P2,P3,P4,P5);
plot(%);

pause();
 
/* bisector intersection theorem */

A:Point(0,0); B:Point(10,0); C:Point(4,6); P:Point(x1,x2); 
c:pc_circle(P,pedalpoint(P,pp_line(A,B)));
lines:[pp_line(A,P),pp_line(B,P),pp_line(C,P)];
polys:{on_bisector(P,A,B,C),on_bisector(P,B,C,A)}; 
sol:coerce(numeric::solve(polys,{x1,x2}),DOM_LIST);
 
/* the four circles */
scene1:map(sol,x->subs(c,x));
/* bisectors of the triangle */
scene2:map(map(sol,x->subs(lines,x)),op);
/* sides of the triangle */ 
scene3:[pp_line(A,B),pp_line(A,C),pp_line(B,C)];

rg; x =-12..18; 
geo_plot(TitleFont=[36],Header="Bisector intersection theorem",
[scene1,rg,Color=Blue],[scene2,rg,Color=Magenta],[scene3,rg]); 
plot(%);

pause();

/* Pappus' theorem */

A:Point(1,1); B:Point(2,2); C:varpoint(A,B,2); 
P:Point(1,0); Q:Point(2,0); R:varpoint(P,Q,3);  
scene1:[ pp_line(A,C), pp_line(P,R)];
scene2:[ pp_line(A,Q), pp_line(P,B), pp_line(A,R), pp_line(P,C),
	  pp_line(B,R), pp_line(Q,C)];  
scene3:[ pp_line(intersection_point(pp_line(A,R),pp_line(P,C)),
	  intersection_point(pp_line(B,R),pp_line(Q,C)))]; 

rg:x=-0.1..4.1; 
geo_plot(TitleFont=[36],Header="Pappus' theorem",
[scene1,rg],[scene2,rg,Color=Green],[scene3,rg,Color=Red]); 
plot(%);

pause();

/* Desargue's theorem */

A:Point(0,0); B:Point(1,0); C:Point(u5,u6); R:Point(u7,u8);
S:Point(u9,u1); T:Point(u2,x1);

polys:[is_concurrent(pp_line(A,R),pp_line(B,S),pp_line(C,T))];  
 
scene1:[A,B,C,pp_line(A,B), pp_line(A,C), pp_line(B,C)];
scene2:[R,S,T,pp_line(R,S), pp_line(R,T), pp_line(S,T)]; 
scene3:[pp_line(A,R), pp_line(B,S), pp_line(C,T)]; 
scene4:[pp_line(intersection_point(pp_line(S,T),pp_line(B,C)), 
intersection_point(pp_line(R,T),pp_line(A,C)))];

rg:x=-0.2..2.2:
all:[	[scene1,rg],		 /* triangle ABC */
	[scene2,rg,Color=Blue],	 /* triangle RST */
	[scene3,rg,Color=Green], /* the concurrent lines */
	[scene4,rg,Color=Red]]; 

s:{u1=1.4,u2=0.6,u5=0.4,u6=0.6,u7=1.2,u8=0.8,u9=0.8};
s1:op(numeric::solve(subs(polys,s),{x1}),1);

geo_plot(TitleFont=[36],Header="Desargue's theorem", op(subs(all,s,s1))); 
plot(%);

pause();

/* Brocard's Point */

A:Point(0,0); B:Point(1,0); C:Point(u1,u2);
/* coordinates
M1:intersection_point(altitude(A,A,C),p_bisector(A,B));
M2:intersection_point(altitude(B,B,A),p_bisector(B,C));
M3:intersection_point(altitude(C,C,B),p_bisector(A,C));
c1:pc_circle(M1,A);
c2:pc_circle(M2,B);
c3:pc_circle(M3,C);
P:other_cc_point(B,c1,c2);

scene1:[pp_line(A,B), pp_line(A,C), pp_line(B,C)];
scene2:[c1,c2,c3]; 

rg:x=-0.2..2.2:
all:[	[scene1,rg],		 /* triangle ABC */
	[scene2,rg,Color=Red]];	 /* Brocard's circles */

s:{u1=.3,u2=.6};
geo_plot(TitleFont=[36],Header="Brocard's Point", op(subs(all,s)));
plot(%);


/* Simon's theorem */

M:Point(0,0); A:Point(u1,0); B:circle_slider(M,A,u2);
C:circle_slider(M,A,u3); P:circle_slider(M,A,u4);
X:pedalpoint(P,pp_line(A,B)); 
Y:pedalpoint(P,pp_line(B,C)); 
Z:pedalpoint(P,pp_line(A,C)); 

scene1:[pp_line(A,B), pp_line(A,C), pp_line(B,C)];
scene2:[pp_line(X,P), pp_line(Y,P), pp_line(Z,P)]; 
scene3:[pc_circle(M,A)];
scene4:[pp_line(X,Y)];

rg:x=-1.2..1.5:
all:[ [scene1,rg], [scene2,rg,Color=Blue],
       [scene3,rg,Color=Magenta], [scene4,rg,Color=Red]];

s:{u1=1, u2=-1, u3=1.5, u4=5}:
geo_plot(TitleFont=[36],Header="Simon's theorem", op(subs(all,s)));
plot(%);

pause();
 
/* Taylor's Circle */

A:Point(u1,0); B:Point(u2,0); C:Point(0,u3);
  /* coordinates */
P:pedalpoint(A,pp_line(B,C));
Q:pedalpoint(B,pp_line(A,C));
R:pedalpoint(C,pp_line(A,B));
P1:pedalpoint(P,pp_line(A,B));
P2:pedalpoint(P,pp_line(A,C));
Q1:pedalpoint(Q,pp_line(A,B));
Q2:pedalpoint(Q,pp_line(B,C));
R1:pedalpoint(R,pp_line(A,C));
R2:pedalpoint(R,pp_line(B,C));

scene1:[pp_line(A,B), pp_line(A,C), pp_line(B,C)];
scene2:[pp_line(A,P), pp_line(B,Q), pp_line(C,R)]; 
scene3a:[pp_line(P,P1), pp_line(P,P2)];
scene3b:[pp_line(Q,Q1), pp_line(Q,Q2)];
scene3c:[pp_line(R,R1), pp_line(R,R2)];
scene3:[P1,P2,Q1,Q2,R1,R2];
scene4:[p3_circle(P1,Q1,P2)];

rg:x=-3..6:
all:[ [scene1,rg], [scene2,rg,Color=Blue],
       [scene3,rg, Color=Magenta], 
       [scene3a,rg, Color=GreenishUmber], 
       [scene3b,rg, Color=TurquoisePale], 
       [scene3c,rg, Color=TurquoiseDark], 
       [scene4,rg,Color=Red]];

s:{u1=-2, u2=4, u3=5}:
geo_plot(TitleFont=[36],Header="Taylor's Circle", op(subs(all,s)));
plot(%);

