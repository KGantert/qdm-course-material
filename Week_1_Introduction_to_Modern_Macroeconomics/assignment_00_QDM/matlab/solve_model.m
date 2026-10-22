%% *****************************************************************************
% Quantitative Dynamic Macroeconomics
% Assignment 00
% RUN FILE (PARAMETER SETUP AND FOR LOOPS)
% Konstantin Gantert
% 24/08/2023
% ******************************************************************************
% function [OUTPUT1,OUTPUT2,...] = FUNCTIONNAME(INPUT1,INPUT2,...)
function output = solve_model(betta,r,sig,z,k1,alp,nuu,psii,c1_0)
% ------------------------------------------------------------------------------
% SOLVE the one equation model from assignment 01 with a numerical solver.
% This file has three parts:
% 1) A function defined within the file at the bottom of the page that is
%   our model equation solved for F(x) = 0. Hence, we look for a x (here: c1)
%   that solves this equation for F(c1) = 0!
% 2) A function handle ("solve_c1_fnc") that is passed to "fsolve", a
%   numerical method to find the root (hence the equilibrium) of our model
%   equation. If you are interested in how this method works, search for
%   "Newton-Raphson algorithm". However, you do not need to know this
%   algorithm in detail for this course. Matlab does everything for us!
% 3) The rest of the model equations to derive all variables and their
%   values from c1. Those equations are all implicitly solved for in our
%   function as defined in 1). We then save all variables in the structure "output.xy"
% ------------------------------------------------------------------------------
% Set fsolve function handle with external function to be optimized
% The "external" function is defined as a local function at the bottom of the page
solve_c1_fnc = @(c1) solve_c1(c1,betta,r,sig,z,k1,alp,nuu,psii);
% Execute fsolve with the function handle and the starting value for c1
% Solve the results as the solution to c1 (consumption today)
c1      = fsolve(solve_c1_fnc,c1_0);
% ------------------------------------------------------------------------------
% Derive all variables using model equations and the numerical solution to c1
% EXERCISE 1 b)
% ------------------------------------------------------------------------------
% Consumption tomorrow
c2    = (betta*(1+r))^(1/sig)*c1;
% Capital stock tomorrow
k2    = (alp*z/(1+r))^((nuu+alp)/(nuu*(1-alp))) * ((1-alp)/psii*c2^(-sig)*z)^(1/nuu);
% Labor supply today
h1    = ((1-alp)/psii*c1^(-sig)*z*k1^alp)^(1/(nuu+alp));
% Labor supply tomorrow
h2    = ((1-alp)/psii*c2^(-sig)*z*k2^alp)^(1/(nuu+alp));
% Production today
y1    = z*k1^alp*h1^(1-alp);
% Production tomorrow
y2    = z*k2^alp*h2^(1-alp);
% Savings today
s     = y1 - c1 - k2;
% ------------------------------------------------------------------------------
% Save the results of all variables in the "output" structure
% ------------------------------------------------------------------------------
output.c1   = c1;
output.c2   = c2;
output.k1   = k1;
output.k2   = k2;
output.h1   = h1;
output.h2   = h2;
output.y1   = y1;
output.y2   = y2;
output.s    = s;
end % END of the function "solve_model"
% ------------------------------------------------------------------------------
% Local function of the non-linear equation of c1 to be solved numerically
% ------------------------------------------------------------------------------
function F = solve_c1(c1,betta,r,sig,z,k1,alp,nuu,psii)
% Equation is solved for zero (F(1)/0 = EQUATION TERMS)
F(1)    = c1 + (betta*(1+r))^(1/sig)/(1+r)*c1 + (alp*z/(1+r))^(1/(1-alp))*((1-alp)/psii*z/(betta*(1+r)*c1^sig)*(alp*z/(1+r))^(alp/(1-alp)))^(1/nuu) ...
            - z*( k1^alp*((1-alp)/psii*z/(c1^sig)*k1^alp)^((1-alp)/(nuu+alp)) + 1/(1+r)*(alp*z/(1+r))^(alp/(1-alp))*((1-alp)/psii*z/(betta*(1+r)*c1^sig)*(alp*z/(1+r))^(alp/(1-alp)))^(1/nuu) );
end % END of the local function
% ------------------------------ END OF FILE -----------------------------------