% ET PLOTS FOR NMWRRI JUNE 2017 ET CONFERENCE
% The kernel regression plotting is a mess. Just laod surface data and do
% plotting here. 
setenv('KR','A:\Code\KernelRegressions')
save_fig = true;

% Set color pallette
gcolour=[0.9,0.5,0.0];
jcolour=[0.25, 1.0, 0.0];
mcolour=[0.0, 0.0, 0.6];
nmcolour=[0.3, 0.0, 0.5];
ngcolour= [0.9, 0.8, 0.0];
pjcolour=[0.0, 0.5, 0.0];
pjgcolour=[0.0, 0.85, 0.0];
pcolour=[0.5, 0.5, 1.0];
scolour=[0.6, 0.2, 0];
colour = ...
    vertcat(gcolour, jcolour, mcolour,nmcolour,ngcolour,pjcolour,pjgcolour,pcolour,scolour);

%% Indexes for subplots
 spID = [ 1 1 ; 2 1 ; 1 2 ;  2 2;  1 3  ;2 3];

%% Load matlab binaries of daily ameriflux values
file_list = list_files(fullfile(getenv('KR'),'data'), '.*.mat');
 sites = regexp(file_list,'data_(\w*).mat','tokens') ;
 sites = [sites{:}] ; sites = [sites{:}]';
 
for i = 1:numel(file_list)
    load(file_list{i});
    all_data{i,1} = char(sites{i});
    all_data{i,2} = data;
end

%% Not interested in non-core sites
find(~cellfun(@isempty , regexp(sites,'GLand|JSav|MCon|PJ|PPine|SLand')));
remove_idx = [4, 5 ,7 ];
all_data = all_data([1 2 3 6 8 9], :);
colour = colour([1 2 3 6 8 9], :);
colour = colour([1 6 2 4 5 3],: );

%% Rearrange according to elevation
all_data = ...
    vertcat( all_data(1,:) , all_data(6,:) , ...
    all_data(2,:) , all_data(4, :) , ...
    all_data(5,:) , all_data(3,:) )

%% Data transforms: Add wy, get annual and all-time cumulative values

for i = 1:length(all_data)
    ts = all_data{i,2}.TIMESTAMP;
    [all_data{i,2}.year, all_data{i,2}.month , all_data{i,2}.day,~,~,~] = ...
        datevec(ts);
    yearvec = unique(all_data{i,2}.year);
    hydroyear = zeros(height(all_data{i,2}),1);
    season = zeros(height(all_data{i,2}),1);
    for j = 1:length(yearvec)
        wy_idx = find( ts <= datenum( yearvec(j) , 9 , 30) & ...
                       ts >= datenum( yearvec(j) - 1 , 10, 1) );
       hydroyear(wy_idx) = yearvec(j)  ;
    end
    all_data{i,2}.hydroyear = hydroyear;
    all_data{i,2}.hDOY =  all_data{i,2}.TIMESTAMP - datenum(  all_data{i,2}.hydroyear-1, 10, 1 ) +1;
    cold_idx = find(all_data{i,2}.hDOY <= 182 );
    season(cold_idx,:) = 1; % COLD SEASON
    spring_idx = find(all_data{i,2}.hDOY > 182 & all_data{i,2}.hDOY <= 273 );
    season(spring_idx) = 2; % SPRING
    monsoon_idx = find(all_data{i,2}.hDOY > 273 & all_data{i,2}.hDOY <= 366 );
    season(monsoon_idx) = 3; % MONSOON
    all_data{i,2}.season = season;
    
   % all_data{i,2}.YrMnth = datestr([data.TIMESTAMP],'yyyymm');
    
    % Cumulative Annual Fluxes (resets to zero at beginning of water year)
    [uniqueWY,idxToUnique,idxFromUniqueBackToAll] = unique(all_data{i,2}.hydroyear);
    % Accumulatve Precip and ET values over water year
    cumulativeET = accumarray(idxFromUniqueBackToAll,all_data{i,2}.ET_mm_dayint,[],@(x) {cumsum(x,'omitnan')});
    all_data{i,2}.cumETannual = vertcat(cumulativeET{:});
    cumulativePPT = accumarray(idxFromUniqueBackToAll,all_data{i,2}.PRECIP,[],@(x) {cumsum(x,'omitnan')});
    all_data{i,2}.cumPPTannual = vertcat(cumulativePPT{:});
    
    % Cumulative fluxes
    cumulativeET = cumsum(all_data{i,2}.ET_mm_dayint,'omitnan');
    all_data{i,2}.cumET =cumulativeET ;
    cumulativePPT = cumsum(all_data{i,2}.PRECIP,'omitnan');
    all_data{i,2}.cumPPT =  cumulativePPT;
    
