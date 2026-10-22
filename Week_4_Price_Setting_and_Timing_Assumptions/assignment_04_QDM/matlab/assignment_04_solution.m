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
par.betta   = 0.98;     % Period discount rate
par.nuu     = 0.5;      % Inverse of Frisch labor supply elasticity
par.vphi    = 1;        % Labor disutility parameter
par.rhoo    = 0.9;      % Elasticity of substitution between types of goods
% Shock processes
par.rho_t   = 0.8;      % Money growth autocorrelation
par.rho_z   = 0.9;      % Productivity growth autocorrelation
par.rho_d   = 0.8;      % Money loss autocorrelation
par.sig_t   = 0.05;     % Standard deviation of money shock
par.sig_z   = 0.05;     % Standard deviation of growth shock
par.sig_d   = 0.01;     % Standard deviation of money loss cost
par.avg_t   = 0.05;     % Constant to yield 5% average money growth
par.avg_z   = 1;        % Constant productivity level
par.avg_d   = 0.02;     % Constant to yield 2% average money loss cost
% Set AR(1) process constants
par.B_t     = par.avg_t*(1-par.rho_t);
par.B_z     = par.avg_z*(1-par.rho_z);
par.B_d     = par.avg_d*(1-par.rho_d);
% Set initial values for the states
par.money_init  = 1;    % Initial money stock

% Options
opts.T           = 100;              % Simulation horizon
opts.irf_disp    = 15;              % Periods displayed for the IRFs
opts.dist_grid   = 50;              % Approximation grid for nominal interest rate expectations

%% RANDOM VARIABLES
% ------------------------------------------------------------------------------
% Set the seed of the random number generator for reproducability
rng(123);
% Draw our random variables for our simulation of tau, del, and g
shocks_sim.ep_t = par.sig_t*randn(1,opts.T);        % Money loss shocks for the continuous simulation
shocks_sim.ep_z = par.sig_z*randn(1,opts.T);        % Money loss shocks for the continuous simulation
shocks_sim.ep_d = par.sig_d*randn(1,opts.T);        % Money loss shocks for the continuous simulation
% IRFs for tau. Set other two shocks to zero
shocks_irf_t.ep_t = [par.sig_t zeros(1,opts.T-1)];    % Money loss shocks for the impulse response function
shocks_irf_t.ep_z = zeros(1,opts.T);
shocks_irf_t.ep_d = zeros(1,opts.T);
% IRFs for productivity. Set other two shocks to zero
shocks_irf_z.ep_z = [par.sig_z zeros(1,opts.T-1)];    % Money loss shocks for the impulse response function
shocks_irf_z.ep_t = zeros(1,opts.T);
shocks_irf_z.ep_d = zeros(1,opts.T);
% IRFs for del. Set other two shocks to zero.
shocks_irf_d.ep_d = [par.sig_d zeros(1,opts.T-1)];    % Money loss shocks for the impulse response function
shocks_irf_d.ep_t = zeros(1,opts.T);
shocks_irf_d.ep_z = zeros(1,opts.T);

%% Simulations
% --------------------------------------------------------------------------------------------------
tic;
% Call the model function (bottom of the code) to create simulated time series of the economy
out_sim = model_uncertainty(par, shocks_sim, opts);
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
legend('Forecasted','Actual','Steady-State')
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
legend('Forecasted','Actual','Steady-State')
title('Forecasted and actual consumption')
% Bond price
nexttile
plot(out_sim.qa)
hold on
yline(mean(out_sim.qa),'r')
hold off
axis tight
xlabel('Period')
ylabel('Bond Price')
legend('Forecasted','Steady-State')
title('Bond Price over Time')
% Price level
nexttile
plot(out_sim.pf)
axis tight
xlabel('Period')
ylabel('Price Level')
title('Price Level Growth over Time')
% Money stock
nexttile
plot(out_sim.m)
axis tight
xlabel('Period')
ylabel('Money Stock')
title('Money Stock Growth over Time')

%% Impulse Response Functions
% --------------------------------------------------------------------------------------------------
tic;
% Call the model function (bottom of the code) to create a IRF time series of the economy
out_irf_t = model_uncertainty(par, shocks_irf_t, opts);
out_irf_z = model_uncertainty(par, shocks_irf_z, opts);
out_irf_d = model_uncertainty(par, shocks_irf_d, opts);
toc;

