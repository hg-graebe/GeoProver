(*###############################################################
#
# FILE:    supp.m
# AUTHOR:  graebe
# CREATED: 2/2002
# PURPOSE: Interface for the extended GEO syntax to Mathematica
# VERSION: $Id: supp.m,v 1.1 2012/02/10 21:13:31 graebe Exp $

General interface *)

(* Interface to Groebner bases and normal forms *)

geogbasis[polys_,vars_]:=
  (* compute a lex Groebner basis of polys in k[vars] *)
  GroebnerBasis[polys,vars,CoefficientDomain -> RationalFunctions]
	
geonormalf[p_List,polys_,vars_]:=geonormalf[#,polys,vars]& /@ p

geonormalf[p_,polys_,vars_]:=
  (* compute the normal form of p wrt. polys in k[vars] *)
  Together[PolynomialReduce[p,polys,vars,
	   CoefficientDomain -> RationalFunctions][[2]]]

geosubs[a_,b_,c_]:=c/.(a->b)

geosolve[polys_,vars_]:=Solve[
  If[FreeQ[polys, Equal], polys==0, polys], vars]

geosolveconstrained[polys_,vars_,nondegs_]:=Solve[
  (* solve polys wrt. vars assuming nondegs != 0 *)
  And[Apply[And,If[FreeQ[polys, Equal], Thread[polys==0], polys]],
    Apply[And,Thread[nondegs != 0]]] ,vars]

geoeval[con_,sol_]:=con /. sol // Together
  (* map all solutions from sol onto the expression con *)
  
geosimplify[u_]:=Simplify[u]

geonormal[u_]:=Together[u]

geoeliminate[polys_,vars_,evars_]:=Eliminate[polys==0,evars]
  (* Eliminate evars in the equations polys==0 *)