end



%% Get yearly (wateryear) site ET and PPT
yearlist = uniqueWY;
meanET = array2table(yearlist,'VariableNames',{'wyear'});
meanP =  array2table(yearlist,'VariableNames',{'wyear'});
meanETSE = array2table(yearlist,'VariableNames',{'wyear'});
meanPSE = array2table(yearlist,'VariableNames',{'wyear'});

for i = 1:length(all_data)
    
    site = all_data{i,1};
    data = all_data{i,2};
    % Calculate yearly means
    [uniqueYears,idxToUnique,idxFromUniqueBackToAll] = unique(data.hydroyear);
    yearlyMeanET = horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.ET_mm_dayint,[],@nanmean));
    yearlyMeanET = array2table(yearlyMeanET,'VariableNames',{'wyear',site});
    meanET = outerjoin(meanET,yearlyMeanET,'MergeKeys',true);
    % Calculate yearly mean SE
    yearlyMeanETSE = horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.ET_mm_dayint,[],@(x) nanstd(x)/sqrt(length(x))));
    yearlyMeanETSE = array2table(yearlyMeanETSE,'VariableNames',{'wyear',site});
    meanETSE = outerjoin(meanETSE,yearlyMeanETSE,'MergeKeys',true);
    % Merge yearly mean and yearly SEM tables, sort by site name
    annualET = outerjoin(meanET,meanETSE,'Keys','wyear','MergeKeys',true);
    sortedNames = sort(annualET.Properties.VariableNames(2:end));
    annualET = [annualET(:,1) annualET(:,sortedNames)];
    % Now for precip
    yearlyMeanP =  horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.PRECIP,[],@nanmean) );
    yearlyMeanP =  array2table(yearlyMeanP,'VariableNames',{'wyear',site});
    meanP = outerjoin(meanP,yearlyMeanP,'MergeKeys',true)   ;
       
    yearlyMeanPSE =  horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.PRECIP,[],@(x) nanstd(x)/sqrt(length(x))));
    yearlyMeanPSE =  array2table(yearlyMeanPSE,'VariableNames',{'wyear',site});
    meanPSE = outerjoin(meanPSE,yearlyMeanPSE,'MergeKeys',true)   ;
      
    annualP = outerjoin(meanP,meanPSE,'Keys','wyear','MergeKeys',true);
    sortedNames = sort(annualP.Properties.VariableNames(2:end));
    annualP = [annualP(:,1) annualP(:,sortedNames)];
       
end

%% Remove WY 2007 and 2016
remove_idx = find(annualP.wyear == 2007 | annualP.wyear == 2017);
annualP(remove_idx, : ) = [];
annualET(remove_idx, : ) = [];
%% SITE TIMESERIES BARPLOTS by YEAR, P and ET
% Plot only core sites
h_fig = figure('Position',[369 318 1454 745]);
save_fig = false;
for i = 1: length(all_data) % To exlude 2006 and 2016, incomplete wate years
    this_site = all_data{ i , 1};
    re = sprintf('(?<!\\w)(%s)',this_site);
    [ ~ , colid] = regexp_header_vars(annualP, re );
    
    
    P = annualP{ : , colid( 1 ) };
    Perr =annualP{ : , colid( 2 ) };
    ET = annualET{ : , colid( 1 )};
    ETerr = annualET{ : , colid( 2 ) };
    
    y = [ET];
