%% ************************************************************************
% Quantitative Dynamic Macroeconomics
% Lecture 01: Business-cycle facts and the Phillips curve for the U.S. economy
% Konstantin Gantert
% *************************************************************************
% Reads data.xlsx (U.S. quarterly time series from FRED, see README.md in this
% folder), computes the second moments shown on the slides and exports the
% figures to ../latex/figures/.
%
% Needs the Econometrics Toolbox (hpfilter) and Matlab R2020a or newer (exportgraphics).
%% ------------------------------------------------------------------------
% HOUSEKEEPING
%--------------------------------------------------------------------------
clear all;
clc;
export_figures = 1;     % Set to "0" to skip exporting the figures
fig_folder     = fullfile('..','latex','figures');

%% ------------------------------------------------------------------------
% DATA CONSTRUCTION
%--------------------------------------------------------------------------
% Set start of the sample (end of the sample = last observation in data.xlsx)
start_date = datetime(1970,1,1);
% Sample for the business-cycle statistics on the slides and for the GDP-cycle figure
stats_start = datetime(1980,1,1);

T = readtable('data.xlsx');
T = T(T.observation_date >= start_date,:);

dates    = T.observation_date;
nom_gdp  = T.nom_gdp;                   % Nominal GDP
real_gdp = T.real_gdp;                  % Real GDP
real_inv = T.real_inv;                  % Real gross private domestic investment
real_gov = T.gov_exp;                   % Real government consumption and investment
unemp    = T.un_rate./100;              % Unemployment rate
fed_fund = T.fed_funds./100;            % Effective federal funds rate
mich_exp = T.infl_exp_mich./100;        % Michigan inflation expectations (available from 1978)
nber_rec = T.nber_recession;            % NBER recession indicator

% The unemployment gap and the Phillips curve need the NAIRU (FRED: NROU) and core
% PCE inflation (FRED: BPCCRO1Q156NBEA, year-on-year), stored in data.xlsx as the
% columns "nairu" and "core_pce" (in percent), see README.md.
has_phillips = all(ismember({'nairu','core_pce'},T.Properties.VariableNames));
if has_phillips
    nairu    = T.nairu./100;
    core_pce = T.core_pce./100;
    un_cycle = unemp - nairu;
else
    warning('Columns "nairu" and "core_pce" not found in data.xlsx: unemployment gap and Phillips curve are skipped.');
end

% GDP deflator and private consumption (residual: GDP - investment - government spending)
gdp_deflator = nom_gdp ./ real_gdp;
priv_con     = real_gdp - real_inv - real_gov;

% Logs
log_real_gdp  = log(real_gdp);
log_real_inv  = log(real_inv);
log_real_cons = log(priv_con);
log_real_gov  = log(real_gov);

% Year-on-year inflation based on the GDP deflator (first four observations are undefined)
infl_year = [nan(4,1); log(gdp_deflator(5:end)) - log(gdp_deflator(1:end-4))];

% De-trending by the HP-filter (smoothing parameter 1600 for quarterly data)
[gdp_trend,gdp_cycle]   = hpfilter(log_real_gdp,Smoothing=1600);
[inv_trend,inv_cycle]   = hpfilter(log_real_inv,Smoothing=1600);
[cons_trend,cons_cycle] = hpfilter(log_real_cons,Smoothing=1600);
[gov_trend,gov_cycle]   = hpfilter(log_real_gov,Smoothing=1600);
% De-trending inflation by subtracting the mean
infl_cycle = infl_year - mean(infl_year,'omitnan');

%% ------------------------------------------------------------------------
% SECOND MOMENTS
%--------------------------------------------------------------------------
cycles = {'Real GDP',gdp_cycle; 'Investment',inv_cycle; 'Consumption',cons_cycle; 'Government spending',gov_cycle; 'Inflation',infl_cycle};
if has_phillips
    cycles = [cycles; {'Unemployment gap',un_cycle}];
end
moments = table('Size',[size(cycles,1) 3],'VariableTypes',{'string','double','double'}, ...
                'VariableNames',{'Variable','RelativeStdDev','CorrelationWithGDP'});
