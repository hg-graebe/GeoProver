/* ###############################################################
%
% FILE:    supp.m
% AUTHOR:  graebe
% CREATED: 2/2017
% PURPOSE: Interface for the extended GEO syntax to Maxima
% VERSION: $Id: supp.red,v 1.1.1.1 2003/11/07 10:34:06 graebe Exp $

*/

load(grobner);
geo_simplify(u):=ratsimp(u);
geo_normal(u):=ratsimp(u);

geo_gbasis(polys,vars):=poly_reduced_grobner(polys,vars);
geo_normalf(poly,gbasis,vars):=poly_normal_form(poly,gbasis,vars);
