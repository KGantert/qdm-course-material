function [ys,params,check] = nk_model_steadystate(ys,exo,M_,options_)

%% read out parameters to access them with their name
% -------------------------------------------------------------------------
NumberOfParameters = M_.param_nbr;
for ii = 1:NumberOfParameters
  paramname = M_.param_names{ii};
  eval([ paramname ' = M_.params(' int2str(ii) ');']);
end
% initialize indicator
check = 0;

%% Model equations block - Default and Natural Model
% -------------------------------------------------------------------------

% Shock processes
sM      = 0;
sZ      = 0;
% Inflation
pii     = 0;
cp      = 0;
cpp     = 0;
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
kl      = ( alp*rhoo*(1-tauK)/((1-betta*(1-delK))/betta) )^(1/(1-alp));
% Income-labor ratio
yl      = kl^alp;
% Consumption-labor ratio
cl      = kl^(alp) - delK*kl ;
% Labor disutility parameter given normalization L=1
vphi    = (1-alp)*rhoo*(1-tauL)/(1+tauC)*muu ...
           * kl^(alp) * cl^(-sig);
% Private consumption
C       = cl*L;
% Capital stock
K       = kl*L;
% Money supply
m       = (nuu)*(1+tauC)*C;
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

%% end own model equations
% -------------------------------------------------------------------------

params=NaN(NumberOfParameters,1);
for iter = 1:length(M_.params) %update parameters set in the file
  eval([ 'params(' num2str(iter) ') = ' M_.param_names{iter} ';' ])
end

NumberOfEndogenousVariables = M_.orig_endo_nbr; %auxiliary variables are set automatically
for ii = 1:NumberOfEndogenousVariables
  varname = M_.endo_names{ii};
  eval(['ys(' int2str(ii) ') = ' varname ';']);
end

% ------------------------------End of file--------------------------------