%% ************************************************************************
% Quantitative Dynamic Macroeconomics
% Lecture 05: Capital and taxes -- balanced-growth-path (BGP) tax revenues
% Konstantin Gantert
% *************************************************************************
% Computes the BGP of the cash-in-advance model with capital, labor taxes tau_L and
% capital taxes tau_K (slides "The Impact of Taxes on the Economy") on a grid of tax
% rates and exports the figures shown on the slides to ../latex/figures/:
%
%   total_tax_revenue.eps          total revenue over (tau_K, tau_L)
%   labor_tax_revenue.eps          labor tax revenue over (tau_K, tau_L)
%   capital_tax_revenue.eps        capital tax revenue over (tau_K, tau_L)
%   consumption_fixed_revenue.eps  consumption along the iso-revenue line of (tau_K = 0.3, tau_L = 0)
%   labor_fixed_revenue.eps        labor along the same iso-revenue line
%
% Needs Matlab R2020a or newer (exportgraphics). Run from this folder.
%% ------------------------------------------------------------------------
% HOUSEKEEPING
%--------------------------------------------------------------------------
clear all;
clc;
export_figures = 1;     % Set to "0" to skip exporting the figures
fig_folder     = fullfile('..','latex','figures');

%% ------------------------------------------------------------------------
% CALIBRATION (slide "Quantitative Analysis: Setup")
%--------------------------------------------------------------------------
par.gam   = 0.5;        % Labor-disutility curvature
par.alp   = 1/3;        % Capital elasticity of production
par.betta = 1/1.01;     % Discount factor
par.g     = 0.01;       % (Net) growth rate of productivity, 1 + g = 1.01
par.tau   = 0.02;       % (Net) money growth rate, 1 + tau = 1.02
par.delta = 0.08;       % Depreciation rate
par.Z1    = 1;          % Initial productivity level

%% ------------------------------------------------------------------------
% REVENUE SURFACES OVER A GRID OF TAX RATES
%--------------------------------------------------------------------------
tK_grid = 0:0.05:0.8;
tL_grid = 0:0.05:0.8;
[TK,TL] = meshgrid(tK_grid,tL_grid);

REV = zeros(size(TK)); REV_L = REV; REV_K = REV;
for ii = 1:numel(TK)
    b = bgp(TL(ii),TK(ii),par);
    REV(ii)   = b.rev;
    REV_L(ii) = b.rev_L;
    REV_K(ii) = b.rev_K;
end

plot_scatter3(TK,TL,REV,  'Capital taxes','Labor taxes','Total tax revenue',  fullfile(fig_folder,'total_tax_revenue.eps'),  export_figures);
plot_scatter3(TK,TL,REV_L,'Capital taxes','Labor taxes','Labor tax revenue',  fullfile(fig_folder,'labor_tax_revenue.eps'),  export_figures);
plot_scatter3(TK,TL,REV_K,'Capital taxes','Labor taxes','Capital tax revenue',fullfile(fig_folder,'capital_tax_revenue.eps'),export_figures);

% Revenue-maximizing tax rates
[~,imax] = max(REV(:));
fprintf('Revenue-maximizing rates on the grid: tau_L = %.2f, tau_K = %.2f, revenue = %.3f\n',TL(imax),TK(imax),REV(imax));
fine = 0:0.01:0.99;
rev_L_only = arrayfun(@(t) bgp(t,0,par).rev,fine);
rev_K_only = arrayfun(@(t) bgp(0,t,par).rev,fine);
[~,iL] = max(rev_L_only);
[~,iK] = max(rev_K_only);
fprintf('Only labor taxes:   tau_L* = %.2f\n',fine(iL));
fprintf('Only capital taxes: tau_K* = %.2f\n',fine(iK));

%% ------------------------------------------------------------------------
% CONSUMPTION AND LABOR HOLDING REVENUE FIXED (tau_K = 0.3, tau_L = 0)
%--------------------------------------------------------------------------
R0     = bgp(0,0.3,par).rev;
tK_fix = 0:0.05:0.8;
tL_fix = zeros(size(tK_fix));
C_fix  = zeros(size(tK_fix));
L_fix  = zeros(size(tK_fix));
for kk = 1:numel(tK_fix)
    % Labor tax rate that delivers the revenue R0 for the given capital tax rate
    tL_fix(kk) = fzero(@(t) bgp(t,tK_fix(kk),par).rev - R0,[-0.5 0.5]);
    b          = bgp(tL_fix(kk),tK_fix(kk),par);
    C_fix(kk)  = b.C;
    L_fix(kk)  = b.L;
end
plot_scatter3(tK_fix,tL_fix,C_fix,'Capital taxes','Labor taxes','Consumption (fixed revenue)',fullfile(fig_folder,'consumption_fixed_revenue.eps'),export_figures);
plot_scatter3(tK_fix,tL_fix,L_fix,'Capital taxes','Labor taxes','Labor (fixed revenue)',      fullfile(fig_folder,'labor_fixed_revenue.eps'),      export_figures);

%% ------------------------------------------------------------------------
% LOCAL FUNCTIONS
%--------------------------------------------------------------------------
function b = bgp(tL,tK,par)
% BGP of the model with taxes: labor, capital, output, consumption and tax revenues
% (real, in units of Y_1).
    ZL_K = ((1/(par.alp*(1-tK))) * ((1+par.g)/par.betta - 1 + par.delta))^(1/(1-par.alp));  % Z L / K
    K_L  = par.Z1/ZL_K;                                                                      % K / L
    C_L  = par.Z1^(1-par.alp)*K_L^par.alp - (par.g+par.delta)*K_L;                           % C / L
    L    = (par.betta/(1+par.tau)/C_L*(1-tL)*(1-par.alp)*par.Z1^(1-par.alp)*K_L^par.alp)^(1/(1+par.gam));
    K    = K_L*L;
    Y    = (par.Z1*L)^(1-par.alp)*K^par.alp;
    b.L     = L;
    b.K     = K;
    b.Y     = Y;
    b.C     = C_L*L;
    b.rev_L = tL*(1-par.alp)*Y;
    b.rev_K = tK*par.alp*Y;
    b.rev   = (tL*(1-par.alp) + tK*par.alp)*Y;
end

function plot_scatter3(x,y,z,xl,yl,zl,path,do_export)
% 3D scatter plot of a surface (unfilled markers) and export to EPS
    figure;
    scatter3(x(:),y(:),z(:),20,'b');
    xlabel(xl); ylabel(yl); zlabel(zl);
    grid on; box on;
    if do_export, exportgraphics(gcf,path,'ContentType','vector'); end
end