% --------------------------------------------------------------------------------------------------
% Plotting the results in a tiled figure (subplots)
figure('Name','Impulse Response Functions')
tiledlayout(2,3)
% Labor supply
nexttile
plot(out_irf_t.lf(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf_t.la(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_z.lf(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_z.la(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_d.lf(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_d.la(1:opts.irf_disp),'LineWidth',2)
yline(out_irf_t.la(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Hours Worked')
legend('Forecasted Tau','Actual Tau','Forecasted Prod','Actual Prod','Forecasted Del','Actual Del','Steady-State')
title('Forecasted and actual labor supply')
% Consumption
nexttile
plot(out_irf_t.cf(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf_t.ca(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_z.cf(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_z.ca(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_d.cf(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_d.ca(1:opts.irf_disp),'LineWidth',2)
yline(out_irf_t.ca(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Consumption')
legend('Forecasted Tau','Actual Tau','Forecasted Prod','Actual Prod','Forecasted Del','Actual Del','Steady-State')
title('Forecasted and actual consumption')
% Bond price
nexttile
plot(out_irf_t.qa(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf_z.qa(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_d.qa(1:opts.irf_disp),'LineWidth',2)
yline(out_irf_t.qa(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Bond price')
legend('Tau','Prod','Del')
title('Bond Price over Time')
% Price level
nexttile
plot(out_irf_t.pf(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf_z.pf(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_d.pf(1:opts.irf_disp),'LineWidth',2)
hold off
axis tight
xlabel('Period')
ylabel('Price Level')
legend('Tau','Prod','Del')
title('Price Level Growth over Time')
% Money stock
nexttile
plot(out_irf_t.m(1:opts.irf_disp),'LineWidth',2)
hold on
plot(out_irf_z.m(1:opts.irf_disp),'LineWidth',2)
plot(out_irf_d.m(1:opts.irf_disp),'LineWidth',2)
hold off
axis tight
xlabel('Period')
ylabel('Money Stock')
legend('Tau','Prod','Del')
title('Money Stock Growth over Time')

%% Model function to simulate the economy given a set of parameters, shocks, and options
% --------------------------------------------------------------------------------------------------
function out = model_uncertainty(par, shocks, opts)
% Initialize
counter = 1;
% Variables from t-1
money_prev  = par.money_init;
delA_prev   = par.avg_d;
tauA_prev   = par.avg_t;
zA_prev     = par.avg_z;
% Approximate distribution of future money growth shocks
rng(123);
shoc_d      = par.sig_d*randn(1,opts.dist_grid);
shoc_t      = par.sig_t*randn(1,opts.dist_grid);
% Pre-allocate zero vectors for variables (increases speed)
delF        = zeros(1,opts.T);
tauF        = zeros(1,opts.T);
zF          = zeros(1,opts.T);
qA          = zeros(1,opts.T);
muuF        = zeros(1,opts.T);
laborF      = zeros(1,opts.T);
consF       = zeros(1,opts.T);
pbar        = zeros(1,opts.T);
delA        = zeros(1,opts.T);
tauA        = zeros(1,opts.T);
laborA      = zeros(1,opts.T);
consA       = zeros(1,opts.T);
money       = zeros(1,opts.T);
% Run a WHILE loop to create a model simulation across T periods
while counter <= opts.T
    % Prices given expected outcome of the economy
    delF(counter)   = par.rho_d.*delA_prev + par.B_d;
    tauF(counter)   = par.rho_t.*tauA_prev + par.B_t;
    zF(counter)     = par.rho_z.*zA_prev   + par.B_z + shocks.ep_z(counter);
    muuF(counter)   = par.betta./(1+tauF(counter));
    laborF(counter) = ( par.rhoo./par.vphi.*muuF(counter) ).^(1./(1+par.nuu));    
    consF(counter)  = zF(counter).*laborF(counter);
    pbar(counter)   = (1-delF(counter)).*money_prev./consF(counter);
    % Calculate actual money loss rate
    delA(counter)   = delF(counter) + shocks.ep_d(counter);
    tauA(counter)   = tauF(counter) + shocks.ep_t(counter);
    % Calculate actual labor and consumption realizations
    laborA(counter) = (1-delA(counter))./(1-delF(counter)).*(1+tauA(counter))/(1+tauF(counter)).*laborF(counter);
    consA(counter)  = zF(counter).*laborA(counter);
    % Calculate nominal interest rate taking expectations about the future into account
    delAF_prime_states  = zeros(1,length(shoc_d));
    tauAF_prime_states  = zeros(1,length(shoc_d));
    qA_states           = zeros(1,length(shoc_d));
    for hh = 1:length(shoc_d)
        delAF_prime_states(hh)  = par.rho_d.*delA(counter) + par.B_d + shoc_d(hh);
        for tt = 1:length(shoc_t)
            tauAF_prime_states(tt)  = par.rho_t.*tauA(counter) + par.B_t + shoc_t(tt);
            qA_states(hh,tt)        = par.betta./(1+tauAF_prime_states(tt)) .* 1./(1-delAF_prime_states(hh));
        end
    end
    % Calculating expectations of q (weighted mean)
    qA(counter) = mean(mean(qA_states,2),1);
    % Updating the money stock
    money(counter)      = (1+tauA(counter))*(1-delA(counter))*money_prev;
    % Updating stock variables for calculations in the next period
    money_prev          = money(counter);
    delA_prev           = delA(counter);
    tauA_prev           = tauA(counter);
    zA_prev             = zF(counter);
    % Updating WHILE loop counter
    counter = counter + 1;
end
% Saving our output in a structure called "out"
out.lf  = laborF;
out.cf  = consF;
out.pf  = pbar;
out.qa  = qA;
out.la  = laborA;
out.ca  = consA;
out.m   = money;
end
