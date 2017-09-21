% checkTotalPrecip - check the quality of data from the NMcon
% total precip gauge. 
%
% This is a script made referencing notes from the field book from April 20
% 2017. We poured a bottle of water into the precip gauge to see if the
% logger program records the correct volume of water. 
%
% 591 mL of water were poured into the 12" rain gauge at 10:25
%
% author: Alex Moody, UNM, 2017

fname = fullfile(getenv('FLUXROOT'),'SiteData',...
    'MCon_SS','secondary_loggers','precip',...
    'TOA5_MCon_SS47606.precip_out_2017_03_17_0905.dat');
data = toa5_2_table(fname);

% Only interested in time during monthly visit
t_start = datenum(2017,4,20);
t_end = datenum(2017,4,20,11,0,0);
keepidx = data.timestamp >= t_start &...
          data.timestamp <= t_end;
data(~keepidx,:) = [];

% Constants
d_g = 12 * 2.54; % gauge orifice diameter 12 inches
V_wi = 591;      % Volume of water input in mL
A_g = pi * (d_g/2)^2; % area of orifice opening

% Calculate the anticipated raise in water level
% H = V_w / A_g; Centimeters
H_e = V_wi / A_g;

% Calculate change in depth
delZ = diff(data.ActDepth);
delZ = [0;delZ];

delZ(delZ < 0.05 ) = 0;
% Convert to cm
delZ = delZ * 2.54

figure;
ax(1) = subplot(2,1,1);
plot(data.timestamp,data.ActDepth);
datetick('x','HH:MM',  'keeplimits' );
ylabel('ActDepth [cm]')

ax(2)=subplot(2,1,2);
bar(data.timestamp,delZ);
datetick('x','HH:MM', 'keeplimits' );
ylabel('\Delta ActDepth [cm]');
xlabel('time')
linkaxes( ax, 'x' );
dynamicDateTicks;

%%
clear all; close all
fname = fullfile(getenv('FLUXROOT'),'SiteData',...
    'MCon_SS','secondary_loggers','precip',...
'TOA5_MCon_SS47606.precip_out_2017_06_14_0845.dat');
data = toa5_2_table(fname);

t_start = datenum(2017,6,15);
t_end = datenum(2017,7,15);
keepidx = data.timestamp > t_start &...
          data.timestamp < t_end;
data(~keepidx,:) = [];


pT = total_precip_calculator( data);

% Get gapfilled data
fillData = parse_forgapfilling_file(UNM_sites.MCon_SS,2017);
keepidx = fillData.timestamp > t_start &...
          fillData.timestamp < t_end;
fillData(~keepidx,:) = [];

% Compare filled Precip with total precip gage
[fillData pT ] = ...
    merge_tables_by_datenum(fillData,pT,'timestamp','timestamp',0.01,t_start,t_end);
P = pT.precip_corr;
Pf = fillData.P;
ts = pT.timestamp;
figure;
ax(1)=subplot(3,1,[1 2])
plot(ts,cumsum(P),':k',ts,cumsum(Pf),'r');
legend('NMCon Gauge','Redondo');
ylabel('cumulative precip [mm]');
datetick('x','keepticks', 'keeplimits' );
title(sprintf('Redondo = %3.1f mm NMCon = %3.1f mm', ...
    max(cumsum(Pf)),...
    max(cumsum(P)))); 

ax(2) = subplot(3,1,3)

dynamicDateTicks


%% Compare same time periods 
fname_nmcon = fullfile(getenv('FLUXROOT'),'SiteData',...
    'MCon_SS','secondary_loggers','precip',...
'TOA5_MCon_SS47606.precip_out_2017_04_20_1205.dat');
data_nmcon = toa5_2_table(fname_nmcon);

fname_mcon = fullfile(getenv('FLUXROOT'),'SiteData',...
    'MCon','secondary_loggers','precip',...
'TOA5_MCon49012.precip_out_2017_05_18_0925.dat');
data_mcon = toa5_2_table(fname_mcon);

t_start = datenum(2017,5,19);
t_end = datenum(2017,6,1);

idx = data_mcon.timestamp > t_start & data_mcon.timestamp < t_end;
data_mcon(~idx,:) = [];
idx = data_nmcon.timestamp > t_start & data_nmcon.timestamp < t_end;
data_nmcon(~idx,:) = [];


figure;
ax(1) = subplot(3,3,[1 2]);
    plot(data_mcon.timestamp,data_mcon.ActDepth,':k','LineWidth',3);
    hold on
    plot(data_nmcon.timestamp,data_nmcon.ActDepth,'-.r','LineWidth',3);
    ylabel('Gauge Depth [in]')
    grid on
     hold off
ax(2) = subplot(3,3,[4 5]);  
    dz1 = [0;diff(data_mcon.ActDepth)];
    dz2 = [0;diff(data_nmcon.ActDepth.*(0.0023/0.001))];  
    plot(data_mcon.timestamp,[0;diff(data_mcon.ActDepth)],':k','LineWidth',2);
    hold on
    plot(data_nmcon.timestamp,[0;diff(data_nmcon.ActDepth)],'-.r','LineWidth',2);
    legend('MCon','New MCon');
    ylabel('\Delta Gauge Depth [in / 5min]');grid on; hold off
   
 ax(3) = subplot(3,3, [7 8] );
  
    dz1(dz1 < 0) = 0;
    dz1(dz1 < 0.01) = 0; 
    dz2(dz2 < 0 ) = 0;
    dz2(dz2 < 0.01) = 0; 
    plot(data_mcon.timestamp,cumsum(dz1,'omitnan'),':k','LineWidth',2);
    hold on 
    plot(data_nmcon.timestamp,cumsum(dz2,'omitnan'),'-.r','LineWidth',2);
    ylabel('Cumulative Precip [in]')
    grid on 
    
    linkaxes(ax,'x')
    dynamicDateTicks(ax,'linked')
    
    mybins = 0.005:0.01:.2;
subplot(2,3,3)
    hist(dz1,mybins);
    title('MCon \DeltaGauge Depth')
    subplot(2,3,6)
    hist(dz2, mybins);
    title('NMCon \DeltaGauge Depth')
    
    
    %%
precip_mcon = total_precip_calculator( data_mcon , UNM_sites.MCon,...
    t_start, t_end);
precip_nmcon = total_precip_calculator( data_nmcon, UNM_sites.MCon_SS,...
    t_start, t_end);

%% NMCon mvperdeg analysis
fname_nmcon = fullfile(getenv('FLUXROOT'),'SiteData',...
    'MCon_SS','secondary_loggers','precip',...
'TOA5_MCon_SS47606.precip_out_2017_04_20_1205.dat');
data = toa5_2_table(fname_nmcon);
%%
% Extract Temp
T = data.Temp;
mv = data.mvOut;
[id]=findchangepts(mv,'MinThreshold',var(data.mvOut)*2);
id = [1;id;length(mv)];
findchangepts(data.mvOut,'MinThreshold',var(data.mvOut)*2)

%% Determine mvprime 

% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'LAR';

mvperdeg = [];
figure('Position',[680 125 1105 973]);
for i = 1:length(id)-1
    idx = id(i):id(i+1)-1;
    if i ==length(id)-1
        idx = id(i):id(i+1);
    end

    [xData, yData] = prepareCurveData( T(idx), mv(idx) );
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    % Plot fit with data.
    ax(i) = subplot(4,4,i);
    plot( fitresult, xData, yData );legend off
    % Label axes
    xlabel('T_{air}');ylabel('mV_{out}');grid on
%     xlim([-10 30])
%     ylim([5.9 6.7])
    title(['mV response =' , num2str(fitresult.p1)])

    mvperdeg(i) =fitresult.p1;
    
end
annotation(gcf,'textbox',...
    [0.35 0.10 0.29 0.159],...
    'String',{['Average mV response = ',num2str(mean(mvperdeg))]},...
    'FontSize',12);