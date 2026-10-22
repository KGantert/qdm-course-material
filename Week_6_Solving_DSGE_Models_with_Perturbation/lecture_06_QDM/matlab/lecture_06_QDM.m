%% *************************************************************************************************
% Quantitative Dynamic Macroeconomics
% Lecture 06: Full DSGE Model solved with Undetermined Coefficients
% Based on Harold Cole (2020). Monetary and Fiscal Policy through a DSGE Lens. Chapters 19-20.
% Konstantin Gantert
% 01/10/2023
% **************************************************************************************************
%% Housekeeping
% --------------------------------------------------------------------------------------------------
clear all;      % Clear all variables from the workspace
clc;            % Clear the command window

%% Parameters and Options
% --------------------------------------------------------------------------------------------------
% Model parameters
par.betta   = 0.98;         % Period discount rate
par.delt    = 0.02;         % Capital depreciation rate
par.alp     = 1/3;          % Capital elasticity w.r.t. production
par.gam     = 1/0.72;       % Inverse Frisch labor supply elasticity
par.rhoZ    = 0.9;          % Productivity autocorrelation
par.rhoTau  = 0.48;         % Money growth autocorrelation
par.stdZ    = 0.009;        % Productivity shock standard deviation
par.stdTau  = 0.008;        % Money growth shock standard deviation

% Initial variable values
init.z_lag      = 0;
init.tau_lag    = 0;
init.k_lag      = 0;

% Simulation options
opts.sim_periods    = 5000;  % Number of periods for simulation
opts.irf_periods    = 100;   % Number of periods calculated for impulse response function
opts.irf_disp       = 20;   % Number of periods displayed for impulse response function

%% Simulating the Model
% --------------------------------------------------------------------------------------------------
% Create shock process
rng(123);
epsZ    = par.stdZ   .* randn(1,opts.sim_periods);  % IRF shock proces: One shock in the first period and zero thereafter.
epsTau  = par.stdTau .* randn(1,opts.sim_periods);  % IRF shock proces: One shock in the first period and zero thereafter.
% Create simulation shock series
shock_sim.epsZ      = epsZ;
shock_sim.epsTau    = epsTau;
% Create orthogonal shock series: productivity
shock_prod.epsZ     = [epsZ(1) zeros(1,length(epsZ)-1)];
shock_prod.epsTau   = zeros(1,length(epsTau));
% Create orthogonal shock series: money growth
shock_money.epsZ     = zeros(1,length(epsZ));
shock_money.epsTau   = [epsTau(1) zeros(1,length(epsTau)-1)];

% Call the model and simulate the economy to get some results
[result_sim,udc_sim,stats_sim] = run_model(par,init,shock_sim,opts);
% Call the model and simulate impulse responses
result_prod     = run_model(par,init,shock_prod,opts);
result_money    = run_model(par,init,shock_money,opts);

%% Robustness Analysis
% --------------------------------------------------------------------------------------------------
% Create array of values for the capital share alpha
loop_values = [0.25 0.33 0.5];
% FOR-loop to iterate over the different values for alpha
for ii = 1:length(loop_values)
    par.alp = loop_values(ii);
    result_robust = run_model(par,init,shock_prod,opts);
    % Save structure in arrays to be able to loop over them
    output_robust(:,ii)         = transpose(result_robust.production);
    labor_robust(:,ii)          = transpose(result_robust.labor);
    consumption_robust(:,ii)    = transpose(result_robust.consumption);
    inflation_robust(:,ii)      = transpose(result_robust.inflation);
end

