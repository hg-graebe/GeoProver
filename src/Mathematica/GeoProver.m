(*  GeoProver | Version 1.3a | 2007-02-09 *)
(*  Author: H.-G. Graebe, Univ. Leipzig, Germany *)
(*  http://www.informatik.uni-leipzig.de/~graebe *)

BeginPackage["GeoProver`"]

(* GeoProver usage *)

::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
::usage:="";
clearndg::usage:="degeneracy tracing";
printndg::usage:="degeneracy tracing";
addndg::usage:="degeneracy tracing";

(* GeoProver Inline part Version 1.3b  *)
(* with undocumented plot addendum *)
(*
  
Changes:

14 Jun 2003: other_cc_point and is_cc_tangent moved to macro  
	     tangent_line added
29 Jun 2003: on_bisector, p3_circle moved to macro

*)

intersectionpoint::prll:="Lines are isparallel"
otherclpoint::pnol:="Point is not on the line."
otherclpoint::pnoc:="Point is not on the circle."
tangentline::pnoc:="Point is not on the circle."

geoplot::usage:=
  "Plots the defined geometric objects. The first argument is a list of \
objects to be plotted together. For each object a color can be chosen by \
specifying the object as a list of the object itself together with the \
Mathematica grafic primitive RGBColor" 
geoplot::wrga:="Wrong argument in plotting list"

Begin["Private`"] 

det3=Det[{{a11,a12,a13},{a21,a22,a23},{a31,a32,a33}}]
(*Accelarates computation of iscollinear and isconcurrent*) 
 
(*Handling non degeneracy conditions*)

clearndg[]:=ndglist={};

printndg[]:=Print[ndglist];

addndg[d_]:=
  Module[{tmplist},tmplist=ndglist;
    If[!MemberQ[tmplist,d],ndglist=Append[tmplist,d]]]

reduceCoords[u_]:=Module[{p,l,g,i,x},
  p=Part[u,1]; l=Denominator[p]; g=Numerator[p]; 
    For[i=2,i<=Length[u],i++,
      p=Part[u,i]; 
      l=PolynomialLCM[l,Denominator[p]]; 
      g=PolynomialGCD[g,Numerator[p]]];
  addndg[g];
  u/.x_->Together[x*l/g]]

clearndg[]  (* Initialization *)

(* How geometric objects should be formatted on output *)

Format[GPPoint[A___]]:={A}
Format[GPLine[A___]]:={A}
Format[GPCircle[A___]]:={A}

(* elementary geometric constructions *)

(* Generators *)

point[a_,b_]:=GPPoint@@Together/@{a,b};

line[a_,b_,c_]:=GPLine@@(Together/@{a,b,c}//reduceCoords); 

isequal[a_,b_]:=(a-b)//Together;

parpoint[a_GPPoint,b_GPPoint,c_GPPoint]:= 
  point[Part[a,1]-Part[b,1]+Part[c,1], Part[a,2]-Part[b,2]+Part[c,2]]

ppline[a_GPPoint,b_GPPoint]:=
  line[Part[b,2]-Part[a,2],Part[a,1]-Part[b,1],
    Part[a,2]*Part[b,1]-Part[a,1]*Part[b,2]]

intersectionpoint[a_GPLine,b_GPLine]:= Module[{d,d1,d2,p},
  d=Together[Part[a,1]*Part[b,2]-Part[b,1]*Part[a,2]];	
  d1=Part[a,3]*Part[b,2]-Part[b,3]*Part[a,2];
  d2=Part[a,1]*Part[b,3]-Part[b,1]*Part[a,3];
  If[d===0, Message[intersectionpoint::prll];Return[]];
  addndg[Numerator[d]];
  point[-d1/d,-d2/d]]					

ortholine[p_GPPoint,a_GPLine]:= Module[{u,v},
  u=Part[a,1];v=Part[a,2];
  line[v,-u,u*Part[p,2]-v*Part[p,1]]]

parline[p_GPPoint,a_GPLine]:=
  line[Part[a,1],Part[a,2],-(Part[a,1]*Part[p,1]+Part[a,2]*Part[p,2])]

varpoint[b_GPPoint,a_GPPoint,l_]:=
  point[l*Part[a,1]+(1-l)*Part[b,1],l*Part[a,2]+(1-l)*Part[b,2]]

lineslider[a_GPLine,u_]:= Module[{p,d},
  If[Part[a,2]===0,p=point[-Part[a,3]/Part[a,1],u]; 
      d=Part[a,1], p=point[u,-(Part[a,3]+Part[a,1]*u)/Part[a,2]]; 
      d=Part[a,2]];
  addndg[Numerator[d]];
  p]

sqrdist[a_GPPoint,b_GPPoint]:=
  Together[(Part[b,1]-Part[a,1])^2+(Part[b,2]-Part[a,2])^2]

(*elementary geometric properties*)

iscollinear[a_GPPoint,b_GPPoint,c_GPPoint]:=
	Together[det3/.{a11->Part[a,1],a12->Part[a,2],a13->1,
	a21->Part[b,1],a22->Part[b,2],a23->1,
	a31->Part[c,1],a32->Part[c,2],a33->1}]

isconcurrent[a_GPLine,b_GPLine,c_GPLine]:=
	Together[det3/.{a11->Part[a,1],a12->Part[a,2],a13->Part[a,3],
	a21->Part[b,1],a22->Part[b,2],a23->Part[b,3],
	a31->Part[c,1],a32->Part[c,2],a33->Part[c,3]}]

isparallel[a_GPLine,b_GPLine]:=
  Together[Part[a,1]*Part[b,2]-Part[b,1]*Part[a,2]]

isorthogonal[a_GPLine,b_GPLine]:=
  Together[Part[a,1]*Part[b,1]+Part[a,2]*Part[b,2]]

online[p_GPPoint,a_GPLine]:=
  Together[Part[p,1]*Part[a,1]+Part[p,2]*Part[a,2]+Part[a,3]]

eqdist[a_GPPoint,b_GPPoint,c_GPPoint,d_GPPoint]:=
  Together[sqrdist[a,b]-sqrdist[c,d]]

(*      Non linear geometric objects                 *)

(*angles*)

l2angle[a_GPLine,b_GPLine]:= Module[{d}, 
  d:=Together[Part[a,1]*Part[b,1]+Part[a,2]*Part[b,2]]; 
  addndg[Numerator[d]];
  Together[(Part[a,2]*Part[b,1]-Part[b,2]*Part[a,1])/d]] 

p3angle[a_GPPoint,b_GPPoint,c_GPPoint]:=l2angle[ppline[b,a],ppline[b,c]] 

anglesum[a_,b_]:= Module[{d},
  d:=Together[1-a*b]; addndg[Numerator[d]]; 
  Together[(a+b)/d]]

eqangle[a_GPPoint,b_GPPoint,c_GPPoint,d_GPPoint,e_GPPoint,f_GPPoint]:=
  Together[p3angle[a,b,c]-p3angle[d,e,f]]

rotate[C_GPPoint, A_GPPoint, angle_]:= Module[{ac1,ac2},
  ac1:=Part[A,1]-Part[C,1]; ac2:=Part[A,2]-Part[C,2];
  point[Part[C,1]+ac1*Cos[angle*\[Pi]]-ac2*Sin[angle*\[Pi]],
    Part[C,2]+ac1*Sin[angle*\[Pi]]+ac2*Cos[angle*\[Pi]]]]

(*symmetric lines and points*)

symline[a_GPLine,l_GPLine]:= Module[{a1,a2,a3,l1,l2,l3,u},
  a1:=Part[a,1]; a2:=Part[a,2]; a3:=Part[a,3]; 
  l1:=Part[l,1]; l2:=Part[l,2]; l3:=Part[l,3]; 
  u:=Together[l1^2 - l2^2];
  line[- a1*u - 2*a2*l1*l2, - 2*a1*l1*l2 + a2*u, 
		- 2*(a1*l1 + a2*l2)*l3 + a3*(l1^2 + l2^2)]]

(* circles *)

circleslider[m_GPPoint,a_GPPoint,u_]:= Module[{d,a1,a2,m1,m2},
  a1:=Part[a,1]; a2:=Part[a,2];
  m1:=Part[m,1]; m2:=Part[m,2];
  d:=Together[u^2+1]; addndg[Numerator[d]]; 
  point[(a1*(u^2-1) + 2*m1 + 2*(m2-a2)*u)/d, 
	 (a2 + 2*(m1-a1)*u + (2*m2-a2)*u^2)/d]]  

circle[c1_,c2_,c3_,c4_]:=
  GPCircle@@(Together/@{c1,c2,c3,c4}//reduceCoords); 

pccircle[m_GPPoint,a_GPPoint]:=Module[{d,a1,a2,m1,m2},
  a1:=Part[a,1]; a2:=Part[a,2];
  m1:=Part[m,1]; m2:=Part[m,2];
  circle[1, -2*m1, -2*m2, a1*(2*m1-a1) + a2*(2*m2-a2)]]

circlecenter[c_GPCircle]:=(addndg[Numerator[Part[c,1]]];
  point[-Part[c,2]/2/Part[c,1] ,-Part[c,3]/(2*Part[c,1])])

circlesqradius[c_GPCircle]:= (addndg[Numerator[Part[c,1]]];
  Together[((Part[c,2]^2+Part[c,3]^2) - 4*Part[c,4]*Part[c,1]) / 
	(2*Part[c,1])^2])

oncircle[p_GPPoint,c_GPCircle]:=Module[{p1,p2}, 
  p1:=Part[p,1]; p2:=Part[p,2];
  Together[Part[c,1]*(p1^2+p2^2)+Part[c,2]*p1+Part[c,3]*p2+Part[c,4]]]  

(*Intersections with circles*)

otherclpoint[p_GPPoint,c_GPCircle,l_GPLine]:= 
Module[{c1,c2,c3,l1,l2,d,d1,p1,p2},
  If[ !(online[p,l] === 0), 
      Message[otherclpoint::pnol]; Return[],
      If[!(oncircle[p,c] === 0),
          Message[otherclpoint::pnoc]; Return[], 
          c1:=Part[c,1]; c2:=Part[c,2]; c3:=Part[c,3]; 
          l1:=Part[l,1]; l2:=Part[l,2]; p1:=Part[p,1]; p2:=Part[p,2];
          d:=Together[c1*(l1^2 + l2^2)]; addndg[Numerator[d]]; 
          d1:=Together[c1*(l1^2-l2^2)];
          point[(d1*p1+((2*c1*p2 + c3)*l1-c2*l2)*l2)/d, 
	        (- d1*p2+((2*c1*p1 + c2)*l2-c3*l1)*l1)/d]]]]  

radicalaxis[c1_GPCircle,c2_GPCircle]:=
  Apply[line,Table[Together[
	Part[c1,1]*Part[c2,i]-Part[c1,i]*Part[c2,1]], {i,2,4}]]; 

iscltangent[c_GPCircle,l_GPLine]:=Module[{c1,c2,c3,c4,l1,l2,l3},
  c1:=Part[c,1]; c2:=Part[c,2]; c3:=Part[c,3]; c4:=Part[c,4]; 
  l1:=Part[l,1]; l2:=Part[l,2]; l3:=Part[l,3]; 
  Together[4*c1*( (- c1*l3 + c2*l1 + c3*l2)*l3 - c4*(l1^2 + l2^2))  
	+ (c2*l2 - c3*l1)^2]];

tangentline[P_GPPoint,c_GPCircle]:=
  If[!(oncircle[P,c]==0), 
	Message[tangentline::pnoc]; Return[],
	line[2*Part[c,1]*Part[P,1]+Part[c,2], 
		2*Part[c,1]*Part[P,2]+Part[c,3],
                Part[c,2]*Part[P,1]+Part[c,3]*Part[P,2]+2*Part[c,4]]];

(* The undocumented GeoProver Plot addendum for Mathematica *)

geoplot[args_List,rg_List]:=Module[{l},
  l=Map[ Switch[#, {_,_RGBColor},geoplot1[#[[1]],rg,#[[2]]],
		    o_,geoplot1[#,rg,RGBColor[0,0,0]]] &, args]; 
  Show[l,DisplayFunction->$DisplayFunction,
      PlotRange->{{rg[[2]],rg[[3]]},{rg[[2]],rg[[3]]}}]]

geoplot1[p_,rg_,c_]:=Module[ { u}, 
  (* plot a single object p with range rg and color c *)
  u=Switch[p,
       _GPPoint, geoplotpoint[p,c],
       _GPLine,  geoplotline[p,rg,c],
       _GPCircle, geoplotcircle[p,c],
       _, Message[geoplot::wrga]];
  Show[u]]

geoplotpoint[p_,c_]:=Graphics[{c,Point@@p},DisplayFunction->Identity]

geoplotline[p_,range_,c_]:=Module[{t}, t=range[[1]];
  If [Part[p,2]===0,
      ParametricPlot[{-Part[p,3]/Part[p,1],t},
        range,{Axes->None,AspectRatio->Automatic,PlotStyle->c,
          DisplayFunction->Identity}], 
      ParametricPlot[{t,-(Part[p,1]*t+Part[p,3])/Part[p,2]},
        range,{Axes->None,AspectRatio->Automatic,PlotStyle->c,
          DisplayFunction->Identity}]]] 

geoplotcircle[p_,c_]:=Module[{M,r}, 
  M:=circlecenter[p]; r:=Sqrt[circlesqradius[p]];
  Show[Graphics[{c,Circle[List@@M,r]},{Axes->None,AspectRatio->Automatic,
          DisplayFunction->Identity}]]]

(* During 'Build' some more generated code will be added  *)


(* GeoProver code generated from database *)



End[] (* Private *)
EndPackage[]
