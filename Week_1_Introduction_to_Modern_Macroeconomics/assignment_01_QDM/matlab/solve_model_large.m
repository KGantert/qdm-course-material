%% *****************************************************************************
% Quantitative Dynamic Macroeconomics
% Assignment 01: A Three-Period Model
% Konstantin Gantert
% 24/08/2023
% ******************************************************************************
% function [OUTPUT1,OUTPUT2,...] = FUNCTIONNAME(INPUT1,INPUT2,...)
function output = solve_model_large(betta,phii,nuu,sig,zbar,g1,g2,xx_0)
% ------------------------------------------------------------------------------
% SOLVE the one equation model from assignment 01 with a numerical solver
% EXERCISE 1 a)
% ------------------------------------------------------------------------------
% Set fsolve function handle with external function to be optimized
% The "external" function is defined as a local function at the bottom of the page
solve_all_fnc = @(xx) solve_all(xx,betta,phii,nuu,sig,zbar,g1,g2);
% Execute fsolve with the function handle and the starting value for c1
% Solve the results as the solution to c1 (consumption today)
options = optimset('Display','off');
results = fsolve(solve_all_fnc,xx_0,options);
% ------------------------------------------------------------------------------
% Save the results of all variables in the "output" structure
% ------------------------------------------------------------------------------
output.L1   = results(1);
output.L2   = results(2);
output.L3   = results(3);
output.C1   = results(4);
output.C2   = results(5);
output.C3   = results(6);
output.Q1   = results(7);
output.Q2   = results(8);
end % END of the function "solve_model"
% ------------------------------------------------------------------------------
% Local function of the non-linear equation of c1 to be solved numerically
% ------------------------------------------------------------------------------
% xx is the array of endogenous variables of the model. By indexation we
% can define which variable is which!
function F = solve_all(xx,betta,phii,nuu,sig,zbar,g1,g2)
    % Equation is solved for zero (F(1) = EQUATION TERMS)
    % xx(1-3): L1-L3; xx(4-6): C1-C3; xx(7-8): Q1-Q2
    F(1) = phii*nuu*xx(1)^nuu - xx(4)^(1-sig);
    F(2) = phii*nuu*xx(2)^nuu - xx(5)^(1-sig);
    F(3) = phii*nuu*xx(3)^nuu - xx(6)^(1-sig);
    F(4) = xx(4) - zbar*xx(1);
    F(5) = xx(5) - (1+g1)*zbar*xx(2);
    F(6) = xx(6) - (1+g1)*(1+g2)*zbar*xx(3);
    F(7) = xx(7) - betta*(xx(4)/xx(5))^sig;
    F(8) = xx(8) - betta*(xx(5)/xx(6))^sig;
end % END of the local function
% ------------------------------ END OF FILE -----------------------------------
