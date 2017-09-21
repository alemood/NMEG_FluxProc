% Cumulative Annual Fluxes (resets to zero at beginning of water year)
    [uniqueDay,idxToUnique,idxFromUniqueBackToAll] = unique(data2(:,2:3));
    % Accumulatve Precip and ET values over water year
    SWC_P1_5_mean = accumarray(idxFromUniqueBackToAll,data2{:,8},[],@(x) nanmean(x));
    SWC_P1_10_mean = accumarray(idxFromUniqueBackToAll,data2{:,9},[],@(x) nanmean(x));
    SWC_P1_30_mean = accumarray(idxFromUniqueBackToAll,data2{:,10},[],@(x) nanmean(x));
    
    

jday = datenum(2017,uniqueDay.month,uniqueDay.day)- datenum(2017,1,0);
%%
subplot(2,1,1)
imagesc([SWC_P1_5_mean, SWC_P1_10_mean,SWC_P1_30_mean]')
pal = colormap( cbrewer( 'seq', 'YlGnBu', 9 ) );
fp_cmap = [ interp1( 1:9, pal, linspace( 1, 9, 100 ) ) ];
colormap(fp_cmap)
colorbar

subplot(2,1,2)
imagesc(diff([SWC_P1_5_mean, SWC_P1_10_mean,SWC_P1_30_mean])',[-.005 .005])
pal = colormap( cbrewer( 'div', 'RdYlBu', 9 ) );
fp_cmap = [ interp1( 1:9, pal, linspace( 1, 9, 100 ) ) ];
colormap(fp_cmap)
colorbar

%% Multiyear

t = table;
for this_year = 2009:2017
    
    this_data = parse_soilmet_qc_file( UNM_sites.PJ,this_year,'suffix','qc_rbd' );
    t = table_append_common_vars(t,this_data);
    
end
%%
t_filled = table_fill_timestamps(t,'timestamp','t_min',datenum(2009,1,1),'t_max',datenum(2017,12,31,23,30,0));
t = t_filled;
%%
[t.year, t.month,t.day,t.hour,t.min,t.second] = datevec(t.timestamp);
%%
% Cumulative Annual Fluxes (resets to zero at beginning of water year)
[uniqueDay,idxToUnique,idxFromUniqueBackToAll] = unique(t(:,{'year','month','day'}));
[uniqueYear,~,~]=unique(t(:,{'year'}));
% Accumulatve Precip and ET values over water year
SWC_P1_5_mean = accumarray(idxFromUniqueBackToAll,t{:,'SWC_P1_5_AVG'},[],@(x) nanmean(x));
SWC_P1_10_mean = accumarray(idxFromUniqueBackToAll,t{:,'SWC_P1_10_AVG'},[],@(x) nanmean(x));
SWC_P1_30_mean = accumarray(idxFromUniqueBackToAll,t{:,'SWC_P1_30_AVG'},[],@(x) nanmean(x));
SWC = [SWC_P1_5_mean ,SWC_P1_10_mean,SWC_P1_30_mean];
%%
figure;
for i = 1:3
subplot(1,3,i)

data = SWC(:,i);
% pad data so number of rows is a multiple of 48 (that is, if there is an
% imcomplete day at the end, pad to a complete day.)
padded_nrow = ceil( size( data, 1 ) / height(uniqueYear) ) * height(uniqueYear);
data( end:padded_nrow, : ) = NaN;
data_rect = reshape( data, [366,height(uniqueYear)] );


imagesc( uniqueYear{:,:}, 1:366 , data_rect)
set( gca, 'YDir', 'normal', 'XMinorTick', 'On' );
pal = colormap( cbrewer( 'seq', 'YlGnBu', 9 ) );
fp_cmap = [ interp1( 1:9, pal, linspace( 1, 9, 100 ) ) ];

ylabel('DOY')
xlabel('Year')
title('Mean Daily SWC, P1 5')
end
colormap(fp_cmap)    
colorbar

   