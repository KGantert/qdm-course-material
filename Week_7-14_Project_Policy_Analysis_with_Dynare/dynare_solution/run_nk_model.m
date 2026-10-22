%% ************************************************************************
% Quantitative Dynamic Macroeconomics
% Project: New-Keynesian (NK) Model with Capital and Fiscal Policy
% Konstantin Gantert
% 12/04/2026
% *************************************************************************
%% ------------------------------------------------------------------------
% .:. Model Selection and Housekeeping .:.
% -------------------------------------------------------------------------
% Clear workspace
clear all;
clc;

% Fiscal block (extension of the baseline model): set to "1" to switch on government spending,
% public liabilities, the lump-sum tax rule and the tax and public-debt shocks
fiscal          = 1;

% Dynare options
approxorder     = 1;        % Set Approximation Order
irfperiod       = 20;       % Set Impulse Response Function Periods
simperiod       = 20000;    % Set Simulation Periods
replicnumber    = 10;       % Set Number of Replications
simreplicnumber = 10;       % Set Number of Simulation Replications
dropnumber      = 1000;     % Set Number of Simulation Periods dropped

% Looping Parameters
run_loop        = 0;        % Set to "1" if you want to execute the FOR-loop!
loopcount       = 3;
loop_robustness = linspace(1,3,loopcount);

%% ------------------------------------------------------------------------
% Parameters
% -------------------------------------------------------------------------
% Baseline calibration (identical to the student baseline model)
% Households
par.betta   = 0.99;
par.sig     = 1;
par.gam     = 2;
par.nuu     = 1;
par.delK    = 0.025;
par.phiX    = 4;

% Firms
par.alp     = 0.3;
par.rhoo    = 0.9;
par.kap     = 60;

% Government (taxes are basically zero in the baseline)
par.tauL    = 1e-5;
par.tauK    = 1e-5;
par.tauC    = 1e-5;

% Monetary policy
par.tetPi   = 1.5;
par.tetY    = 0.5;
par.tetR    = 0.5;

% Shock standard deviations
par.stdM    = 0.001;
par.stdZ    = 0.0064;
par.stdP    = 0.05;
par.stdX    = 0.006;
par.stdV    = 0.025;
par.stdC    = 0.01;

% Shock autocorrelations
par.rhoM    = 0.5;
par.rhoZ    = 0.8;
par.rhoP    = 0.8;
par.rhoX    = 0.8;
par.rhoV    = 0.8;
par.rhoC    = 0.9;

% Fiscal block (only used if fiscal = 1): taxes and fiscal parameters
if fiscal == 1
    par.tauL    = 0.2;
    par.tauK    = 0.2;
    par.tauC    = 0.2;
    par.lgY_ss  = 0.1;      % Public-debt-to-GDP steady-state target
    par.gamLG   = 0.1;      % Fiscal rule coefficient w.r.t. government liabilities
    par.stdT    = 0.02;
    par.stdL    = 0.01;
    par.rhoT    = 0;
    par.rhoL    = 0.8;
end

%% ------------------------------------------------------------------------
% Impulse Response Analysis - Default Model
% -------------------------------------------------------------------------
% Call Dynare to initialize model (YOU DO NOT HAVE TO CHANGE ANYTHING HERE)
eval(['dynare nk_model.dyn -Dfiscal=' num2str(fiscal) ' -Dreplic_number=' num2str(replicnumber) ...
	' -Dsimul_replic_number=' num2str(simreplicnumber) ' -Ddrop_number=' num2str(dropnumber) ...
	' -Dapprox_order=' num2str(approxorder) ' -Dirf_periods=' num2str(irfperiod) ...
	' -Dsim_periods=' num2str(simperiod) ' noclearall;']);

% Calculate Steady States (YOU DO NOT HAVE TO CHANGE ANYTHING HERE)
for ii = 1:length(oo_.dr.ys)
	eval(['stst.' strjoin(cellstr(M_.endo_names(ii))) ' = oo_.dr.ys(' num2str(ii) ');']);
end


%% ------------------------------------------------------------------------
% IRF Plotting - Scenario Shocks
% -------------------------------------------------------------------------
% Impulse Responses to All Scenario Shocks (positive innovations)
shock_id   = {'M','P','Z','X','V','C'};
shock_name = {'Monetary Policy','Cost-Push','TFP','Investment','Velocity','COVID'};
if fiscal == 1
    shock_id   = [shock_id,   {'T','L'}];
    shock_name = [shock_name, {'Tax','Public Debt'}];
end
% Panels: variable, title, and type ('lev' = %-deviation from steady state, 'abs' = deviation in percentage points)
panels = {'Y','Real GDP','lev'; 'pii','Inflation','abs'; 'L','Total Hours','lev'; ...
          'K','Capital Stock','lev'; 'C','Consumption','lev'; 'w','Real Wage','lev'; ...
          'rB','Interest Rate','lev'; 'mc','Real Marginal Costs','lev'};