%     if donorm
%         y = [normalize_vector(ET, 0, 1), ...
%             normalize_vector(P, 0 , 1) ];
%     end
    errY = [ETerr];
    
    %figure; hold on
    %[bar1 barerr] = barwitherr(errY, y);% Plot with errorbars
    subplotrc(2 ,3 ,spID(i,1),spID(i,2));
    %bar1 = bar( y ); hold on
    bar1 = barwitherr(errY,y)
    set(gca,'XTickLabel',annualP{:,1})
    set(gca,'YLim',[0 2.5])
    %set(gca,'XLim',[2007 2015]) % Incomplete water years in 2006 and 2016
    %set(bar1(1),'FaceColor',[224/255 194/255 85/255],'DisplayName','ET')
   % set(bar1(2),'FaceColor',[23/255 162/255 209/255],'DisplayName','P');
    set(bar1(1),'FaceColor',colour(i,:),'DisplayName','ET');
    title(sprintf('%s', this_site))
    if i <= 2; ylabel('Mean Daily ET [mm]');end
    if i == 4; xlabel('Hydrologic Year');end
    % if i == 1; legend('ET','P','Location','Best');end
    %errorbar(y,errY,'.k')
    hold off
    
end

if save_fig
    fname = 'MeanDailyET_allyears_allsites';
    destfile = fullfile(getenv('FLUXROOT'),'Plots',...
        'NMWRRI_ET',strcat(fname,'.png'));
    destfilefig = fullfile(getenv('FLUXROOT'),'Plots',...
        'NMWRRI_ET','matfig',fname);
    
    savefig( gcf, destfilefig)
    saveas( gcf , destfile, 'png')
end

%% Bar plot: Average ET by site
% Plot only core sites
%h_fig = figure('Position',[369 318 1454 745]);
save_fig = false;
aggET = [];
aggETerr = [];
for i = 1: length(all_data) % To exlude 2006 and 2016, incomplete wate years
    this_site = all_data{ i , 1};
    re = sprintf('(?<!\\w)(%s)',this_site);
    [ ~ , colid] = regexp_header_vars(annualP, re );
       
%     P = annualP{ : , colid( 1 ) };
%     Perr =annualP{ : , colid( 2 ) };
    aggET = [aggET, mean(annualET{ : , colid( 1 )} )];
    aggETerr = [aggETerr , mean( annualET{ : , colid( 2 ) } ) ];    
end
figure; 
bar1 = barwitherr( aggETerr,aggET ); 
set(bar1, 'FaceColor',[224/255 194/255 85/255],'DisplayName','ET')
set(gca,'XTickLabel',{all_data{:,1}})
if save_fig
    fname = 'MeanDailyETbar_allsites';
    destfile = fullfile(getenv('FLUXROOT'),'Plots',...
        'NMWRRI_ET',strcat(fname,'.png'));
    destfilefig = fullfile(getenv('FLUXROOT'),'Plots',...
        'NMWRRI_ET','matfig',fname);
    
    savefig( gcf, destfilefig)
    saveas( gcf , destfile, 'png')
end
%% Plot cumulative P - ET for every year for all sites
donorm = true;

for j = 1:length(uniqueWY)
    h_fig = figure;
   % idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
    for i = 1:length(all_data)
        idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
        this_ts = datenum(all_data{i,2}.hydroyear(idx),1,0)+all_data{i,2}.hDOY(idx);
        this_ts = all_data{i,2}.TIMESTAMP(idx); 
        Y = [all_data{i, 2}.cumPPT - all_data{i,2}.cumET];
        if donorm
            Y = normalize_vector(Y,-1,1);
        end   
        plot( this_ts,Y(idx) ,'LineWidth',2,'Color',colour(i,:));
        hold on
    end
    hold off
    
    legend([all_data(:,1)],'Location','Best')
    datetick('x','mmm-yy')
    ylabel('P - ET [mm]')
    xlabel('Date')
    title(sprintf('Water Year %d',uniqueWY(j)))
    if save_fig 
    fname = fullfile( getenv('FLUXROOT'),'Plots\NMWRRI_ET',sprintf('precip_less_et_%d.png',uniqueWY(j)));
    if donorm
        fname = strrep(fname,'_less','_less_normalized');
        ylabel('normalized P - ET [mm]')
    end
    saveas(h_fig, fname );
        
    end
end

%% Plot cumulative P - ET for every year for all sites.
% Each site has all years plotted on one plot, 6 panel plot
donorm = true;
h_fig = figure;

