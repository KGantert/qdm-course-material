%% *****************************************************************************
% Quantitative Dynamic Macroeconomics
% Assignment 01: A Three-Period Model
% Konstantin Gantert
% 24/08/2023
% ******************************************************************************
%% -----------------------------------------------------------------------------
% HOUSEKEEPING
% ------------------------------------------------------------------------------
clear all;  % Clear the workspace to prevent using any old variable or function
clc;        % Clear the command window for better visibility of new results
%% -----------------------------------------------------------------------------
% GENERAL SETUP: Parameters and Exogenous Variables
% ------------------------------------------------------------------------------
betta   = 0.99;     % Discount rate
phii    = 0.1;      % Labor disutility
nuu     = 1/0.72;   % Inverse of labor supply elasticity
sig     = 1;        % Risk-aversion
zbar    = 1;        % Initial productivity
g1      = 0.02;     % Productivity growth period 1
g2      = 0.04;     % Productivity growth period 2
%% -----------------------------------------------------------------------------
% EXERCISE 1: SOLVING THE MODEL (MULTI EQUATION SOLVER)
% ------------------------------------------------------------------------------
% We use the numerical solver "FSOLVE". This method is commonly based on the
% Newton-Raphson method. We have to provide all the parameters and starting
% values for all endogenous variables. Here we use rather simple starting
% values, as the model is simple. For more complex models, the starting
% values have to be closer to the true solution.
xx_0 = [1 1 1 1 1 1 1 1];
% Call the model file function where FSOLVE is included.
output = solve_model_large(betta,phii,nuu,sig,zbar,g1,g2,xx_0);
% Display the results for exercise 1 (large FSOLVE)
%display(struct2table(output));
%% -----------------------------------------------------------------------------
% EXERCISE 2: The Impact
% ------------------------------------------------------------------------------
sig_loop    = transpose(1:0.1:4); % Create a column vector from 1 to 4 with 0.1 steps.
% Pre-allocate matrices for speed! We create the matrices beforehand and
% then fill them. Otherwise, the size of the matrices would change with each
% iteration of the loop, which is very slow.
L1_ex5  = zeros(length(sig_loop),1);
L2_ex5  = zeros(length(sig_loop),1);
L3_ex5  = zeros(length(sig_loop),1);
C1_ex5  = zeros(length(sig_loop),1);
C2_ex5  = zeros(length(sig_loop),1);
C3_ex5  = zeros(length(sig_loop),1);
Q1_ex5  = zeros(length(sig_loop),1);
Q2_ex5  = zeros(length(sig_loop),1);
% As we want to loop over all possible values for the sigma parameter, we use a FOR-loop.
% "Length" is like size, but you dont have to choose the dimension as it picks the longest one.
for ii = 1:length(sig_loop)
    % Call the model function
    output = solve_model_large(betta,phii,nuu,sig_loop(ii),zbar,g1,g2,xx_0);
    % Save results. Be careful with the right allocation of indices.
    % Otherwise you will override your results with each iteration of the FOR-loop.
    L1_ex5(ii) = output.L1;
    L2_ex5(ii) = output.L2;
    L3_ex5(ii) = output.L3;
    C1_ex5(ii) = output.C1;
    C2_ex5(ii) = output.C2;
    C3_ex5(ii) = output.C3;
    Q1_ex5(ii) = output.Q1;
    Q2_ex5(ii) = output.Q2;
end
% Plotting the results
figure('Name','Optimal Consumption, Total Hours Worked and Bond Prices (Ex 2)')
% We define with "subplot(ROW,COLUMN,INDEX)" the grid of the plot
subplot(3,3,1)
plot(sig_loop,L1_ex5)
axis tight % Set axis tight to reduce large white spaces
xlabel('Risk Aversion') % Set x-axis label for the figure
ylabel('Labor Period One') % Set y-axis label for the figure
% Add the second figure (INDEX) of the subplot
subplot(3,3,2)
plot(sig_loop,L2_ex5) % PLOT(XVALUES,YVALUES)
axis tight % Set axis tight to reduce large white spaces
xlabel('Risk Aversion') % Set x-axis label for the figure
ylabel('Labor Period Two') % Set y-axis label for the figure
% Add the third figure (INDEX) of the subplot
subplot(3,3,3)
plot(sig_loop,L3_ex5)
axis tight % Set axis tight to reduce large white spaces
xlabel('Risk Aversion') % Set x-axis label for the figure
ylabel('Labor Period Three') % Set y-axis label for the figure
% Add the fourth figure (INDEX) of the subplot
subplot(3,3,4)
plot(sig_loop,C1_ex5)
axis tight % Set axis tight to reduce large white spaces
xlabel('Risk Aversion') % Set x-axis label for the figure
ylabel('Consumption Period One') % Set y-axis label for the figure
% Add the fifth figure (INDEX) of the subplot
subplot(3,3,5)
plot(sig_loop,C2_ex5)
axis tight
xlabel('Risk Aversion')
ylabel('Consumption Period Two')
% Add the fifth figure (INDEX) of the subplot
subplot(3,3,6)
plot(sig_loop,C3_ex5)
axis tight
xlabel('Risk Aversion')
ylabel('Consumption Period Three')
% Add the fifth figure (INDEX) of the subplot
subplot(3,3,7)
plot(sig_loop,Q1_ex5)
axis tight
xlabel('Risk Aversion')
ylabel('Bond Price Period One')
% Add the fifth figure (INDEX) of the subplot
subplot(3,3,8)
plot(sig_loop,Q2_ex5)
axis tight
xlabel('Risk Aversion')
ylabel('Bond Price Period Two')
% ------------------------------ END OF FILE -----------------------------------
