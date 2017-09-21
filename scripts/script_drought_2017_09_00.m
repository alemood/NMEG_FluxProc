% SCRIPT FOR  MARCYS TUCSON DROUGHT PRESENTATION
% Alex Moody, September 2017
clear all
close all

% Select sites
sites = {UNM_sites.PJ,UNM_sites.GLand,UNM_sites.MCon, ...
    UNM_sites.SLand, UNM_sites.PPine, UNM_sites.JSav};

% Construct object
obj = aflxAnalyzer( sites, ...
    'daily_data_already_parsed',true);

%%


%% 
vars = {'GPP_g_int','RECO_g_int','FC_F_g_int'};
varName = vars{1};
mylim = [0 8];
donorm = false;
% ---
% FC
% ---
% Make all time, unnormalized plots
[~,h1] = plotExceedanceCurves(obj,...
    {varName},...
    'figname','AllTime',...
    'donorm',donorm);
[~,h2] = plotExceedanceCurves(obj,...
    {varName},...
    'plot_end',datenum(2011,9,30),...
    'figname','pre2011',...
    'donorm',donorm);
[~,h3] = plotExceedanceCurves(obj,...
    {varName},...
    'plot_start',datenum(2011,10,1),...
    'figname','post2011',...
    'donorm',donorm);

h = figure('Position',[65 223 1357 377]);
hSub1 = subplot(1,3,1);
hAxes1 = findobj('Parent',h1,'Type','axes');  
copyobj(get(hAxes1,'Children'),hSub1);
ax = gca; ax.YLabel.String =hAxes1.YLabel.String;
title('All-time')
grid on
ylim(mylim)


hSub2 = subplot(1,3,2);
hAxes2 = findobj('Parent',h2,'Type','axes'); 
copyobj(get(hAxes2,'Children'),hSub2);
ax = gca; ax.XLabel.String = hAxes1.XLabel.String;
grid on
title('Pre-2011')
ylim(mylim)

hSub3 = subplot(1,3,3);
hAxes3 = findobj('Parent',h3,'Type','axes'); 
copyobj(get(hAxes3,'Children'),hSub3);
title('Post-2011')
grid on
ylim(mylim)
legend( gca, 'show' )

fname = fullfile(getenv('FLUXROOT'),...
                    'Plots','aflxAnalyzer','exceedance',...
                    sprintf('%s_norm_exceedance.png',varName));
saveas( h ,fname);
 