for ii = 1:size(cycles,1)
    x = cycles{ii,2};
    ok = ~isnan(x);
    rho = corrcoef(x(ok),gdp_cycle(ok));
    moments(ii,:) = {string(cycles{ii,1}), std(x(ok))/std(gdp_cycle(ok)), rho(1,2)};
end
fprintf('Second moments relative to real GDP, %s to %s:\n', string(dates(1),'yyyy-QQQ'), string(dates(end),'yyyy-QQQ'));
disp(moments)

% Statistics shown on the business-cycle slide: standard deviation (in percent) and
% autocorrelations of the cyclical components, HP filter applied to the sample from stats_start on
in_s = dates >= stats_start;
[~,gdp_cycle_s] = hpfilter(log_real_gdp(in_s),Smoothing=1600);
slide_series = {'Real GDP',gdp_cycle_s};
if has_phillips
    slide_series = [slide_series; {'Unemployment gap',un_cycle(in_s)}];
end
fprintf('Business-cycle statistics, %s to %s:\n', string(dates(find(in_s,1)),'yyyy-QQQ'), string(dates(end),'yyyy-QQQ'));
for ii = 1:size(slide_series,1)
    x = slide_series{ii,2};
    ac = zeros(1,3);
    for kk = 1:3
        r = corrcoef(x(1:end-kk),x(1+kk:end));
        ac(kk) = r(1,2);
    end
    fprintf('%-18s std = %.2f%%, autocorrelation (1/2/3 quarters) = %.2f / %.2f / %.2f\n', slide_series{ii,1}, std(x)*100, ac);
end

%% ------------------------------------------------------------------------
% PLOTTING THE RESULTS
%--------------------------------------------------------------------------
% Dates of the three vertical markers in the inflation figures (oil crisis, Volcker disinflation, Covid)
event_dates = [datetime(1973,10,1) datetime(1979,1,1) datetime(2020,1,1)];
%--------------------------------------------------------------------------
% Real GDP and its trend
figure("Name","Real GDP growth");
plot(dates(5:end),log_real_gdp(5:end),'b','LineWidth',1.5);
hold on;
plot(dates(5:end),gdp_trend(5:end),'r','LineWidth',1.5);
hold off;
axis tight;
xlabel('Year');
ylabel('Log-Scale');
legend('Real GDP','Real GDP Trend','Location','southoutside','Orientation','horizontal');
box on;
ax = gca;
ax.XGrid = 'off';
ax.YGrid = 'on';
if export_figures, exportgraphics(gcf,fullfile(fig_folder,'gdp_growth.eps'),'ContentType','vector'); end
%--------------------------------------------------------------------------
% Real GDP and unemployment fluctuations
if has_phillips
    figure("Name","Real GDP and Unemployment fluctuations");
    d      = dates(5:end);
    gdp_c  = gdp_cycle(5:end).*100;
    un_c   = un_cycle(5:end).*100;
    rec    = nber_rec(5:end);
    yl     = [min([gdp_c; un_c]) max([gdp_c; un_c])];
    yl     = yl + 0.05*diff(yl)*[-1 1];
    % Recession shading first (opaque light grey, no transparency: EPS export does not support it)
    hold on;
    h_rec = bar(d,yl(2)*rec,1,'FaceColor',[0.88 0.88 0.88],'EdgeColor','none');
    bar(d,yl(1)*rec,1,'FaceColor',[0.88 0.88 0.88],'EdgeColor','none','HandleVisibility','off');
    h_gdp = plot(d,gdp_c,'b','LineWidth',1.5);
    h_un  = plot(d,un_c,'k--','LineWidth',1.5);
    yline(0,'r','HandleVisibility','off');
    hold off;
    ylim(yl);
    xlim([stats_start dates(end)]);
    ylabel('%-Deviations');
    xlabel('Year');
    legend([h_gdp h_un h_rec],{'Real GDP Deviations','Unemployment Gap','NBER Recessions'},'Location','southoutside','Orientation','horizontal')
    box on;
    ax = gca;
    ax.XGrid = 'off';
    ax.YGrid = 'on';
    ax.Layer = 'top';
    if export_figures, exportgraphics(gcf,fullfile(fig_folder,'gdp_cycle.eps'),'ContentType','vector'); end
