%% *************************************************************************************************
% Quantitative Dynamic Macroeconomics
% Lecture 03: Kappa Model with Markov Process
% Based on Harold Cole (2020). Monetary and Fiscal Policy through a DSGE Lens. Chapter 5.
% Konstantin Gantert
% 07/09/2023
% **************************************************************************************************
%% Housekeeping
% --------------------------------------------------------------------------------------------------
clear all;      % Clear all variables from the workspace
clc;            % Clear the command window

%% Parameters
% --------------------------------------------------------------------------------------------------
betta   = 0.98;
kap     = 0.7;
tauu_G  = 0.02;
tauu_B  = 0.1;
rhoo    = 0.25;
gam     = 1/0.72;
zz      = 1;

%% Solving the model
% --------------------------------------------------------------------------------------------------
% Solving for muu, taking into account weighted expectations
solv_muu_handle = @(muu_vec) solv_muu(muu_vec,betta,tauu_G,tauu_B,rhoo,kap);
muu_res = fsolve(solv_muu_handle,[1 1]);
% Saving the results from FSOLVE for muu in either state
muu_G   = muu_res(1);
muu_B   = muu_res(2);
% Solving for labor supply in either state
l_G     = (muu_G/kap)^(1/(1+gam));
l_B     = (muu_B/kap)^(1/(1+gam));
% Solving for consumption in either state
c_G     = zz*l_G;
c_B     = zz*l_B;
% Solving for nominal interest rate in either state
q_G     = betta/(1+tauu_G) * 1/muu_G * ( muu_G*rhoo + muu_B*(1-rhoo) );
q_B     = betta/(1+tauu_B) * 1/muu_B * ( muu_B*rhoo + muu_G*(1-rhoo) );

%% Simulation
% Create a uniform random variable for 1000 periods: If it is larger than 0.5 (transition matrix of 0.5 each),
% we assign the "G-state", otherwise we assign the "B-state". The model solves analytically, intra-temporally and there are 
% only two states. Hence, any simulation will randomly jump between the two possible values for labor.
% All other variables can be derived from labor.
rnd_state = rand(1000,1);
labor(rnd_state > 0.5) = l_G;
labor(rnd_state <= 0.5) = l_B;

%% Model section
% --------------------------------------------------------------------------------------------------
function F = solv_muu(muu_vec,betta,tauu_G,tauu_B,rhoo,kap)
    muu_G = muu_vec(1);     % Assigning variable to the first element of our solution vector
    muu_B = muu_vec(2);     % Assigning variable to the second element of our solution vector
    % Setting up solving for muu in the form F(muu_S) = 0! This allows us to use FSOLVE later on.
    F(1) = muu_G - betta/(1+tauu_G) * ( rhoo*(1-(1-kap)/kap*muu_G) + (1-rhoo)*(1-(1-kap)/kap*muu_B) );
    F(2) = muu_B - betta/(1+tauu_B) * ( (1-rhoo)*(1-(1-kap)/kap*muu_G) + rhoo*(1-(1-kap)/kap*muu_B) );
end