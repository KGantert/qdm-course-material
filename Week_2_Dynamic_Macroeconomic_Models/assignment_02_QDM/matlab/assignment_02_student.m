%% *****************************************************************************
% Quantitative Dynamic Macroeconomics
% Assignment 02: A dynamic CiA model
% Konstantin Gantert
% 26/10/2023
% ******************************************************************************

%% -----------------------------------------------------------------------------
% HOUSEKEEPING
% ------------------------------------------------------------------------------
clear all;  % Clear the workspace to prevent using any old variable or function
clc;        % Clear the command window for better visibility of new results

%% -----------------------------------------------------------------------------
% GENERAL SETUP: Parameters and Exogenous Variables
% ------------------------------------------------------------------------------
% Parameters (make sure to not use the exact spelling of greek letters as
% they might already be a build-in Matlab function.
betta   = 0.98;
nuu     = 4;
vphi    = 0.5;
kap     = ...
tauu    = ...
grow    = ...

% Initial productivity level
Z0      = 1;

% Gridsize and periods
gridsize = 40;
periods  = 50;

%% -----------------------------------------------------------------------------
% EXERCISE 3: Solving for the steady-state of the model
% ------------------------------------------------------------------------------
% Loop parameters
nuu_loop  = linspace(0.5,4,gridsize);
tauu_loop = ...

% Pre-allocating arrays to save results (for speed reasons)
L_solv      = zeros(length(nuu_loop),length(tauu_loop));
C_solv      = zeros(length(nuu_loop),length(tauu_loop));
r_solv      = zeros(length(nuu_loop),length(tauu_loop));
pii_solv    = zeros(length(nuu_loop),length(tauu_loop));
Z           = zeros(1,periods);
C_solv_grow = zeros(length(nuu_loop),length(tauu_loop),periods);

% Running a nested FOR-loop to calculate the impact on the steady-state of any
% combination of the two parameters within their intervals.
for ii = 1:length(nuu_loop) % First, loop over the grid for different labor supply elasticities
    for tt = ... % Second, loop over the grid for different money growth rates
        [labor, consumption, interest, inflation] = model_stst(vphi,kap,tauu_loop(tt),betta,nuu_loop(ii),grow);
        % Save model results for balanced growth path variables
        L_solv(ii,tt)   = labor;
        C_solv(ii,tt)   = consumption;
        r_solv(ii,tt)   = interest;
        pii_solv(ii,tt) = inflation;

        for hh = 1:periods
            % Calculate the steady-state level of productivity for 50 periods
            if hh == 1
                Z(1)  = Z0;
            else
                Z(hh) = ...;
            end
            % Calculate non-stationary consumption time series
            C_solv(ii,tt,hh) = Z(hh).*L_solv(ii,tt);
        end
    end
end

% ------------------------------------------------------------------------------
% Creating figures to display the results
figure('Name','Results to exercise 3 of assignment 02 (QDM)')
tt = tiledlayout(4,2);
% Labor plot (nuu loop)
nexttile
plot(nuu_loop,L_solv(:,5))
axis tight
ylabel('Labor supply')
xlabel('Labor supply elasticity')
title('Labor Supply')
% Labor plot (tauu loop)
nexttile
plot(tauu_loop,transpose(L_solv(12,:)))
axis tight
ylabel('Labor supply')
xlabel('Labor supply elasticity')
title('Labor Supply')
% GDP plot (nuu loop)
nexttile
plot(transpose(squeeze(C_solv(1:4:gridsize,5,:))))
axis tight
ylabel('Consumption level')
xlabel('Time')
title('Consumption')
% GDP plot (tauu loop)
nexttile
plot(transpose(squeeze(C_solv(12,1:4:gridsize,:))))
axis tight
ylabel('Consumption level')
xlabel('Time')
title('Consumption')
% Inflation Plot (nuu loop)
nexttile
plot(nuu_loop,pii_solv(:,5))
axis tight
ylabel('Inflation')
xlabel('Labor supply elasticity')
title('Inflation')
% Inflation Plot (tauu loop)
nexttile
plot(nuu_loop,pii_solv(12,:))
axis tight
ylabel('Inflation')
xlabel('Labor supply elasticity')
title('Inflation')
% Nominal interest rate plot (nuu loop)
nexttile
...
% Nominal interest rate plot (tauu loop)
nexttile
...
% Add title and labels for the overall figure (not possible with subplot)
title(tt,'Results to exercise 4 of assignment 02 (QDM)')

%% -----------------------------------------------------------------------------
% MODEL FUNCTION (STATIONARY MODEL)
% ------------------------------------------------------------------------------
% Exercise 3: Steady-state model equation
function [labor, consumption, interest, inflation] = model_stst(vphi,kap,tauu,betta,nuu,grow)
    labor           = ...;
    consumption     = ...;
    interest        = (1+tauu)/betta - 1;
    inflation       = (1+tauu)/(1+grow) - 1;
end