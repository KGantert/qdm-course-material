%% *****************************************************************************
% Quantitative Dynamic Macroeconomics
% Assignment 00
% RUN FILE (PARAMETER SETUP AND FOR LOOPS)
% Konstantin Gantert
% 24/08/2023
% ******************************************************************************
%% -----------------------------------------------------------------------------
% HOUSEKEEPING
% ------------------------------------------------------------------------------
clear all;  % Clear the workspace to prevent using any old variable or function
clc;        % Clear the command window for better visibility of new results
%% -----------------------------------------------------------------------------
% Parameters and Exogenous Variables
% ------------------------------------------------------------------------------
betta   = 0.99;     % Discount rate
r       = 0.01;     % Exogenous interest rate
sig     = 1.5;      % Risk-aversion
z       = 1;        % Exogenous productivity
k1      = 2;        % Pre-determined capital stock
alp     = 0.33;     % Capital elasticity of production
nuu     = 1/0.72;   % Inverse of labor supply elasticity
psii    = 0.1;      % Labor disutility
%% -----------------------------------------------------------------------------
% SOLVING THE MODEL
% ------------------------------------------------------------------------------
% We use a numerical root finder to solve the model, as it is non-linear in c1 and can therefore 
% not be solved analytically. This method is commonly based on the Newton-Raphson method. 
% We have to provide all the parameters and a starting value for c1. 
% We use the solved one equation model from assignment 01 as the model. 
% All other variables are derived from this solution.
c1_0    = 1;    % Set starting value for c1
% Call the model solve function we have created (check for other file in the working directory).
% All results are saved in the structure "output".
output  = solve_model(betta,r,sig,z,k1,alp,nuu,psii,c1_0);
%% -----------------------------------------------------------------------------
% FOR LOOP
% ------------------------------------------------------------------------------
% We are running a FOR-loop for different values of the parameter psi and
% solve the model for each change in the parameter value of psi.
psii_loop = transpose(0.1:0.01:2); % Define all the parameter to loop over
for tt = 1:size(psii_loop,1)  % Initialize the FOR-loop iteration
  psii   = psii_loop(tt,1);   % Set the "psii" value to the current iteration of the loop
  output = solve_model(betta,r,sig,z,k1,alp,nuu,psii,c1_0); % Call the model solve function
  c1_psii(tt,:) = output.c1;  % Save c1 from the output structure for each iteration
  c2_psii(tt,:) = output.c2;  % Save c2 from the output structure for each iteration
end % ENDS the FOR-loop iteration
% ******************************************************************
% We are running a FOR-loop for different values of the interest rate "r" and
% solve the model for each change in the interest rate.
r_loop = transpose(0.005:0.001:0.08); % Define all the parameter to loop over
for tt = 1:size(r_loop,1) % Initialize the FOR-loop iteration
  r   = r_loop(tt,1);     % Set the "r" value to the current iteration of the loop
  output = solve_model(betta,r,sig,z,k1,alp,nuu,psii,c1_0); % Call the model solve function
  c1_r(tt,:) = output.c1; % Save c1 from the output structure for each iteration
  c2_r(tt,:) = output.c2; % Save c2 from the output structure for each iteration
end % ENDS the FOR-loop iteration
%% -----------------------------------------------------------------------------
% PLOTTING
% ------------------------------------------------------------------------------
% Figure 01 - The Impact of Labor Disutility Changes on Intertemporal Consumption
figure('Name','The Impact of Labor Disutility Changes on Intertemporal Consumption');
plot(psii_loop,c1_psii); % Plot(X-AXIS_VALUES,Y-AXIS_VALUES)
hold on;  % Hold ON to plot an additional curve to the figure
plot(psii_loop,c2_psii); % Plot(X-AXIS_VALUES,Y-AXIS_VALUES)
hold off; % Hold OFF
axis tight; % Set axis tight to reduce large white spaces
xlabel('Labor Disutility Parameter'); % Set x-axis label for the figure
ylabel('Consumption Units'); % Set y-axis label for the figure
legend('Consumption Today','Consumption Tomorrow'); % Set legend of the curves for the figure
% Figure 02 - The Impact of Interest Rate Changes on Intertemporal Consumption
figure('Name','The Impact of Interest Rate Changes on Intertemporal Consumption');
plot(r_loop,c1_r); % Plot(X-AXIS_VALUES,Y-AXIS_VALUES)
hold on;  % Hold ON to plot an additional curve to the figure
plot(r_loop,c2_r); % Plot(X-AXIS_VALUES,Y-AXIS_VALUES)
hold off; % Hold OFF
axis tight; % Set axis tight to reduce large white spaces
xlabel('Interest Rate'); % Set x-axis label for the figure
ylabel('Consumption Units'); % Set y-axis label for the figure
legend('Consumption Today','Consumption Tomorrow'); % Set legend of the curves for the figure
% ------------------------------ END OF FILE -----------------------------------