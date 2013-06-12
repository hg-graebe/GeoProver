###################################################################
#
# FILE:    supp.mpl
# AUTHOR:  graebe
# CREATED: 2/2002
# PURPOSE: Interface for the extended GEO syntax to Maple 
# VERSION: $Id: supp.mpl,v 1.1 2012/02/10 21:13:31 graebe Exp $

# General interface #

List:=proc() [args] end;
Sqrt:=proc(u) sqrt(u) end;
geo_subs:=proc(a,b,c) subs(a=b,c) end;

# Interface to Groebner bases and normal forms. poly and polys are
# assumed to be rational 

with(Groebner):

geo_num:=proc(poly) local x;
# return numerator, add denominator to the ndg #
   `geoprover/add_ndg`(denom(poly));
   numer(poly);
end:

geo_gbasis:=proc(polys,vars)
  # compute a lex Groebner basis of polys in k[vars] #
	if nargs<>2 then
	   error("Syntax must be geo_gbasis(polys,vars)") 
	fi;
	gbasis([op(map(geo_num,polys))],plex(op(vars)));
end:
	
geo_normalf:=proc(p,polys,vars)
  # compute the normal form of p wrt. polys in k[vars] #
	if type(p,list) then return map(geo_normalf,p,polys,vars) fi;
	if nargs<>3 then
	   error("Syntax must be geo_normalf(poly,basis,vars)")
	fi;
	normalf(geo_num(p),[op(polys)],plex(op(vars)));
end:
		
geo_solve1:=proc(polys,vars) 
  solve({op(polys)},{op(vars)}) 
end:

geo_solve:=proc(polys,vars) 
# solve polys wrt. vars #
  map(allvalues,[geo_solve1(polys,vars)]) end:

geo_solveconstrained:=proc(polys,vars,nondegs) 
# solve polys wrt. vars assuming nondegs #
map(x->geo_solve1(op(1,x),vars),
    [op(gsolve(map(geo_num,polys),vars,nondegs))]) end:

geo_eval:=proc(con,sol)
# map all solutions from sol onto the expression con #
map(proc(x) normal(subs(x,con)) end,sol) end:

geo_simplify:=proc(u) simplify(u) end;

geo_normal:=proc(u) normal(u) end;

geo_eliminate:=proc(polys,vars,evars)
  local nonevars,gb;
  nonevars:=select(x -> not member(x,evars), vars);
  gb:=gbasis([op(map(geo_num,polys))],plex(op(evars),op(nonevars)));
  select(x -> not has(x,evars), gb);
end:

geo_groebfactor:= proc(polys,vars) 
  map(u->u[1],gsolve(polys,vars));
end:
