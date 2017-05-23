formatdata =false; % Pull in data from fluxall. Otherwise, load .mat file

if formatdata
sitelist = { UNM_sites.PJ , UNM_sites.PJ_girdle};
yearlist = 2009:2017;

par_t_PJ = table();
par_t_PJG = table();
for i = 1:length(sitelist)
    par_t = table();
    for j = 1:length(yearlist)
        sitecode = sitelist{i};
        year = yearlist(j);
        
        pathname = fullfile( get_site_directory( sitecode ));
        fname = sprintf( '%s_%d_fluxall.txt', get_site_name( sitecode ), year );
        
        all_data = parse_fluxall_qc_file( sitecode, year );
        
        [var, par_idx] = regexp_header_vars(all_data,'Par');
        [~ , ts_idx ] = regexp_header_vars( all_data,'timestamp');
       % [~ , jday_idx ] = regexp_header_vars( all_data,'jday');
        
        new_par_t = all_data( : , [ts_idx , jday_idx, par_idx ] ) ;
        if j > 1
        par_t = table_foldin_data(par_t , new_par_t );
        else
        par_t = new_par_t;
        end      
    end
    
    if i == 1
        par_t_PJ = par_t;
    elseif i == 2
        par_t_PJG = par_t;
    end
    % rename to appropriate site
    clear all_data
end
[ t.year,t.month, t.day, t.hour , ~ , ~ ] = datevec(t.timestamp);
else
    load('PJ_par_allyears.mat')
end

% ---------------- FIGURE 1 ---------------------------------------------
%           Plot daily mean time series
% -----------------------------------------------------------------------

par_pj_c = [ 0 168/255 119/255 ];
par_pjg_c = [ 0 106/255 78/255 ]; 
% Get the unique days, and their indices
[uniqueDays,idxToUnique,idxFromUniqueBackToAll] = unique(floor(t.timestamp));

dailyMeanPJ = accumarray(idxFromUniqueBackToAll,t.Par_Avg_PJ,[],@nanmean);
[fitresultdPJ ,gofdPJ ] = createFit(uniqueDays, dailyMeanPJ, false );

dailyMeanPJG = accumarray(idxFromUniqueBackToAll,t.Par_Avg_PJG,[],@nanmean);
[fitresultdPJG ,gofdPJG ] = createFit(uniqueDays, dailyMeanPJG, false );

dailyDiff = dailyMeanPJ - dailyMeanPJG;
[fitresultdiffPJ, gofdiffPJ] = createFit(uniqueDays, dailyDiff ,false );

h_fig1 = figure( 'Name', ...
    sprintf('Mean daily PAR', ...
    'Position', [100 100 1250 950], 'Visible', 'on' ) );
ax(1) = subplot(2,1,1);
    plot(fitresultdPJ,uniqueDays,dailyMeanPJ,'.') ;hold on
    plot(fitresultdPJG, uniqueDays,dailyMeanPJG , '.' ); 
    ylabel('\mumol m^{-2} s^{-1}')
ax(2) = subplot(2,1,2);
    plot(fitresult, uniqueDays,dailyMeanPJ - dailyMeanPJG ,'.' )
    xlabel('Date')
    ylabel('\mumol m^{-2} s^{-1}')
    ylim([-200 200])
  
 linkaxes(ax)
 dynamicDateticks(ax)
 %%
% Get unique months and their indices
[allyears , allmonths,~,~,~,~] = datevec(t.timestamp);
[uniqueMonths,idxToUnique,idxFromUniqueBackToAll] = unique( datenum(allyears,allmonths,1));

monthlyMeanPJ = accumarray(idxFromUniqueBackToAll,t.Par_Avg_PJ,[],@nanmean);
[fitresultmPJ ,gofmPJ ] = createFit(uniqueMonths,monthlyMeanPJ, false );

monthlyMeanPJG = accumarray(idxFromUniqueBackToAll,t.Par_Avg_PJG,[],@nanmean);
[fitresultmPJG ,gofmPJG ] = createFit(uniqueMonths, monthlyMeanPJG, false );

monthlyDiff = monthlyMeanPJ - monthlyMeanPJG;
[fitresultmdiffPJ ,gofmdiffPJ ] = createFit(uniqueMonths, monthlyDiff, false );

h_fig2 = figure( 'Name', ...
    sprintf('Mean monthly PAR', ...
    'Position', [100 100 1250 950], 'Visible', 'on' ) );
title('Monthly Mean PAR')
ax(1) = subplot(2,1,1);
    plot(fitresultmPJ,uniqueMonths,monthlyMeanPJ,'.') ; hold on
    plot(fitresultmPJG, uniqueMonths,monthlyMeanPJG , '.' ); 
    ylabel('\mumol m^{-2} s^{-1}')
ax(2) = subplot(2,1,2);
    plot(fitresultmdiffPJ, uniqueMonths, monthlyMeanPJ - monthlyMeanPJG ,'-.' )
    xlabel('Date')
    ylabel('\mumol m^{-2} s^{-1}')
    ylim([-100 100])

    %%
% Get unique years and their indices

[uniqueYears,idxToUnique,idxFromUniqueBackToAll] = unique( datenum(allyears));