%% Plotting Impulse Response Funnctions
% --------------------------------------------------------------------------------------------------
% Plotting the results in a tiled figure (subplots)
figure('Name','Impulse Response Functions')
tiledlayout(2,4)
% Labor supply
nexttile
plot(result_prod.labor(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.labor(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Labor supply')
% Consumption
nexttile
plot(result_prod.consumption(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.consumption(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Consumption')
% Capital Stock
nexttile
plot(result_prod.capital(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.capital(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Capital Stock')
% Output
nexttile
plot(result_prod.production(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.production(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Output')
% Investment
nexttile
plot(result_prod.investment(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.investment(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Investment')
% Inflation
nexttile
plot(result_prod.inflation(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.inflation(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Inflation')
% Real Wage
nexttile
plot(result_prod.wage(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.wage(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Real Wage')
% Real Rental Rate
nexttile
plot(result_prod.interest(1:opts.irf_disp),'LineWidth',2)
hold on
plot(result_money.interest(1:opts.irf_disp),'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Real Rental Rate')

%% Plotting Simulations
% --------------------------------------------------------------------------------------------------
% Plotting simulated time series of the model economy
figure('Name','Simulation of the Economy')
tiledlayout(2,4)
% Labor supply
nexttile
plot(result_sim.labor,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Labor supply')
% Consumption
nexttile
plot(result_sim.consumption,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Consumption')
% Capital Stock
nexttile
plot(result_sim.capital,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Capital Stock')
% Output
nexttile
plot(result_sim.production,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Output')
% Investment
nexttile
plot(result_sim.investment,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Investment')
% Inflation
nexttile
plot(result_sim.inflation,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Inflation')
% Real Wage
nexttile
plot(result_sim.wage,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Real Wage')
% Real Rental Rate
nexttile
plot(result_sim.interest,'LineWidth',2)
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Real Rental Rate')

%% IRF Robustness Analysis
% --------------------------------------------------------------------------------------------------
% Plotting the results in a tiled figure (subplots)
figure('Name','Impulse Response Functions')
tiledlayout(2,2)
% Labor supply
nexttile
plot(labor_robust(1:opts.irf_disp,:),'LineWidth',2)
hold on
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Labor supply')
% Consumption
nexttile
plot(consumption_robust(1:opts.irf_disp,:),'LineWidth',2)
hold on
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Consumption')
% Output
nexttile
plot(output_robust(1:opts.irf_disp,:),'LineWidth',2)
hold on
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Output')
% Output
nexttile
plot(inflation_robust(1:opts.irf_disp,:),'LineWidth',2)
hold on
yline(0,'r')
hold off
axis tight
xlabel('Period')
ylabel('%-Deviation')
title('Inflation')
legend('\alpha = 0.25','\alpha = 0.33','\alpha = 0.5')

%% Model section
% --------------------------------------------------------------------------------------------------
function [out,udc,stats] = run_model(par,init,shock,opts)
% --------------------------------------------------------------------------------------------------
% Initialize
counter = 1;
% Initial states
z_lag   = init.z_lag;
tau_lag = init.tau_lag;
k_state = init.k_lag;

% *****************************************************
% Calculate undetermined coefficients
% *****************************************************
% Composite parameters
sig_1   = (1-par.betta*(1-par.delt))*(1-par.alp);
sig_2   = par.alp/((1-par.betta)/par.betta+par.delt*(1-par.alp));

% Solve for undetermined coefficients: Stable path for phiKK
AA = sig_2*(sig_1+par.gam+par.alp);
BB = (-1)*( sig_2*( (1-par.delt*(1-par.alp))*(sig_1+par.gam+par.alp)+par.gam+par.alp ) ...
        + ( par.gam+par.alp+(1-par.alp)*(1+par.delt*sig_2) )*( sig_1+par.alp ) );
CC = par.alp*(par.gam+par.alp+(1-par.alp)*(1+par.delt*sig_2)) ...
        + sig_2*(1-par.delt*(1-par.alp)*(par.gam+par.alp));
% Setting up matrix for quadratic equation solver
roots_matrix    = [AA BB CC];
% Solving for the quadratic equation
psiKK = roots(roots_matrix);
% Select stable root (saddle-path of the economy)
udc.psiKK   = psiKK(psiKK<1);
% Calculate rest of the undetermined coefficients for the stable root
udc.psiLK   = (-1)/(par.gam+par.alp+(1+par.delt*sig_2)*(1-par.alp)) * (sig_2/par.betta-par.alp-sig_2*udc.psiKK);
udc.psiCK   = par.alp - (par.gam+par.alp)*udc.psiLK;
% Calculate undetermined coefficients for productivity shock block
udc.psiLZ   = (sig_2*(1-par.alp)*(1-par.rhoZ)+par.rhoZ*sig_1-(udc.psiCK-sig_1*(udc.psiLK-1))*((1+par.delt*sig_2)*(1-par.alp)-(1-par.alp))) ...
            / (udc.psiCK-sig_1*(udc.psiLK-1)*((1+par.delt*sig_2)*(1-par.alp)+par.gam+par.alp)-par.rhoZ*sig_1+sig_2*(par.gam+par.alp)*(1-par.rhoZ));
udc.psiCZ   = (1-par.alp)-(par.gam+par.alp)*udc.psiLZ;
udc.psiKZ   = 1/sig_2*((1+par.delt*sig_2)*(1-par.alp)*(1+udc.psiLZ) - udc.psiCZ);
% Calculate undetermined coefficients for money growth shock block
udc.psiLTau = (udc.psiCK-sig_1*(udc.psiLK-1)) / ( sig_2*(par.rhoTau*sig_1-(1-par.rhoTau)*(par.gam+par.alp)) ...
            - (udc.psiCK-sig_1*(udc.psiLK-1))*((1+par.delt*sig_2)*(1-par.alp)+(par.gam+par.alp)) );
udc.psiCTau = (-1) - (par.gam+par.alp)*udc.psiLTau;
udc.psiKTau = 1/sig_2 * ( ((1+par.delt*sig_2)*(1-par.alp)+(par.gam+par.alp))*udc.psiLTau + 1 );
% Solving for investment undetermined coefficients
udc.psiXK   = 1/par.delt*( (udc.psiKK) - (1-par.delt) );
udc.psiXZ   = 1/par.delt*udc.psiKZ;
udc.psiXTau = 1/par.delt*udc.psiKTau;
% Solving for result undetermined coefficients
udc.psiYK   = (1-par.alp)*udc.psiLK + par.alp;
udc.psiYZ   = (1-par.alp)*(udc.psiLZ+1);
udc.psiYTau = (1-par.alp)*udc.psiLTau;
% Solving for inflation undetermined coefficients
udc.psiPK   = udc.psiCK*(1-udc.psiKK);
udc.psiPZ   = udc.psiCZ*(1-par.rhoZ) - udc.psiCK*udc.psiKZ;
udc.psiPTau = 1 + udc.psiCTau*(1-par.rhoTau) - udc.psiCK*udc.psiKTau;
% Solving for real wage undetermined coefficients
udc.psiWK   = par.alp*(1-udc.psiLK);
udc.psiWZ   = 1-par.alp*(1+udc.psiLZ);
udc.psiWTau = (-1)*par.alp*udc.psiLTau;
% Solving for real rental rate undetermined coefficients
udc.psiRK   = (1-par.alp)*(udc.psiLK-1);
udc.psiRZ   = (1-par.alp)*(1+udc.psiLZ);
udc.psiRTau = (1-par.alp)*udc.psiLTau;

% ***************************************************************
% Run a WHILE loop to create a model simulation across T periods
% ***************************************************************
z_state = zeros(1,opts.sim_periods);
tau_state= zeros(1,opts.sim_periods);
labor= zeros(1,opts.sim_periods);
capital= zeros(1,opts.sim_periods);
consumption= zeros(1,opts.sim_periods);
investment= zeros(1,opts.sim_periods);
production= zeros(1,opts.sim_periods);
inflation= zeros(1,opts.sim_periods);
wage= zeros(1,opts.sim_periods);
interest= zeros(1,opts.sim_periods);

while counter <= opts.sim_periods
    % Updating exogenous AR(1) processes
    z_state(counter)    = par.rhoZ*z_lag + shock.epsZ(counter);
    tau_state(counter)  = par.rhoTau*tau_lag + shock.epsTau(counter);
    % Calculating endogenous variables
    labor(counter)          = udc.psiLK*k_state + udc.psiLZ*z_state(counter) + udc.psiLTau*tau_state(counter);
    capital(counter)        = udc.psiKK*k_state + udc.psiKZ*z_state(counter) + udc.psiKTau*tau_state(counter);
    consumption(counter)    = udc.psiCK*k_state + udc.psiCZ*z_state(counter) + udc.psiCTau*tau_state(counter);
    investment(counter)     = udc.psiXK*k_state + udc.psiXZ*z_state(counter) + udc.psiXTau*tau_state(counter);
    production(counter)     = udc.psiYK*k_state + udc.psiYZ*z_state(counter) + udc.psiYTau*tau_state(counter);
    inflation(counter)      = udc.psiPK*k_state + udc.psiPZ*z_state(counter) + udc.psiPTau*tau_state(counter);
    wage(counter)           = udc.psiWK*k_state + udc.psiWZ*z_state(counter) + udc.psiWTau*tau_state(counter);
    interest(counter)       = udc.psiRK*k_state + udc.psiRZ*z_state(counter) + udc.psiRTau*tau_state(counter);
    % Update state variables
    k_state = capital(counter);
    z_lag   = z_state(counter);
    tau_lag = tau_state(counter);
    % Update counter
    counter = counter + 1;
end

% **************************************************************
% Statistics
% **************************************************************
% Standard deviations
stats.std_labor       = std(labor).*100;
stats.std_capital     = std(capital).*100;
stats.std_consumption = std(consumption).*100;
stats.std_investment  = std(investment).*100;
stats.std_production  = std(production).*100;
stats.std_inflation   = std(inflation).*100;
stats.std_wage        = std(wage).*100;
stats.std_interest    = std(interest).*100;

% Relative standard deviations
stats.rstd_labor          = stats.std_labor ./ stats.std_production;
stats.rstd_capital        = stats.std_capital ./ stats.std_production;
stats.rstd_consumption    = stats.std_consumption ./ stats.std_production;
stats.rstd_investment     = stats.std_investment ./ stats.std_production;
stats.rstd_inflation      = stats.std_inflation ./ stats.std_production;
stats.rstd_wage           = stats.std_wage ./ stats.std_production;
stats.rstd_interest       = stats.std_interest ./ stats.std_production;

% **************************************************************
% Save results (multiplying by 100 to get nice perecent numbers
% **************************************************************
out.labor       = labor.*100;
out.capital     = capital.*100;
out.consumption = consumption.*100;
out.investment  = investment.*100;
out.production  = production.*100;
out.inflation   = inflation.*100;
out.wage        = wage.*100;
out.interest    = interest.*100;

end