end
%--------------------------------------------------------------------------
% Phillips curves over time
if has_phillips
    periods = [1975 1984; 1985 1994; 1995 2014; 2015 2023];
    colors  = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250; 0.4660 0.6740 0.1880];
    figure('Name','US Phillips Curves over Time');
    hold on;
    for pp = 1:size(periods,1)
        in_p = year(dates) >= periods(pp,1) & year(dates) <= periods(pp,2);
        x = un_cycle(in_p).*100;
        y = core_pce(in_p).*100;
        coef = polyfit(x,y,1);                  % OLS: core PCE inflation = intercept + slope * unemployment gap
        scatter(x,y,75,'MarkerFaceColor',colors(pp,:),'MarkerEdgeColor','none');
        plot(x,polyval(coef,x),'--','Color',colors(pp,:),'LineWidth',1.5,'HandleVisibility','off');
        fprintf('Phillips curve %d-%d: slope = %.3f\n',periods(pp,1),periods(pp,2),coef(1));
    end
    hold off
    box on
    axis tight
    xlabel('Unemployment Gap')
    ylabel('Core PCE Inflation')
    legend('1975-1984','1985-1994','1995-2014','2015-2023','Location','southoutside','Orientation','horizontal')
    title('US Phillips Curves over Time')
    ax = gca;
    ax.XGrid = 'off';
    ax.YGrid = 'on';
    if export_figures, exportgraphics(gcf,fullfile(fig_folder,'phillips_us.eps'),'ContentType','vector'); end
end
%--------------------------------------------------------------------------
% Inflation and the output gap
if has_phillips
    figure("Name","Inflation and the Output Gap");
    area(dates(5:end),gdp_cycle(5:end).*100,'EdgeColor','none','FaceColor',[0.75 0.75 0.75]);
    hold on;
    plot(dates(5:end),un_cycle(5:end).*100,'k--','LineWidth',1.5);
    plot(dates(5:end),infl_year(5:end).*100,'r--','LineWidth',1.5);
    plot(dates(5:end),mich_exp(5:end).*100,'g-.','LineWidth',1.5);
    yline(0,'r')
    for ee = 1:numel(event_dates), xline(event_dates(ee),'b','LineWidth',2,'HandleVisibility','off'); end
    hold off;
    axis tight;
    xlabel('Year');
    ylabel('%-Deviations');
    legend('Real GDP','Unemployment','Inflation YoY','Inflation Expectation YoY','Location','southoutside','Orientation','horizontal');
    box on;
    ax = gca;
    ax.XGrid = 'off';
    ax.YGrid = 'on';
    if export_figures, exportgraphics(gcf,fullfile(fig_folder,'infl_exp.eps'),'ContentType','vector'); end
    %----------------------------------------------------------------------
    % Inflation and interest rates
    figure("Name","Inflation and Interest Rates");
    area(dates(5:end),gdp_cycle(5:end).*100,'EdgeColor','none','FaceColor',[0.75 0.75 0.75]);
    hold on;
    plot(dates(5:end),un_cycle(5:end).*100,'k--','LineWidth',1.5);
    plot(dates(5:end),infl_year(5:end).*100,'r--','LineWidth',1.5);
    plot(dates(5:end),mich_exp(5:end).*100,'g-.','LineWidth',1.5);
    plot(dates(5:end),fed_fund(5:end).*100,'b','LineWidth',1.5);
    yline(0,'r')
    hold off;
    axis tight;
    xlabel('Year');
    ylabel('%-Deviations');
    legend('Real GDP','Unemployment','Inflation YoY','Inflation Expectation YoY','FED Funds Rate','Location','southoutside','Orientation','horizontal');
    box on;
    ax = gca;
    ax.XGrid = 'off';
    ax.YGrid = 'on';
    if export_figures, exportgraphics(gcf,fullfile(fig_folder,'infl_interest.eps'),'ContentType','vector'); end
end
