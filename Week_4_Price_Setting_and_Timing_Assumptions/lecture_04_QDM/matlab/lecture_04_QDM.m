%% *************************************************************************************************
% Quantitative Dynamic Macroeconomics
% Lecture 04: Price Setting and Information Frictions
% Based on Harold Cole (2020). Monetary and Fiscal Policy through a DSGE Lens. Chapter 10.
% Konstantin Gantert
% 07/09/2023
% **************************************************************************************************
%% Housekeeping
% --------------------------------------------------------------------------------------------------
clear all;      % Clear all variables from the workspace
clc;            % Clear the command window

%% Parameters and Options
% --------------------------------------------------------------------------------------------------
% Model parameters
etaa        = 11;               % Substitutability parameter between any two goods C(i) and C(j)
betta       = 0.98;             % Period discount rate
zz          = 1;                % Fixed productivity
Btau        = 0.01;             % Constant of money growth process
std_tau     = 0.01;             % Standard deviation of money growth shock
rhoo        = 0.9;              % Autocorrelation/persistence of money growth shock
% Initial variable values
money_init  = 1;                % Initial money stock
tauA_init   = Btau/(1-rhoo);    % Long-term average money growth
% Simulation options
sim_periods = 500;              % Number of periods for simulation
irf_periods = 50;               % Number of periods calculated for impulse response function
irf_disp    = 10;               % Number of periods displayed for impulse response function

%% Impulse Response Funnctions
% --------------------------------------------------------------------------------------------------
% Create shock process
epss_irf    = [ std_tau zeros(1,irf_periods-1) ];  % IRF shock process: One shock in the first period and zero thereafter.
% Setting starting values for money growth rate and money stock.
tauA_prev = tauA_init;  % Initial money growth rate from the previous period is set to long-term average.
money = money_init;     % Initial money stock is normalized to one.

% Pre-allocation of variable vectors (improves execution speed)
tauA_irf            = zeros(1,irf_periods);
laborF_irf          = zeros(1,irf_periods);
laborA_irf          = zeros(1,irf_periods);
consF_irf           = zeros(1,irf_periods);
consA_irf           = zeros(1,irf_periods);
Pbar_irf            = zeros(1,irf_periods);
money_prime_irf     = zeros(1,irf_periods);

% FOR-loop: Simulating the model one period at a time and using updated values for the next period
for ii = 1:irf_periods
    % Calling the model function
    [tauA_irf(ii), laborF_irf(ii), laborA_irf(ii), consF_irf(ii), consA_irf(ii), Pbar_irf(ii), money_prime_irf(ii)] ...
                = model_04(tauA_prev, money, rhoo, Btau, zz, etaa, betta, epss_irf(ii));
    % Updating the stock variables
    tauA_prev   = tauA_irf(ii);
    money       = money_prime_irf(ii);
end

% --------------------------------------------------------------------------------------------------
% Plotting the results in a tiled figure (subplots)
figure('Name','Impulse Response Functions')
tiledlayout(2,2)
% Labor supply
nexttile
plot(laborF_irf(1:irf_disp),'LineWidth',2)
hold on
plot(laborA_irf(1:irf_disp),'LineWidth',2)
yline(laborA_irf(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Hours Worked')
legend('Forecasted','Actual')
title('Forecasted and actual labor supply')
% Consumption
nexttile
plot(consF_irf(1:irf_disp),'LineWidth',2)
hold on
plot(consA_irf(1:irf_disp),'LineWidth',2)
yline(consA_irf(end),'r')
hold off
axis tight
xlabel('Period')
ylabel('Consumption')
legend('Forecasted','Actual')
title('Forecasted and actual consumption')
% Price level
nexttile
plot(Pbar_irf(1:irf_disp),'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Price Level')
title('Price Level Growth over Time')
% Money stock
nexttile
plot(money_prime_irf(1:irf_disp),'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Money Stock')
title('Money Stock Growth over Time')

% Export figure for the slides
exportgraphics(gcf,fullfile('..','latex','figures','irf.eps'),'ContentType','vector')

%% Simulations
% --------------------------------------------------------------------------------------------------
% Create shock process
epss_sim    = randn(1,sim_periods)*std_tau;  % Simulation shock series: AR(1) process but each period a new shock is also drawn.
% Setting starting values for money growth rate and money stock.
tauA_prev = tauA_init;
money = money_init;
% Pre-allocation of variable vectors (improves execution speed)
tauA_sim            = zeros(1,sim_periods);
laborF_sim          = zeros(1,sim_periods);
laborA_sim          = zeros(1,sim_periods);
consF_sim           = zeros(1,sim_periods);
consA_sim           = zeros(1,sim_periods);
Pbar_sim            = zeros(1,sim_periods);
money_prime_irf     = zeros(1,sim_periods);
% FOR-loop: Simulating the model one period at a time and using updated values for the next period
for ii = 1:sim_periods
    % Calling the model function
    [tauA_sim(ii), laborF_sim(ii), laborA_sim(ii), consF_sim(ii), consA_sim(ii), Pbar_sim(ii), money_prime_sim(ii)] ...
                = model_04(tauA_prev, money, rhoo, Btau, zz, etaa, betta, epss_sim(ii));
    % Updating the stock variables
    tauA_prev   = tauA_sim(ii);
    money       = money_prime_sim(ii);
end

% --------------------------------------------------------------------------------------------------
% Plotting simulated time series of the model economy
figure('Name','Simulation of the Economy')
tiledlayout(2,2)
% Labor supply
nexttile
plot(laborF_sim)
hold on
plot(laborA_sim)
yline(mean(laborA_sim),'r')
hold off
axis tight
xlabel('Period')
ylabel('Hours Worked')
legend('Forecasted','Actual')
title('Forecasted and actual labor supply')
% Consumption
nexttile
plot(consF_sim)
hold on
plot(consA_sim)
yline(mean(consA_sim),'r')
hold off
axis tight
xlabel('Period')
ylabel('Consumption')
legend('Forecasted','Actual')
title('Forecasted and actual consumption')
% Price level
nexttile
plot(Pbar_sim,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Price Level')
title('Price Level Growth over Time')
% Money stock
nexttile
plot(money_prime_sim,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('Money Stock')
title('Money Stock Growth over Time')

% Export figure for the slides
exportgraphics(gcf,fullfile('..','latex','figures','simulation.eps'),'ContentType','vector')

%% Model section
% --------------------------------------------------------------------------------------------------
function [tauA, laborF, laborA, consF, consA, Pbar, money_prime] ...
                        = model_04(tauA_prev, money, rhoo, Btau, zz, etaa, betta, epss)
    % Forecasted money growth today
    tauF    = rhoo*tauA_prev + Btau;
    % Forecasted money growth tomorrow
    tauF_prime = rhoo*(rhoo*tauA_prev + Btau) + Btau;
    % Actual money growth
    tauA    = tauF + epss;
    % Forecasted labor supply
    laborF = ( betta*etaa / (1+tauF_prime) );
    % Actual labor supply
    laborA  = (1+tauA)/(1+tauF)*laborF;
    % Forecasted consumption
    consF   = zz*laborF;
    % Actual consumption
    consA   = (1+tauA)/(1+tauF)*consF;
    % Prices (set at the beginning of the period)
    Pbar    = money*(1+tauF) / (zz*laborF);
    % Money stock tomorrow
    money_prime = (1+tauA)*money;
end