if fiscal == 1
    panels = [panels; {'lg','Public Debt','lev'}];
end

figure('Name','IRFs to all scenario shocks')
tiledlayout(3,3)
for pp = 1:size(panels,1)
    nexttile
    title(panels{pp,2})
    hold on
    for ss = 1:numel(shock_id)
        irf = oo_.irfs.([panels{pp,1} '_e' shock_id{ss}]);
        if strcmp(panels{pp,3},'lev')
            irf = irf./stst.(panels{pp,1});
        end
        plot(irf.*100,'LineWidth',2)
    end
    yline(0,'r')
    hold off
    axis tight
    xlabel('Periods')
    ylabel('%-Dev. St.St.')
end
legend(shock_name)

%% ------------------------------------------------------------------------
% Impulse Response Analysis - Robustness Analysis (FOR loops)
% -------------------------------------------------------------------------

if run_loop == 1

for tt = 1:length(loop_robustness)
    % Set inverse Frisch elasticity of labor supply
    par.gam = loop_robustness(tt);
    % Call Dynare to initialize model (YOU DO NOT HAVE DO CHANGE ANYTHING HERE)
    eval(['dynare nk_model.dyn -Dfiscal=' num2str(fiscal) ' -Dreplic_number=' num2str(replicnumber) ...
	    ' -Dsimul_replic_number=' num2str(simreplicnumber) ' -Ddrop_number=' num2str(dropnumber) ...
	    ' -Dapprox_order=' num2str(approxorder) ' -Dirf_periods=' num2str(irfperiod) ...
	    ' -Dsim_periods=' num2str(simperiod) ' noclearall;']);

    % Calculate Steady States (YOU DO NOT HAVE DO CHANGE ANYTHING HERE)
    for ii = 1:length(oo_.dr.ys)
	    eval(['stst.' strjoin(cellstr(M_.endo_names(ii))) ' = oo_.dr.ys(' num2str(ii) ');']);
    end

    % Save productivity IRFs of each iteration
    output_eZ(:,tt)         = Y_eZ./stst.Y;
    inflation_eZ(:,tt)      = pii_eZ;
    hours_eZ(:,tt)          = L_eZ./stst.L;
    capital_eZ(:,tt)        = K_eZ./stst.K;
    consumption_eZ(:,tt)    = C_eZ./stst.C;
    wage_eZ(:,tt)           = w_eZ./stst.w;
    interest_rate_eZ(:,tt)     = rB_eZ./stst.rB;
    marginal_cost_eZ(:,tt)  = mc_eZ./stst.mc;
    % Save IRFs of each iteration
    output_eM(:,tt)         = Y_eM./stst.Y;
    inflation_eM(:,tt)      = pii_eM;
    hours_eM(:,tt)          = L_eM./stst.L;
    capital_eM(:,tt)        = K_eM./stst.K;
    consumption_eM(:,tt)    = C_eM./stst.C;
    wage_eM(:,tt)           = w_eM./stst.w;
    interest_rate_eM(:,tt)     = rB_eM./stst.rB;
    marginal_cost_eM(:,tt)  = mc_eM./stst.mc;

end

% Impulse Responses Productivity
figure('Name','IRFs to a positive productivity shock (robustness)')
tiledlayout(3,3)

nexttile
title('Real GDP')
hold on
plot(output_eZ.*100,'LineWidth',2);
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Inflation')
hold on
plot(inflation_eZ.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Total Hours')
hold on
plot(hours_eZ.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Capital Stock')
hold on
plot(capital_eZ.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Consumption')
hold on
plot(consumption_eZ.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Real Wage')
hold on
plot(wage_eZ.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Bond Price')
hold on
plot(interest_rate_eZ.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Real Marginal Costs')
hold on
plot(marginal_cost_eZ.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')
legend('\gamma = 1','\gamma = 2','\gamma = 3')

% Impulse Responses Productivity
figure('Name','IRFs to a positive monetary policy shock (robustness)')
tiledlayout(3,3)

nexttile
title('Real GDP')
hold on
plot(output_eM.*100,'LineWidth',2);
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Inflation')
hold on
plot(inflation_eM.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Total Hours')
hold on
plot(hours_eM.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Capital Stock')
hold on
plot(capital_eM.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Consumption')
hold on
plot(consumption_eM.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Real Wage')
hold on
plot(wage_eM.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Bond Price')
hold on
plot(interest_rate_eM.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Real Marginal Costs')
hold on
plot(marginal_cost_eM.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')
legend('\gamma = 1','\gamma = 2','\gamma = 3')

end

% ----------------------------- End of File -------------------------------