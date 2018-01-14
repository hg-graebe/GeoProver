//
// FILE:    supp.mu
// AUTHOR:  graebe
// CREATED: 2/2002
// PURPOSE: Interface for the extended GEO syntax to MuPAD 
// VERSION: $Id: supp.mu,v 1.2 2005/06/24 12:34:02 graebe Exp $

/* 

There are yet problems with the new piecewise constructs returned
by the solver.

*/

// General interface //

geoList:=proc() begin [args()] end_proc:
// MuPAD 2.5 uses List as keyword for an option in normal()
Sqrt:=proc(u) begin sqrt(u) end_proc:
geo_subs:=proc(a,b,c) begin subs(c,a=b) end:

/* Interface to Groebner bases and normal forms. poly and polys are
assumed to be rational */

to_list:=proc(u) begin coerce(u,DOM_LIST) end_proc:

geo_num:=proc(poly) local x;
// return numerator, add denominator to the ndg //
begin
   geoprover::add_ndg(denom(poly));
   numer(poly);
end:

geo_gbasis:=
proc(polys,vars)
  // compute a lex Groebner basis of polys in k[vars] //
begin
  if args(0)<>2 then
    error("Syntax must be geo_gbasis(polys,vars)")
  end_if;
  polys:=map([op(map(polys,geo_num))], poly, [op(vars)],
             Dom::ExpressionField(normal));
  map(groebner::gbasis(polys,hold(LexOrder)),expr);
end_proc:
	
geo_groebfactor:=
proc(polys,vars)
  // compute a factored lex Groebner basis of polys in k[vars] //
  local g;
begin
  if args(0)<>2 then
    error("Syntax must be geo_groebfactor(polys,vars)")
  end_if;
  polys:=map([op(map(polys,geo_num))], poly, [op(vars)],
             Dom::ExpressionField(normal));
  g:=groebner::factor(gbasis(polys,hold(LexOrder)),hold(LexOrder));
  map(g,map,expr);
end_proc:
	
geo_normalf:=
proc(p,polys,vars)
  // compute the normal form of p wrt. polys in k[vars] //
begin
  if hastype(p,DOM_LIST) then 
    return (map(p,geo_normalf,polys,vars))
  end_if;
  if args(0)<>3 then
    error("Syntax must be geo_normalf(poly,basis,vars)")
  end_if;
  polys:=map([op(polys)], poly, [op(vars)],
             Dom::ExpressionField(normal));
  p:=poly(geo_num(p),[op(vars)], Dom::ExpressionField(normal));
  expr(groebner::normalf(p,polys,hold(LexOrder)));
end_proc:
		
geo_solve:= // to be fixed for MuPAD 2.5 //
proc(polys,vars)
// solve polys wrt. vars //
  local u;
begin
  u:=solve({op(polys)},{op(vars)},
           BackSubstitution=TRUE, IgnoreSpecialCases);
  // MuPAD 2.5 uses much of piecewise constructs. This is a first hack: //
  if hastype(u,piecewise) then 
    u:=piecewise::disregardPoints(u);
  end_if;
  return(to_list(u));
end_proc:

geo_solveconstrained:=
proc(polys,vars,nondegs)
// solve polys wrt. vars assuming nondegs  //
begin
  select(geo_solve(polys,vars),
         u->not _or(op(map(subs(nondegs,u),iszero@normal))));
end_proc:

geo_eval:=proc(con,sol)
// map all solutions from sol onto the expression con //
begin map(sol,x->normal(subs(con,x))) end_proc:

geo_simplify:=proc(u) begin simplify(u) end:

geo_normal:=proc(u) begin normal(u) end:

geo_eliminate:=
proc(polys,vars,evars)
  local nonevars,gb;
begin
  nonevars:=select(vars,x -> not has(evars,x));
  polys:=map([op(map(polys,geo_num))], poly, [op(evars),op(nonevars)],
             Dom::ExpressionField(normal));
  gb:=gbasis(polys,hold(LexOrder));
  select(map(gb,expr),x -> not _or(op(map(evars,y->has(x,y)))));
end:

