%% *************************************************************************************************
% Quantitative Dynamic Macroeconomics
% Assignment 04: Surprise Money Losses and Aggregate Demand
% Konstantin Gantert
% 18/09/2023
% **************************************************************************************************
%% HOUSEKEEPING
% --------------------------------------------------------------------------------------------------
clear all;  % Clear the workspace to prevent using any old variable or function
clc;        % Clear the command window for better visibility of new results

%% PARAMETERS AND OPTIONS
% --------------------------------------------------------------------------------------------------
% Parameters (make sure to not use the exact spelling of greek letters as
% they might already be a build-in Matlab function.
par.betta   = 0.98;             % Period discount rate
par.nuu     = 0.5;              % Inverse of Frisch labor supply elasticity
par.vphi    = 1;                % Labor disutility parameter
par.rhoo    = 0.9;              % Elasticity of substitution between types of goods
par.tauu    = 0.1;              % Money growth rate
% Shock processes
par.rho_d   = 0.9;              % Money loss autocorrelation
par.sig_d   = 0.01;             % Standard deviation of money loss cost
par.B_d     = 0.05*(1-par.rho_d);   % Constant to yield 1% average money loss cost
% Set initial values for the states
par.money_init = 1;             % Initial money stock
par.Zprod = 1;                  % Initial productivity level

% Options
opts.T           = 50;      % Simulation horizon
opts.irf_disp    = 25;      % Periods displayed for the IRFs
opts.dist_grid   = 50;      % Approximation grid for nominal interest rate expectations

%% RANDOM VARIABLES
% ------------------------------------------------------------------------------
% Set the seed of the random number generator for reproducability
rng(123);
% Draw our random variables for 
% (i) our simulation of tau and g, and 
% (ii) approximating the integral.
shocks_sim.ep_d = ...;      % Money loss shocks for the continuous simulation
shocks_irf.ep_d = ...;      % Money loss shocks for the impulse response function

%% Simulations
% --------------------------------------------------------------------------------------------------
tic;
% Call the model function (bottom of the code) to create simulated time series of the economy
out_sim = ...;
toc;
% --------------------------------------------------------------------------------------------------
% Plotting simulated time series of the model economy
figure('Name','Simulation of the Economy')
tiledlayout(2,3)
% Labor supply
nexttile
plot(out_sim.lf)
hold on
plot(out_sim.la)
yline(mean(out_sim.la),'r')
hold off
axis tight
xlabel('Period')
ylabel('Hours Worked')
legend('Forecasted','Actual')
title('Forecasted and actual labor supply')
% Consumption
nexttile
plot(out_sim.cf)
hold on
plot(out_sim.ca)
yline(mean(out_sim.ca),'r')
hold off
axis tight
xlabel('Period')
ylabel('Consumption')
legend('Forecasted','Actual')
title('Forecasted and actual consumption')
% Bond price
nexttile
plot(out_sim.qf)
hold on
plot(out_sim.qa)
yline(mean(out_sim.qa),'r')
hold off
axis tight
xlabel('Period')
ylabel('Bond Price')
legend('Forecasted','Actual')
title('Bond Price over Time')
% Price level
nexttile
plot(out_sim.pf,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Price Level')
title('Price Level Growth over Time')
% Money stock
nexttile
plot(out_sim.m,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Money Stock')
title('Money Stock Growth over Time')

%% Impulse Response Functions
% --------------------------------------------------------------------------------------------------
tic;
% Call the model function (bottom of the code) to create a IRF time series of the economy
out_irf = ...;
toc;
% --------------------------------------------------------------------------------------------------
% Plotting the results in a tiled figure (subplots)
figure('Name','Impulse Response Functions')
tiledlayout(2,3)
% Labor supply
nexttile
plot(out_irf.lf(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf.la(1:opts.irf_disp),'LineWidth',2)
yline(out_irf.la(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Hours Worked')
legend('Forecasted','Actual')
title('Forecasted and actual labor supply')
% Consumption
nexttile
plot(out_irf.cf(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf.ca(1:opts.irf_disp),'LineWidth',2)
yline(out_irf.ca(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Consumption')
legend('Forecasted','Actual')
title('Forecasted and actual consumption')
% Bond price
nexttile
plot(out_irf.qf(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf.qa(1:opts.irf_disp),'LineWidth',2)
yline(out_irf.qa(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Bond price')
legend('Forecasted','Actual')
title('Bond Price over Time')
% Price level
nexttile
plot(out_irf.pf(1:opts.irf_disp),'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Price Level')
title('Price Level Growth over Time')
% Money stock
nexttile
plot(out_irf.m(1:opts.irf_disp),'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Money Stock')
title('Money Stock Growth over Time')

%% Model function to simulate the economy given a set of parameters, shocks, and options
% --------------------------------------------------------------------------------------------------
function out = model_uncertainty(par, shocks, opts)
% Initialize
rng(123);
counter = 1;
money_prev = par.money_init;
delA_prev  = par.B_d/(1-par.rho_d);
% Approximate distribution of future money growth shocks
shoc = par.sig_d*randn(1,opts.dist_grid);
% Pre-allocate zero vectors for variables (increases speed)
delF        = zeros(1,opts.T);
muuF        = zeros(1,opts.T);
laborF      = zeros(1,opts.T);
consF       = zeros(1,opts.T);
pbar        = zeros(1,opts.T);
delA        = zeros(1,opts.T);
laborA      = zeros(1,opts.T);
consA       = zeros(1,opts.T);
money       = zeros(1,opts.T);
% Run a WHILE loop to create a model simulation across T periods
while counter <= opts.T
    delF(counter)       = ...; % Forecasted money loss today
    muuF(counter)       = ...; % Forecasted muu variable
    laborF(counter)     = ...; % Forecasted labor supply
    consF(counter)      = ...; % Forecasted consumption
    pbar(counter)       = ...; % Price setting with at the beginning of the period
    delA(counter)       = ...; % Middle of the period realization of money loss random variable
    laborA(counter)     = ...; % End of the period actual labor supply
    muuA(counter)       = ...; % End of the period actual muu
    consA(counter)      = ...; % Actual consumption at the end of the period
    money(counter)      = ...; % Actual money holdings in the middle of the period
    % Calculate the nominal interest rate taking expectations about the
    % future into account (no certainty equivalence)
    for hh = 1:length(shoc)
        delAF_prime_states(hh)  = par.rho_d.*delA(counter) + par.B_d + shoc(hh);
        muuAF_states(hh)        = par.betta./(1+par.tauu).*(1-delA(counter))./(1-delAF_prime_states(hh));
        qA_states(hh)           = muuA(counter)./muuAF_states(hh);
    end
    % Calculate expected nominal interest rate
    qA(counter) = mean(qA_states);
    % Update states on money and shock process
    money_prev          = money(counter);
    delA_prev           = delA(counter);
    % Update counter on while loop
    counter = counter + 1;
end
% Create structure to save all the results of the model in
out.lf  = laborF;
... % Further variables output!
end