for j = 1:length(all_data) % site idx
    
   % idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
    for i = 2:length(uniqueWY)-1
        idx = find(all_data{j,2}.hydroyear == uniqueWY(i) );
        this_ts = datenum(all_data{j,2}.hydroyear(idx),1,0)+all_data{j,2}.hDOY(idx);
        this_ts = all_data{j,2}.TIMESTAMP(idx); 
        Y = [all_data{j, 2}.cumPPTannual - all_data{j,2}.cumETannual];
        if donorm
            Y = normalize_vector(Y,-1,1);
        end 
        subplotrc(2,3,j)
        plot(all_data{j,2}.hDOY(idx),Y(idx) ,'LineWidth',2,'DisplayName',num2str(uniqueWY(i)))%'Color',colour(j,:));
        %datetick('x','m')
        grid on
        hold on
    end
    hold off 
    %legend('Location','Best')
    ylabel('P - ET [mm]')
    xlabel('Day of Water Year')
    xlim([0 365])
    title(sprintf('%s',all_data{j,1}))
    if save_fig 
    fname = fullfile( getenv('FLUXROOT'),'Plots\NMWRRI_ET','precip_less_et_allsites.png');
    if donorm
        fname = strrep(fname,'_less','_less_normalized');
        ylabel('normalized P - ET [mm]')
    end
  %  saveas(h_fig, fname );
        
    end
end

%% Plot fanchart of cumulative P-ET, all years one plot, 6 panel plot
donorm = false;
hfig = figure('Position',[369 163 1438 900]);
for i = 1:length(all_data) % site index
    agg_data = zeros( 366 , 9 );
    Y = [all_data{i, 2}.cumPPTannual - all_data{i,2}.cumETannual];
    for j = 2:length(uniqueWY)-1 % ignore 2006 & 2016 water years (incomlete)
        % Find timestamps in this water year
        idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
        % Normalize if called for
        if donorm;Y = normalize_vector(Y,-1,1);end
        % Place data in aggregated array
        agg_data(1:length(Y(idx)) , j - 1 ) = Y(idx);
    end
     subplotrc(2 ,3 ,spID(i,1),spID(i,2));
    aa= colour(i,:);
    aa = [23/255 162/255 209/255];
    this_ts = datenum(2004,10,all_data{i,2}.hDOY(idx));
    %[lineh, bandsh] = fanChart(1:366,agg_data,'mean', 10:10:90,'alpha',.5,'colormap', {'shadesOfColor', aa});
    [lineh, bandsh] = fanChart(this_ts,agg_data,'mean', 10:10:90,'alpha',.5,'colormap', {'shadesOfColor', aa});
    datetick('x','m')
    xlim([ min(this_ts) max(this_ts)])
    ylim([-200 300])
    title(all_data{i,1})
    if i<= 2;ylabel('cumulative P - ET [mm]');end
    %if i == 4; xlabel( 'Day of Water Year');end
    grid on
