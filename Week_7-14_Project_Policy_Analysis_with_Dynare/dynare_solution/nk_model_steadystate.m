function [ys,params,check] = nk_model_steadystate(ys,exo,M_,options_)

% read out parameters to access them with their name
NumberOfParameters = M_.param_nbr;
for ii = 1:NumberOfParameters
  paramname = M_.param_names{ii};
  eval([ paramname ' = M_.params(' int2str(ii) ');']);
end
% initialize indicator
check = 0;

% Is the fiscal block switched on? (government liabilities "lg" are part of the model then)
fiscal = any(strcmp(M_.endo_names,'lg'));

%% Model equations block - Default and Natural Model
% Shock processes
sM      = 0;
sP      = 0;
sZ      = 0;
sX      = 0;
sV      = 0;
sC      = 0;
sT      = 0;
sL      = 0;

% Inflation
pii     = 0;
cp      = 0;
cpp     = 0;
% Variable lump-sum tax (zero in steady state, only part of the model with the fiscal block)
tauT    = 0;
% Investment adjustment cost
ci      = 0;
cii     = 0;
% Nominal interest rate
rB      = 1/betta - 1;
% Labor supply
L       = 1;
% Cash-in-advance constraint
muu     = betta/(nuu-betta*(nuu-1));
% Marginal cost
mc      = rhoo;
% Capital-labor ratio
kl = ( alp*rhoo*(1-tauK)/((1-betta*(1-delK))/betta) )^(1/(1-alp));
% Government spending share of output (fiscal block only)
if fiscal
    gs = (1+rB/(1+rB)*(nuu+tauC))^(-1) ...
            * ( rB/(1+rB)*(nuu+tauC)*(1-delK*kl^(1-alp)) ...
                - lgY_ss*rB/(1+rB) ...
                + (tauL*(1-alp)+tauK*alp)*mc );
else
    gs = 0;
end
% Consumption-labor ratio
cl = (1-gs)*kl^(alp) - delK*kl ;
% Labor disutility parameter given normalization L=1
vphi    = (1-alp)*rhoo*(1-tauL)/(1+tauC)*muu ...
           * kl^(alp) * cl^(-sig);
% Private consumption
C       = cl*L;
% Capital stock
K       = kl*L;
% Money supply
m       = C*nuu*(1+tauC+tauT);
% Private investment
X       = delK*K;
% Real GDP / output
Y       = L^(1-alp)*K^alp;
% Real wage
w       = (1-alp)*Y/L*mc;
% Marginal utility
muc     = C^(-sig);
% Private capital law of motion penalty price
tet     = muu;
% Capital interest rate
rK      = alp*Y/K*mc;
% Government spending and public liabilities implied by the government budget constraint (fiscal block only)
if fiscal
    g_ss    = gs*Y;
    lg      = m - (1+rB)/rB*( g_ss-(tauC)*C-(tauL)*w*L-(tauK)*rK*K );
end

%% end own model equations

params=NaN(NumberOfParameters,1);
for iter = 1:length(M_.params) %update parameters set in the file
  eval([ 'params(' num2str(iter) ') = ' M_.param_names{iter} ';' ])
end

NumberOfEndogenousVariables = M_.orig_endo_nbr; %auxiliary variables are set automatically
for ii = 1:NumberOfEndogenousVariables
  varname = M_.endo_names{ii};
  eval(['ys(' int2str(ii) ') = ' varname ';']);
end
