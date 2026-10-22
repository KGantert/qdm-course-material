%% ************************************************************************
% Quantitative Dynamic Macroeconomics
% Lecture 07: New-Keynesian (NK) Model
% Konstantin Gantert
% 06/04/2026
% *************************************************************************
%% ------------------------------------------------------------------------
% .:. Model Selection and Housekeeping .:.
% -------------------------------------------------------------------------
% Clear workspace
clear all;
clc;

% Dynare options
approxorder     = 1;        % Set Approximation Order
irfperiod       = 20;       % Set Impulse Response Function Periods
simperiod       = 20000;    % Set Simulation Periods
replicnumber    = 10;       % Set Number of Replications
simreplicnumber = 10;       % Set Number of Simulation Replications
dropnumber      = 1000;     % Set Number of Simulation Periods dropped

% Name of the exported IRF figure: 'with_capital' (alpha = 1/3, delta = 0.03 on the slide) or
% 'without_capital' (marginal capital: set par.alp close to 0 and par.delK = 1 below)
figure_name     = 'without_capital';

% Looping Parameters
run_loop        = 0;        % Set to "0" for default; set to "1" if you want to execute the FOR-loop (robustness analysis)!
loopcount       = 3;
loop_robustness = linspace(0,120,loopcount);    % Robustness wrt price adjustment cost parameter

%% ------------------------------------------------------------------------
% Parameters
% -------------------------------------------------------------------------
% Deep parameters
par.betta   = 0.98;         % Discount factor
par.sig     = 1;            % Risk-aversion
par.gam     = 1/0.72;       % Inverse Frisch elasticity
par.vphi    = 1;            % Labor disutility level
par.alp     = 0.33;         % Capital elasticity of production
par.delK    = 0.025;        % Capital depreciation rate
par.rhoo    = 0.9;          % Inverse steady-state price markup
par.kap     = 60;           % Price adjustment cost
par.nuu     = 0.5;          % Inverse money velocity (M/(P*C))
par.phiX    = 4;            % Investment adjustment cost

% Fiscal policy and taxes
par.tauL    = 0;            % Proportional labor income tax
par.tauK    = 0;            % Proportional capital income tax

% Monetary policy
par.tetR    = 0;            % Interest rate smoothing
par.tetPi   = 1.5;          % Taylor coefficient wrt inflation
par.tetY    = 0;            % Taylor coefficient wrt output
par.tetGap  = 0;            % Taylor coefficient wrt output gap

% Shock processes
par.stdZ    = 0.01;         % Std.dev. productivity shock
par.stdM    = 0.005;        % Std.dev. monetary policy shock
par.stdP    = 0.05;         % Std.dev. cost-push shock
par.rhoZ    = 0.9;          % Autocorrelation productivity shock
par.rhoM    = 0.5;          % Autocorrelation monetary policy shock
par.rhoP    = 0.5;          % Autocorrelation cost-push shock

%% ------------------------------------------------------------------------
% Impulse Response Analysis - Default Model
% -------------------------------------------------------------------------
% Call Dynare to initialize model (YOU DO NOT HAVE TO CHANGE ANYTHING HERE)
eval(['dynare nk_model.dyn -Dreplic_number=' num2str(replicnumber) ...
	' -Dsimul_replic_number=' num2str(simreplicnumber) ' -Ddrop_number=' num2str(dropnumber) ...
	' -Dapprox_order=' num2str(approxorder) ' -Dirf_periods=' num2str(irfperiod) ...
	' -Dsim_periods=' num2str(simperiod) ' noclearall;']);

% Calculate Steady States (YOU DO NOT HAVE DO CHANGE ANYTHING HERE)
for ii = 1:length(oo_.dr.ys)
	eval(['stst.' strjoin(cellstr(M_.endo_names(ii))) ' = oo_.dr.ys(' num2str(ii) ');']);
end

% Impulse Responses to Productivity, Monetary Policy and Cost-Push Shocks
figure('Name','IRFs to productivity, monetary policy and cost-push shocks')
tiledlayout(3,3)