end
txt = strcat({'Pct'}, cellstr(int2str((20:20:80)')));
legend([lineh;bandsh], [{'Mean'};txt])



destfile = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET',sprintf('P-ET_fanchart_allsites.png'));
destfilefig = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET','matfig',sprintf('P-ET_fanchart_allsites'));


%  savefig(gcf, destfilefig)
%  saveas( gcf , destfile, 'png')


%% One long time series of P - ET

   agg_data = zeros( 3288 , 6);
for i = 1:length(all_data) % site index
 
    idx = find(all_data{ i ,2}.hydroyear > 2006 & all_data{i,2}.hydroyear < 2016);
    Y = [all_data{i, 2}.cumPPT - all_data{i,2}.cumET];

    Y = Y(idx);
    agg_data( : , i ) = Y;
end
aa = [23/255 162/255 209/255];
[lineh, bandsh] = fanChart(all_data{i,2}.TIMESTAMP(idx),agg_data,'mean', 10:10:90,'alpha',.5,'colormap', {'shadesOfColor', aa});
%xtickformat('MMMMM')
txt = strcat({'Pct'}, cellstr(int2str((20:20:80)')));
legend([lineh;bandsh], [{'Mean'};txt])
xlabel('Date')
ylabel('Cumulative P - ET (mm)')

set(gca,'XMinorTick','on')
xticks([min(all_data{i,2}.TIMESTAMP(idx)):183:max(all_data{i,2}.TIMESTAMP(idx))])
datetick('x','m-yy','keepticks')

grid on
destfile = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET',sprintf('P-ET_fanchart_allsites_fullts.png'));
destfilefig = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET','matfig',sprintf('P-ET_fanchart_allsites_fullts'));
%  savefig(gcf, destfilefig)
%  saveas( gcf , destfile, 'png')

%% cumulative ET 6 panel, by site
pal = cbrewer('seq','PuBuGn',15);
donorm = true;
for i = 1:length(all_data);
    subplotrc(2 ,3 ,spID(i,1),spID(i,2)); hold on
    Y = all_data{i,2}.cumETannual;
    for j = 2:length(uniqueWY)-1; 
        Y = all_data{i,2}.cumETannual;
        if donorm; Y = normalize_vector(Y,0,1);end 
        idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
        Y = Y(idx); 
        this_ts = datenum(2004,10,all_data{i,2}.hDOY(idx));
       % this_ts = all_data{i,2}.TIMESTAMP(idx); 
        plot(this_ts,Y,'LineWidth',2,'Color',pal(j + 5,:),'DisplayName',num2str(uniqueWY(j)))
        if i == 1| i == 6;ylabel('Cumulative ET (mm)');end     
        if  i ==4 ;xlabel('Month');end
    end 
    datetick('x','m')
    xlim([ min(this_ts) max(this_ts)])
    title(all_data{i,1})
    set(gca,'XMinorTick','on')
    grid on
end
legend('Location','Best')

destfile = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET',sprintf('cumulative_ET_by_site_normalized.png'));
destfilefig = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET','matfig',sprintf('cumulative_ET_by_site_normalized'));
%  savefig(gcf, destfilefig)
%  saveas( gcf , destfile, 'png')

%% daily ET 6 panel, by site, all years one plot
pal = cbrewer('seq','PuBuGn',15);
donorm = true;
h_fig = figure('Position',[369 318 1454 745])
for i = 1:length(all_data);
    subplotrc(2 ,3 ,spID(i,1),spID(i,2)); hold on
  %  Y = all_data{i,2}.ET_mm_dayint;
    for j = 2:length(uniqueWY)-1; 
        Y = all_data{i,2}.ET_mm_dayint;
        if donorm; Y = normalize_vector(Y,0,1);end 
        idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
        Y = Y(idx); 
        this_ts = datenum(2004,10,all_data{i,2}.hDOY(idx));
       % this_ts = all_data{i,2}.TIMESTAMP(idx); 
        plot(this_ts,Y,'LineWidth',1,'Color',pal(j + 5,:),'DisplayName',num2str(uniqueWY(j)))
        if i == 1| i == 6;ylabel('Cumulative ET (mm)');end     
        if  i ==4 ;xlabel('Month');end
    end 
    datetick('x','m')
    xlim([ min(this_ts) max(this_ts)])
    title(all_data{i,1})
    set(gca,'XMinorTick','on')
    grid on
end
legend('Location','Best')

destfile = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET',sprintf('ET_by_site_normalized.png'));
destfilefig = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET','matfig',sprintf('ET_by_site_normalized'));
%  savefig(gcf, destfilefig)
%  saveas( gcf , destfile, 'png')

%% ET daily, 6 panel,  fan chart
donorm = false;
h_fig = figure('Position',[369 318 1454 745])
for i = 1:length(all_data) % site index
    agg_data = zeros( 366 , 9 );
    Y = [all_data{i, 2}.ET_mm_dayint];
    for j = 2:length(uniqueWY)-1 % ignore 2006 & 2016 water years (incomlete)
        % Find timestamps in this water year
        idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
        % Normalize if called for
        if donorm;Y = normalize_vector(Y,0,1);end
        % Place data in aggregated array
        agg_data(1:length(Y(idx)) , j - 1 ) = Y(idx);
    end
    subplotrc(2,3,spID(i,1),spID(i,2)); 
    aa= colour(i,:);
    aa = [23/255 162/255 209/255];
    this_ts = datenum(2004,10,all_data{i,2}.hDOY(idx));
    %[lineh, bandsh] = fanChart(1:366,agg_data,'mean', 10:10:90,'alpha',.5,'colormap', {'shadesOfColor', aa});
    [lineh, bandsh] = fanChart(this_ts,agg_data,'nanmean', 10:10:90,'alpha',.5,'colormap', {'shadesOfColor', aa});
   % xlim([0 365])
    title(all_data{i,1})
    if i ==1 | i == 2;ylabel('ET [mm]');end
   % if i > 3; xlabel( 'Day of Water Year');end
   datetick('x','m')
    xlim([ min(this_ts) max(this_ts)])
    ylim([ 0 6])
    grid on
end
txt = strcat({'Pct'}, cellstr(int2str((20:20:80)')));
legend([lineh;bandsh], [{'Mean'};txt])

destfile = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET',sprintf('ET_by_site_fanchart.png'));
destfilefig = fullfile(getenv('FLUXROOT'),'Plots',...
    'NMWRRI_ET','matfig',sprintf('ET_by_site_fanchart'));
%  savefig(gcf, destfilefig)
%  saveas( gcf , destfile, 'png')
%% Plot cumulative ET for every year for all sites
donorm = true;
for j = 1:length(uniqueWY)
    h_fig = figure;
   % idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
    for i = 1:length(all_data)
        idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
        this_ts = datenum(all_data{i,2}.hydroyear(idx),1,0)+all_data{i,2}.hDOY(idx);
        this_ts = all_data{i,2}.TIMESTAMP(idx); 
        Y = all_data{i,2}.cumETannual;
        if donorm
            Y = normalize_vector(Y,0,1);
        end   
        plot( this_ts,Y(idx) ,'LineWidth',2,'Color',colour(i,:));
        hold on
    end
    hold off
    legend([all_data(:,1)],'Location','Best')
    datetick('x','m-yy')
    ylabel('ET [mm]')
    xlabel('Date')
    title(sprintf('Water Year %d',uniqueWY(j)))
    if save_fig 
    fname = fullfile( getenv('FLUXROOT'),'Plots\NMWRRI_ET',sprintf('cumulative_ET_%d.png',uniqueWY(j)));
    if donorm
        fname = strrep(fname,'cumulative_ET','cumulative_ET_normalized');
        ylabel('normalized ET [mm]')
    end
    saveas(h_fig, fname );     
    end
end

%% Plot ET exceedance curves
h_fig = figure

% Set symbols.
mysymbols = '......d....';
pal = cbrewer( 'qual', 'Dark2', 11 );
pal(7,:) = [1 0 0];
for i = 1:length(all_data)
    Y = all_data{i,2}.ET_mm_dayint;
    %Y =  all_data{i,2}.PRECIP;
    zeroIDs = find( Y == 0);
    %Y(zeroIDs) = NaN;
    if donorm
        Y = normalize_vector(Y, 0 , 1 );
    end
    [F X ]= ecdf(Y);
    plot( 1- F , X ,'LineWidth',1.5,'Color',colour(i,:));
    hold on
    % Find year means and plot 
%     [x, idx ]=unique(X);
%     Fq = interp1( x , F(idx) , meanET{:,1+i});
%     gscatter( 1 - Fq, meanET{:,1+i},meanET.wyear,pal,mysymbols)
end
    hold off
   % set(gca,'yscale','log');
    grid on
    legend([all_data(:,1)],'Location','Best')
    ylabel('ET [mm]')
   % ylim([0 6])
    grid on
    xlabel('% of time given value was exceeded')

%% Histograms, ET
h_fig = figure;
for i = 1:length(all_data)
    Y = all_data{i,2}.ET_mm_dayint;
    [count , ET_value] = hist(Y,0.25:.25:6.5);
    edges = 0:.25:6;
    %[N,edges] = histcounts(Y,edges,'Normalization','probability')
    subplotrc(2,3,spID(i,1),spID(i,2)); 
    bar1 = bar(ET_value, count./sum(count))
    %bar1 = bar(ET_value, count )
    set(bar1(1),'FaceColor',colour(i,:),'DisplayName','ET');
    if i <=2; ylabel('Frequency');end
    if i == 4; xlabel('ET [mm/d]');end
    ylim([0 0.5])
    xlim([0 6])
    title(all_data{i,1})
end
  
%% Yearly cumulative P-ET
for i = 1:length(all_data)
    
    % Accumulatve Precip and ET values over water year, grab end of year values
    yearlycumulativeET = accumarray(idxFromUniqueBackToAll,all_data{i,2}.cumETannual,[],@nanmax);
    yearlycumulativePPT = accumarray(idxFromUniqueBackToAll,all_data{i,2}.cumPPTannual,[],@nanmax);
    Y = yearlycumulativePPT - yearlycumulativeET;
    plot(uniqueWY, Y,'Marker','o','LineStyle',':','LineWidth',2,'Color',colour(i,:));
    hold on
    allsitessum(:,i) = Y;
end

    hold off
    legend([all_data(:,1)],'Location','Best')
    ylabel('cumulative yearly P - ET [mm]')
    xlabel('Water Year')
    xlim([2007 2015])
    title(sprintf('Water Year %d',uniqueWY(j)))
    if save_fig 
    fname = fullfile( getenv('FLUXROOT'),'Plots\NMWRRI_ET','yearly_precip_less_et.png');
    if donorm
        fname = strrep(fname,'_less','_less_normalized');
        ylabel('normalized P - ET [mm]')
    end
    saveas(h_fig, fname );
        
    end

%% Annual ET and P, allsites, one panel, barplot
%% Yearly cumulative P-ET
 yearlycumulativeET = [];
 yearlycumulativePPT = [];
for i = 1:length(all_data)
    
    % Accumulatve Precip and ET values over water year, grab end of year values
    yearlycumulativeET = ...
        [yearlycumulativeET , mean(accumarray(idxFromUniqueBackToAll,all_data{i,2}.cumETannual,[],@nanmax)) ];
    yearlycumulativePPT = ...
        [yearlycumulativePPT mean(accumarray(idxFromUniqueBackToAll,all_data{i,2}.cumPPTannual,[],@nanmax)) ];
    
end
    figure
    bar1 = bar([yearlycumulativeET' , yearlycumulativePPT']);
    
    legend('Location','Best')
    ylabel('Annual P and ET [mm]')

    set(bar1(1),'FaceColor',[224/255 194/255 85/255],'DisplayName','ET')
    set(bar1(2),'FaceColor',[23/255 162/255 209/255],'DisplayName','P');
    set(gca,'XTickLabel',{all_data{:,1}})
    
    if save_fig 
    fname = fullfile( getenv('FLUXROOT'),'Plots\NMWRRI_ET','annual_ET_and_P.png');
    saveas(gcf, fname );
    end


%% ------------ Mean Annual ET/P for each year at each site
load('spei.mat')
%%
aflx_sites = {'Seg' 'Ses' 'Wjs' 'Mpj' 'Vcp' 'Vcm'};
pal = cbrewer('seq','PuBuGn',13);
figure
for i = 1:6
    this_site = aflx_sites{i};
    % Find data for this site
    idx = find(spei.variable == this_site);
    %Remove NAN (can't use in linear regression)
    notNAN = find(~isnan(spei.wyear_mean_spei(idx)));
    idx = idx(notNAN);
    
    % Start plotting
    subplot(1,6,i)
    gscatter(spei.wyear_mean_spei(idx),spei.year_sum(idx),spei.year_w(idx),pal(7:13,:)); hold on
    [fr, gof, xData,yData] = fit( spei.wyear_mean_spei(idx), spei.year_sum(idx),'poly1','normalize','off' );
    plot( fr );
    
    ylim([0 750])
    title(this_site)
    if i == 1; ylabel('Cumulative ET [mm]');else;ylabel('');end
    xlabel('')
    
    lm = fitlm(spei.wyear_mean_spei(idx),spei.year_sum(idx),'linear');%'RobustOpts','on');
    this_p = lm.Coefficients.pValue(2);
     % Plot stats
     txt = sprintf('r^2 = %1.2f \np = %1.2f \nRMSE = %2.2f', lm.Rsquared.Adjusted,this_p,lm.RMSE);
     text(-1.75,80,txt)

    legend off
end

%% MCon Comparisons
 
for i = 1:2
 data = all_data{i,2};
 [am,~,cm] = unique([data.year,data.month],'rows');
 month_flux = ...
    [datenum(am(:,1),am(:,2),1), ...
        accumarray( cm, data.FC,[], @(x) nansum(x) ),...
        accumarray( cm, data.GPP,[], @(x) nansum(x) ),...
        accumarray( cm, data.RE,[], @(x) nansum(x) ) ];
    idx = month_flux== 0;
 month_flux(idx) = NaN;   
 all_data{i,3} = ...
     array2table(month_flux,'VariableNames',{'TIMESTAMP','FC','GPP','RE'})
    
end

%%
close all
idx = all_data{1,3}.TIMESTAMP >= datenum(2010,1,1);


idxburn = all_data{1,3}.TIMESTAMP > datenum(2013,6,1) & ...
     all_data{1,3}.TIMESTAMP < datenum(2014,1,1);
% all_data{1,2}{idxburn,:} = NaN;
time=all_data{1,3}.TIMESTAMP; 

%sets up figure
ax=figure_ts(2,[min(time) max(time)],0,'Date');
figure1 = gcf
%ticks and ylabels for each axis
ytix1=-80:40:140; ylbl1='MCon Burned';
ytix2=-80:40:140; ylbl2='MCon Sulfur Spring';

pal = cbrewer('qual','Paired',6);
GPPc = [0, 122, 204]./255;
FCc = pal(3 ,: );
REc = pal(6, :);
% MCon
idx2 = idx &~idxburn;
subplot_ts(ax,1,ytix1,ylbl1,...
    's1', time(idx2) , all_data{1,3}.FC(idx2),'Color',FCc,'linewidth',1.25,...
    's2', time(idx2), all_data{1,3}.GPP(idx2),'Color',GPPc,'linewidth',1.25,...
    's3', time(idx2) , all_data{1,3}.RE(idx2),'Color',REc,'linewidth',1.25);
ylabel('g C m^{2} d{-1}')
datetick('x','m-yy')
grid on



% MCon_SS
subplot_ts(ax,2,ytix2,ylbl2,...
    's1', time(idx) , all_data{2,3}.FC(idx),'Color',FCc,'linewidth',1.25,...
    's2', time(idx), all_data{2,3}.GPP(idx),'Color',GPPc,'linewidth',1.25,...
    's3', time(idx) , all_data{2,3}.RE(idx),'Color',REc,'linewidth',1.25);
ylabel('g C m^{2} d{-1}')
datetick('x','m-yy')
grid on

l1=legend_ts(ax,1,'best','NEP','GPP','RE'); %makes a legend

patch_ts(ax,datenum(2013,6,1),datenum(2014,1,1),[.9 .9 .9]); %makes a shaded region (patch)

% Create textarrow
annotation(figure1,'textarrow',[0.482809070958303 0.507681053401609],...
    [0.864874363327674 0.848896434634974],'LineWidth',1,'FontSize',14);

% Create textbox
annotation(figure1,'textbox',...
    [0.459668617410388 0.850594227504244 0.0589853694220921 0.0594227504244486],...
    'Color',[0.850980401039124 0.325490206480026 0.0980392172932625],...
    'String',{'Fire'},...
    'LineWidth',1,...
    'LineStyle','none',...
    'FontSize',14,...
    'FitBoxToText','off');

% Create textbox
annotation(figure1,'textbox',...
    [0.602316752011707 0.514431239388794 0.228700073152888 0.0441426146010185],...
    'String','Mixed Confier Sulfur Spring',...
    'LineWidth',1,...
    'LineStyle','none',...
    'FontSize',14,...
    'FitBoxToText','off');

% Create textbox
annotation(figure1,'textbox',...
    [0.2043650329188 0.884550084889643 0.102145574250183 0.0441426146010186],...
    'String',{'Mixed Confier'},...
    'LineWidth',1,...
    'LineStyle','none',...
    'FontSize',14,...
    'FitBoxToText','off');

%% Bivariate comparison plots
close all
vars = {'FC' , 'GPP' ,'RE'};
for i = 1:length(vars)
 
    var1 = all_data{1,2}{:,vars{i}};
    var2 = all_data{2,2}{:,vars{i}};
    ts = all_data{1,2}.TIMESTAMP;
    type = 'general';
    plot_bivariate_comparison(var1, var2,ts,'general','fig_name',vars{i},'varnames',{'MCon','MCon_SS'})
    saveas(gcf,fullfile(getenv('FLUXROOT'),'Plots','CZO_figures',sprintf('MCons_%s.png',vars{i})));
end