yearlyMeanPJ = accumarray(idxFromUniqueBackToAll,t.Par_Avg_PJ,[],@nanmean);
[fitresultyPJ ,gofyPJ ] = createFit(uniqueYears,yearlyMeanPJ, false );
yearlyMeanPJG = accumarray(idxFromUniqueBackToAll,t.Par_Avg_PJG,[],@nanmean);
[fitresultyPJG ,gofyPJG ] = createFit(uniqueYears,yearlyMeanPJG, false );
yearlyDiff = yearlyMeanPJ - yearlyMeanPJG;
[fitresultydiff ,gofydiff ] = createFit(uniqueYears,yearlyDiff, false );

h_fig2 = figure( 'Name', ...
    sprintf('Mean monthly PAR', ...
    'Position', [100 100 1250 950], 'Visible', 'on' ) );
title('Yearly Mean PAR')
ax(1) = subplot(2,1,1);
    plot(fitresultyPJ,uniqueYears,yearlyMeanPJ,'.') ; hold on
    plot(fitresultyPJG, uniqueYears,yearlyMeanPJG , '.' ); 
    ylabel('\mumol m^{-2} s^{-1}')
ax(2) = subplot(2,1,2);
    plot(fitresultydiff, uniqueYears, yearlyMeanPJ - yearlyMeanPJG ,'-.' )
    xlabel('Date')
    ylabel('\mumol m^{-2} s^{-1}')

 %%   
 % ----------------------- PAR DAILY CYCLE --------------------------------

% Get unique years and their indices 
[allyears , ~,~,~,~,~] = datevec(t.timestamp);
[uniqueYears,idxToUnique,idxFromUniqueBackToAll] = unique( datenum(allyears)); 

t.DTIME = t.timestamp - datenum(t.year,1,0);
 
fh = figure( 'Units', 'Normalized' );
pos = get( fh, 'Position' );
pos( [ 2, 4 ] ) = [ 0, 1 ];
set( fh, 'Position', pos );

for i = 1:numel( uniqueYears )
    year_idx = find(t.year == uniqueYears( i ) );
    all_axes( i ) = subplot( 3,3, i );
    plot( t.hour( year_idx ) + t.min(year_idx), [t.Par_Avg_PJ(year_idx) - t.Par_Avg_PJG(year_idx)] ,'.');
    xlim( [ 0, 24 ] );
    ylim( [ -50, 2000 ] );
    xlabel( 'hour' );
    ylabel( 'PAR' );
    title( num2str(uniqueYears (i ))) ;
end

linkaxes( all_axes( : ), 'x' );

%%

%------------------
% CONFIGURATION
%--------------

allTimestamps = timestamp;

% Number of days to plot radiation for ???
radDays = 10; % July 10

% Month to center data around
dom = 6;

% Colors
par_pj_c = [ 0 168/255 119/255 ];
par_pjg_c = [ 0 106/255 78/255 ];
% swin_c = [ 255/255 140/255 0 ];
% swout_c = [ 255/255 88/255 0 ];
% lwin_c = [ 0 147/255 175/255 ];
% lwout_c = [ 0 24/255 168/255 ];
% swinpot_c = [237/255 28/255 36/255 ];
% rnet_c = [ 0 0 0 ];

%
 
% ============================ FIGURE 2 =================================
% SWin vs PAR in each month of year

% Set up figure window
h_fig = figure( 'Name', ...
    sprintf('%d - %d Radiation diagnostics 1/2', ...
    min(unique(t.year)), max(unique(t.year) ), ...
    'Position', [100 100 1250 950], 'Visible', 'on' );

% Arrays of data and labels for months
%xLabelList = { 'January', 'February', 'March', 'April', 'May', 'June', ...
%    'July', 'August', 'September', 'October', 'November', 'December' };

% Array of data and labels 
xLabelList = { '2009'  '2010'  '2011'  '2012'  '2013'  '2014'  '2015' ,...
    '2016' '2017' };
% Dont plot months without the days we need
[ ~, monthsPresent, daysPresent, ~, ~, ~ ] = datevec( t.timestamp );
fullMonthsPresent = monthsPresent( daysPresent >= dom + 5 ); 

for i = 1:max( fullMonthsPresent )
    % Get day numbers, mean data for 2 variables, and solar events for 
    % the first week of month (i)
    repday = datenum( year, i, dom );
    solCalcs = noaa_potential_rad( sitevars.latitude, ...
        sitevars.longitude, ...
        repday );
    
    startDay = repday - radDays/2;
    endDay = repday + radDays/2;
    radTest = allTimestamps >= startDay & allTimestamps <= endDay;
    

    % Create subplot and draw dual y axis with original (unshifted) data
    hAx = subplot( 3, 4, i );
    hLine1 = plot( solCalcs( :, 1 ), solCalcs( :, 2 ), ...
        '.-', 'Color', swinpot_c );
    xlabel( xLabelList{ i } );
    ylim([ 0 1400 ]);
    xlim([ 0 24 ]);
    hold on;
    times = allTimestamps( radTest ) - floor( allTimestamps( radTest ));
    times = times * 24;
    hLine2 = plot( times, Par_Avg( radTest ) * 0.48, '.', ...
        'Color', parin_c);
    hLine3 = plot( times, sw_incoming( radTest ), '.', ...
        'Color', swin_c);

    if i == 1
        lh = legend( [ hLine1, hLine2, hLine3 ], ...
            'SWin_{pot}', 'scaled PPFD', 'SWin', ...
            'Location', 'NorthWest', 'Orientation', 'horizontal' );
        set( lh , 'Position', get( lh, 'Position') + [0 .05 0 0 ] );
    end

    % Label axes
    if i == 1 || i == 5 || i == 9 ;
        ylabel( hAx( 1 ), 'Radiation ( W m^2 )');
    end
end