nexttile
title('Real GDP')
hold on
plot(Y_eZ./stst.Y.*100,'LineWidth',2);
plot(Y_eM./stst.Y.*100,'LineWidth',2);
plot(Y_eP./stst.Y.*100,'LineWidth',2);
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Output Gap')
hold on
plot(Y_Gap_eZ.*100,'LineWidth',2)
plot(Y_Gap_eM.*100,'LineWidth',2)
plot(Y_Gap_eP.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Inflation')
hold on
plot(pii_eZ.*100,'LineWidth',2)
plot(pii_eM.*100,'LineWidth',2)
plot(pii_eP.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Total Hours')
hold on
plot(L_eZ./stst.L.*100,'LineWidth',2)
plot(L_eM./stst.L.*100,'LineWidth',2)
plot(L_eP./stst.L.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Capital Stock')
hold on
plot(K_eZ./stst.K.*100,'LineWidth',2)
plot(K_eM./stst.K.*100,'LineWidth',2)
plot(K_eP./stst.K.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Consumption')
hold on
plot(C_eZ./stst.C.*100,'LineWidth',2)
plot(C_eM./stst.C.*100,'LineWidth',2)
plot(C_eP./stst.C.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Real Wage')
hold on
plot(w_eZ./stst.w.*100,'LineWidth',2)
plot(w_eM./stst.w.*100,'LineWidth',2)
plot(w_eP./stst.w.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Nominal Interest Rate')
hold on
plot(rB_eZ./stst.rB.*100,'LineWidth',2)
plot(rB_eM./stst.rB.*100,'LineWidth',2)
plot(rB_eP./stst.rB.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')

nexttile
title('Real Marginal Costs')
hold on
plot(mc_eZ./stst.mc.*100,'LineWidth',2)
plot(mc_eM./stst.mc.*100,'LineWidth',2)
plot(mc_eP./stst.mc.*100,'LineWidth',2)
yline(0,'r')
hold off
axis tight
xlabel('Periods')
ylabel('%-Dev. St.St.')
legend('Productivity','Policy','Cost-Push')

% Export figure for the slides (figure_name is set in the housekeeping section)
exportgraphics(gcf,fullfile('..','latex','figures',['irfs_' figure_name '.eps']),'ContentType','vector')

%% ------------------------------------------------------------------------
% Impulse Response Analysis - Robustness Analysis (FOR loops)
% -------------------------------------------------------------------------

if run_loop == 1

for tt = 1:length(loop_robustness)
    % Set Inflation Targeting Parameter
    par.kap = loop_robustness(tt);
    % Call Dynare to initialize model (YOU DO NOT HAVE DO CHANGE ANYTHING HERE)
    eval(['dynare nk_model.dyn -Dreplic_number=' num2str(replicnumber) ...
	    ' -Dsimul_replic_number=' num2str(simreplicnumber) ' -Ddrop_number=' num2str(dropnumber) ...
	    ' -Dapprox_order=' num2str(approxorder) ' -Dirf_periods=' num2str(irfperiod) ...
	    ' -Dsim_periods=' num2str(simperiod) ' noclearall;']);

    % Calculate Steady States (YOU DO NOT HAVE DO CHANGE ANYTHING HERE)
    for ii = 1:length(oo_.dr.ys)
	    eval(['stst.' strjoin(cellstr(M_.endo_names(ii))) ' = oo_.dr.ys(' num2str(ii) ');']);
    end

    % Save productivity IRFs of each iteration
    output_eZ(:,tt)         = Y_eZ./stst.Y;
    output_gap_eZ(:,tt)     = Y_Gap_eZ;
    inflation_eZ(:,tt)      = pii_eZ;
    hours_eZ(:,tt)          = L_eZ./stst.L;
    capital_eZ(:,tt)        = K_eZ./stst.K;
    consumption_eZ(:,tt)    = C_eZ./stst.C;
    wage_eZ(:,tt)           = w_eZ./stst.w;
    interest_eZ(:,tt)       = rB_eZ./stst.rB;
    marginal_cost_eZ(:,tt)  = mc_eZ./stst.mc;
    money_grow_eZ(:,tt)     = tauu_eZ;
    % Save IRFs of each iteration
    output_eM(:,tt)         = Y_eM./stst.Y;
    output_gap_eM(:,tt)     = Y_Gap_eM;
    inflation_eM(:,tt)      = pii_eM;
    hours_eM(:,tt)          = L_eM./stst.L;
    capital_eM(:,tt)        = K_eM./stst.K;
    consumption_eM(:,tt)    = C_eM./stst.C;
    wage_eM(:,tt)           = w_eM./stst.w;
    interest_eM(:,tt)       = rB_eM./stst.rB;
    marginal_cost_eM(:,tt)  = mc_eM./stst.mc;
    money_grow_eM(:,tt)     = tauu_eM;

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
title('Money Grow')
hold on
plot(money_grow_eZ.*100,'LineWidth',2)
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
title('Nominal Interest Rate')
hold on
plot(interest_eZ.*100,'LineWidth',2)
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
legend('\kappa = 0','\kappa = 120','\kappa = 240')

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
title('Money Growth')
hold on
plot(money_grow_eM.*100,'LineWidth',2)
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
title('Nominal Interest Rate')
hold on
plot(interest_eM.*100,'LineWidth',2)
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
legend('\kappa = 0','\kappa = 120','\kappa = 240')

end

% ----------------------------- End of File -------------------------------