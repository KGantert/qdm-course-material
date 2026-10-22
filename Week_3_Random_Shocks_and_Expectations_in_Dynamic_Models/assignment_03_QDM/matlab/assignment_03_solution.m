%% *****************************************************************************
% Quantitative Dynamic Macroeconomics
% Assignment 03: A stochastic dynamic CiA model
% Konstantin Gantert
% Based on Code by Harold Cole with help from David Valencia
% 31/10/2023
% ******************************************************************************
%% HOUSEKEEPING
% ------------------------------------------------------------------------------
clear all;  % Clear the workspace to prevent using any old variable or function
clc;        % Clear the command window for better visibility of new results

%% PARAMETERS AND OPTIONS
% ------------------------------------------------------------------------------
% Parameters (make sure to not use the exact spelling of greek letters as
% they might already be a build-in Matlab function.
% Here, we use a structure "par." to save all parameters in one place
par.betta   = 0.98;         % Period discount rate
par.nuu     = 0.5;          % Inverse of Frisch labor supply elasticity
par.vphi    = 1;            % Leisure utility parameter
par.rho_t   = 0.5;          % Money growth autocorrelation
par.rho_g   = 0.5;          % Productivity growth autocorrelation
par.rho_d   = 0.5;          % Money loss autocorrelation

% Shock processes
shock.sig_t = 0.05;         % Standard deviation of money shock
shock.sig_g = 0.05;         % Standard deviation of growth shock
shock.sig_d = 0.02;         % Standard deviation of money loss cost

% Set initial states
exo.money       = 1;        % Initial money stock (normalization)
exo.Zprod       = 1;        % Initial productivity level (normalization)
exo.tauu_avg    = 0.05;     % Average money stock growth
exo.grow_avg    = 0.02;     % Average productivity growth
exo.del_avg     = 0.01;     % Average money loss

% Options
opt.periods     = 1000;     % Simulation horizon
opt.dist_approx = 20;       % Distribution approximation nodes
opt.corr_win    = 10;       % Long-term correlation window

%% CALL MODEL FUNCTION
% ------------------------------------------------------------------------------
[labor,cons,price,labor_social,cons_social,Q,tauu,grow,del,money,Zprod] ...
    = model_sim(opt,par,exo,shock);

%% UTILITY DIFFERENTIAL
% ------------------------------------------------------------------------------
% Function handle to calculate the difference between actual and social
% planner utility.
phi_cost = zeros(1,opt.periods);
% Re-set counter
counter = 1;
while counter <= opt.periods
    % Consumption equivalents function (leisure utility vphi*(1-L)^(1-nu)/(1-nu); requires nu ~= 1)
    util_cost = @(phii) ( log(cons_social(counter)) + par.vphi./(1-par.nuu).*(1-labor_social).^(1-par.nuu) ) ...
                        - ( (log((1+phii)*cons(counter)) + par.vphi./(1-par.nuu).*(1-labor(counter)).^(1-par.nuu)) );
    % Solve for consumption equivalents given by "phii" when util_cost = 0!
    options = optimset('Display','off');
    phi_cost(counter) = fsolve(util_cost,0.05,options) .* 100;
    % Update WHILE loop counter
    counter = counter + 1;
end

%% PLOTTING RESULTS
% ------------------------------------------------------------------------------
% Plots of Series
Dates = 1:opt.periods;

% Stationary Times Series plots
figure(1)
plot(Dates,labor./mean(labor),Dates,Q./mean(Q))
title('Time Series of Labor and Interest Rates from Model Simulation')
legend('Labor','Q')

% Plots of Nonstartionary Time Series
figure(2)
plot(Dates,cons,Dates,money,Dates,Zprod,Dates,price)
title('Consumption, Money, Zprod, and the Price Level')
legend('Cons','Money','Zprod','Price')

% Plots of Consumption Equivalents
figure(3)
plot(Dates,phi_cost)
title('Time Series of Consumption Equivalents')

%% CALCULATING STATISTICS
% ------------------------------------------------------------------------------
disp('Some Short-term Summary Statistics')

% Computing growth rates
gm      = log(money(2:opt.periods)) - log(money(1:opt.periods-1));
gc      = log(cons(2:opt.periods))  - log(cons(1:opt.periods-1));
gp      = log(price(2:opt.periods)) - log(price(1:opt.periods-1));
gpr     = log(Zprod(2:opt.periods)) - log(Zprod(1:opt.periods-1));

disp('    First Some Mean Growth Rates')
disp('    Money     Cons     Prices    Prod')
    [mean(gm) mean(gc) mean(gp) mean(gpr)]
    
disp('  ')
disp('   Then the Correlation Matrix')
    corrcoef([gm' gc' gp' gpr'])
    
disp('Some leads and lags of Money growth and Inflation')
disp( 'lagged current future money then inflation')
    
aa = length(gm);

corrcoef([gm(1:aa-2)' gm(2:aa-1)' gm(3:aa)' gp(1:aa-2)' gp(2:aa-1)' gp(3:aa)' ])
    
% Long Term Relationships

% computing growth rates
lgm = (log(money(opt.corr_win+1:opt.periods)) - log(money(1:opt.periods-opt.corr_win)))/opt.corr_win;
lgc = (log(cons(opt.corr_win+1:opt.periods)) - log(cons(1:opt.periods-opt.corr_win)))/opt.corr_win;
lgp = (log(price(opt.corr_win+1:opt.periods)) - log(price(1:opt.periods-opt.corr_win)))/opt.corr_win;
lgpr = (log(Zprod(opt.corr_win+1:opt.periods)) - log(Zprod(1:opt.periods-opt.corr_win)))/opt.corr_win;
    
% The Long-term Correlation Matrix
disp('   The Long-term Correlation Matrix')
corrcoef([lgm' lgc' lgp' lgpr'])

%% MODEL FUNCTION
% ------------------------------------------------------------------------------
function [labor,cons,price,labor_social,cons_social,Q,tauu,grow,del,money,Zprod] = model_sim(opt,par,exo,shock)

% RANDOM VARIABLES
% ------------------------------------------------------------------------------
% Set the seed of the random number generator for reproducability
rng(123456);

% Draw our random variables for 
% (i) our simulation of tau and g, and (ii) approximating the integral.
ep_t    = shock.sig_t*randn(1,opt.periods); % Money stock growth shocks
ep_g    = shock.sig_g*randn(1,opt.periods); % Productivity growth shocks
ep_d    = shock.sig_d*randn(1,opt.periods); % Money holding cost shocks

% Calculate mean growth rates of exogenous processes
B_t     = exo.tauu_avg*(1-par.rho_t);   % Constant to yield average money growth
B_g     = exo.grow_avg*(1-par.rho_g);   % Constant to yield average productivity growth
B_d     = exo.del_avg*(1-par.rho_d);    % Constant to yield average money loss cost

% Non-negativity constraints on growth rates
ep_t    = max(-(exo.tauu_avg), ep_t);   % bounding neg money shocks
ep_g    = max(-(exo.grow_avg), ep_g);   % ditto growth shocks

% Set initial values for exogenous processes
tauu    = exo.tauu_avg;     % Long-term average money growth AR(1) process
grow    = exo.grow_avg;     % Long-term average productivity growth AR(1) process
del     = exo.del_avg;      % Long-term average money loss AR(1) process
money   = exo.money;        % Initial money stock
Zprod   = exo.Zprod;        % Initial productivity level

% EXOGENOUS GROWTH PROCESSES
% ------------------------------------------------------------------------------
% Set initial counter for WHILE loop
counter = 1;
% WHILE loop that updates vectors of growth variables until end period T+1 is reached
while counter < opt.periods+1
    % Money growth rate: Each iteration one value is added to the existing vector
    tauu    = [tauu par.rho_t*tauu(counter)+B_t+ep_t(counter)]; 
    % Productivity growth rate
    grow    = [grow par.rho_g*grow(counter)+B_g+ep_g(counter)];
    % Money loss share
    del     = [del par.rho_d*del(counter)+B_d+ep_d(counter)];
    % Money stock
    money   = [money (1+tauu(counter+1))*money(counter)];
    % Productivity level
    Zprod   = [Zprod (1+grow(counter+1))*Zprod(counter)];
    % Update counter variable by one per iteration
    counter = counter + 1;
end

% To line everything up note that the money growth is between t and t+1
% while the productivity growth rate is between t-1 and t.
tauu    = tauu(2:opt.periods+1);      % starts with tau realized in period 1 (M_2 = (1-del_1)*(1+tau_1)*M_1)
grow    = grow(1:opt.periods);        % ditto
del     = del(2:opt.periods+1);       % ditto
money   = money(1:opt.periods);       % this is beginning of period money so shifted back
Zprod   = Zprod(2:opt.periods+1);     % this is productivity hit by g_t

%% CONSTRUCTING EQUILIBRIUM OBJECTS
% ------------------------------------------------------------------------------
% Labor supply
options = optimset('Display','off');
for ii = 1:length(del)
    labor_fct = @(labor) par.vphi.*labor./(1-labor).^par.nuu - par.betta.*(1-del(ii))./(1+tauu(ii));
    labor(ii) = fsolve(labor_fct, 0.5, options);
end
% Consumption
cons            = Zprod .* labor;
% Price level
price           = money ./ cons;
% Labor supply (social planner)
labor_social_fct = @(labor_social) par.vphi.*labor_social./(1-labor_social).^par.nuu - 1;
labor_social = fsolve(labor_social_fct, 0.5, options);
% Consumption (social planner)
cons_social     = Zprod .* labor_social;

%% CONSTRUCTING EXPECTED NOMINAL INTEREST RATE
% ------------------------------------------------------------------------------
% Reset WHILE loop counter for next loop
counter = 1;
% Approximate distribution of future money growth shocks
shot = shock.sig_t*randn(1,opt.dist_approx);   % money shocks - select # of shocks to determine quality of approx.
shot = max(-(exo.tauu_avg),shot);       % bounding neg money shocks
shod = shock.sig_d*randn(1,opt.dist_approx);
shod = max(-(exo.del_avg),shod);
% WHILE LOOP to calculate "q" (inverse of nominal interest rate)
while counter <= opt.periods
    % Calculate "certain" part of rhs of "q"
    Q(counter) = ( par.betta/(( 1-del(counter) )) );
    % Calculate possible shock distribution tomorrow given state today
    taus = par.rho_t.*tauu(counter) + B_t + shot;
    dels = par.rho_d.*del(counter)  + B_d + shod;
    % Caculate "uncertain" part of rhs of "q" (use muu_(t+1) for labor)
    Q_tom = (1-transpose(dels))*(1./(1-taus));
    % Combine "certain" and "uncertain" part of rhs of "q" to include
    % uncertainty in realization of "q" today
    Q(counter) = Q(counter)*mean( Q_tom , "all" );
    % Update WHILE loop counter
    counter = counter + 1;
end
% -----------------------End of Model Function----------------------------------
end