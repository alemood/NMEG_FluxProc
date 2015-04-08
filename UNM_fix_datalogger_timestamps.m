function dataTableShifted = UNM_fix_datalogger_timestamps( sitecode, year, ...
    dataTable, ...
    varargin )
% UNM_FIX_DATALOGGER_TIMESTAMPS - corrects shifts in the timestamps for
% particular periods.
%
% Called from UNM_RemoveBadData to correct shifts in the timestamps for
% particular periods.  This file simply contains the periods that need 
% to be shifted. If asked it will produce diagnostic plots that can be
% used to determine the time shifts to be applied to the data. Script calls
% shift_data to make the data shifts.
%
% INPUTS
%    sitecode: UNM_sites object; specifies the site to show
%    year: four-digit year: specifies the year to show
%    dataTable: NxM matlab table: the data to be fixed
% PARAMETER-VALUE PAIRS
%    debug: {true}|false; if true, several before & after correction plots
%        are drawn to the screen
%    save_figs: {true}|false; if true, the debug plots are saved to
%        $PLOTS/Rad_Fingerprints/SITE_YEAR_Rg_fingerprints.eps.
%        $PLOTS/Rad_Fingerprints is created if it does not exist.
%
% SEE ALSO
%    UNM_sites, dataset, UNM_site_plot_fullyear_time_offsets, shift_data,
%    plot_fixed_datalogger_timestamps
%
% author: Timothy W. Hilton, UNM, June 2012
% modified by: Gregory E. Maurer, UNM, February 2015

[ this_year, ~, ~ ] = datevec( now );

% -----
% define optional inputs, with defaults and typechecking
% -----
args = inputParser;
args.addRequired( 'sitecode', @(x) ( isintval( x ) | isa( x, 'UNM_sites' ) ) );
args.addRequired( 'year', @(x) ( isintval( x ) & ( x >= 2006 ) & ...
    ( x <= this_year ) ) );
args.addRequired( 'dataTable', @istable );
args.addParamValue( 'debug', true, @islogical );
args.addParamValue( 'save_figs', true, @islogical );

% parse optional inputs
args.parse( sitecode, year, dataTable, varargin{ : } );

sitecode = args.Results.sitecode;
year = args.Results.year;
dataTable = args.Results.dataTable;
debug = args.Results.debug;
save_figs = args.Results.save_figs;

% Get data dimensions and headers
[ nRows, nCols ] = size( dataTable );
colHeaders = dataTable.Properties.VariableNames;

% Determine column locations of 10hz and 30min data
first10hzCol = find( strcmp( 'iok', colHeaders ));
first30MinCol = find( strcmp( 'Fc_wpl', colHeaders ));
timestampCol = find( strcmp( 'timestamp', colHeaders ));
% Check for other timestamps in the file
otherTimestamps = cellfun(@(x) ~isempty( regexpi( x, 'timestamp' )), ...
    colHeaders( : ));
if sum( otherTimestamps > 1 );
    warning( ' Multiple timestamp columns exist in this FLUXALL file! ' );
end

% Get column indices for 10 hz ("matlab") data
all10hzCols = first10hzCol:first30MinCol - 1;
if ismember( nCols, timestampCol );
    all30MinCols = first30MinCol:nCols - 1; % Exclude last timestamp column
    allCols = first10hzCol:nCols - 1;
elseif timestampCol < first10hzCol
    all30MinCols = first30MinCol:nCols; % Don't exclude last column
    allCols = first10hzCol:nCols;
else
    error(' Timestamp column is misplaced in this FLUXALL data! ');
end

%--------------------------------------------------------------------------

% Extract the numeric data from the table (shift_data.m requires this)
data = table2array( dataTable );

% ============================= SHIFT DATA ================================
% Go through each site and shift the data in 'data'
switch sitecode
    case UNM_sites.GLand
        switch year
            case 2007
                data = shift_data( data, -1.0 );
                row_idx = DOYidx( 38 ) : DOYidx( 69 );
                % FIXME - Column indexes like this are total BS
                col_idx = [ 1:144, 146:size( data, 2 ) ]; % all but SW_in
                data( row_idx, : ) = shift_data( data( row_idx, : ), ...
                    -1.0, col_idx );
                data = shift_data( data, -0.5, all10hzCols );
            case 2008
                data = shift_data( data, -1.0, all30MinCols );
                data = shift_data( data, -0.5, all10hzCols );
            case 2009
%                 idx = 1 : DOYidx( 58 );
%                 data( idx, : ) = shift_data( data( idx, : ),  -1.0, ...
%                     all30MinCols );
%                 idx = DOYidx( 82 ) : size( data, 1 );
%                 data( idx, : ) = shift_data( data( idx, : ),  -0.5, ...
%                     all30MinCols );
%                 
%                 idx = DOYidx( 295 ) : DOYidx( 330 );
%                 data( idx, : ) = shift_data( data( idx, : ), -2.0, ...
%                     all10hzCols );
%                 idx = DOYidx( 27 ) : DOYidx( 50 );
%                 data( idx, : ) = shift_data( data( idx, : ), -1.0, ...
%                     all10hzCols );
%                 
%                 data = shift_data( data, 0.5, all10hzCols );
                % There was a .5 hour shift and then it looks like clock
                % was set to DST on day 66
                preClockSet = 1 : DOYidx( 66.57 );
                data( preClockSet, : ) = ...
                    shift_data( data( preClockSet, : ), 0.5, allCols );
                % Data for rest of year need to be shifted 1.5 hours
                postClockSet = DOYidx( 66.58 ) : size( data, 1 );
                data( postClockSet, : ) = ...
                    shift_data( data( postClockSet, : ), 1.5, allCols );
                
            case { 2010, 2011 }
                data = shift_data( data, 1.5, allCols );
%             case 2011
%                 data = shift_data( data, 1.0, all30MinCols );
%                 data = shift_data( data, 0.5, all10hzCols );
            case 2012
                % Clock change on Dec 07 at 12:55
                clockSet = datenum( 2012, 12, 7, 12, 55, 0 ) - ...
                    datenum( 2012, 1, 0 );
                idx = 1 : DOYidx( clockSet  );
                data( idx, : ) = shift_data( data( idx, : ), 1.0, allCols );
                % The entire year must shift an additional 0.5 hours
                data = shift_data( data, 0.5, allCols );
            case { 2013, 2014 }
                data = shift_data( data, 0.5, allCols );
        end
        
    case UNM_sites.SLand
        switch year
            case 2007
                % idx = 1: DOYidx( 150 );
                % data( idx, : ) = shift_data( data( idx, : ), 0.5, ...
                %   all10hzCols );
                % col_idx = [ 76:145, 147:size( data, 2 ) ]
                % data( idx, : ) = shift_data( data( idx, : ), -0.5, ...
                %   col_idx );
                % idx = DOYidx( 45 ) : DOYidx( 60 );
                % col_idx = [ 1:144, 146:size( data, 2 ) ];
                % data( idx, : ) = shift_data( data( idx, : ), -1.0, ...
                %   col_idx);
            case 2008
                % idx = [ 1: DOYidx( 5 ), DOYidx( 20 ) : size( data, 1 ) ];
                % data( idx, : ) = shift_data( data( idx, : ), 1.0, ...
                %   all30MinCols );
                data = shift_data( data, -1.0, all30MinCols );
                data = shift_data( data, -0.5, all10hzCols );
%             case 2009
%                 idx = 1 : DOYidx( 64 );
%                 data( idx, : ) = shift_data( data( idx, : ),  -1.0, ...
%                     all30MinCols );
            case { 2009 2010 2011 2012 2013 2014 }
                data = shift_data( data, 0.5, allCols );
%             case 2011
%                 idx = DOYidx( 137 ) : DOYidx( 165 );
%                 data( idx, : ) = shift_data( data( idx, : ),  -0.5, ...
%                     all30MinCols );
        end
        
    case UNM_sites.JSav
        switch year
            case 2007
                doy_col = 8;  % day of year column in JSav_FluxAll_2007.xls
                idx = find( ( data( :, doy_col ) >= 324 ) & ...
                    ( data( :, doy_col ) <= 335 ) );
                data( idx, : ) = shift_data( data( idx, : ),  1.0, ...
                    all30MinCols );
            case { 2009, 2010, 2011, 2012, 2013, 2014 }
                data = shift_data( data, 0.5, allCols );
        end
        
    case UNM_sites.PJ
        switch year
            case { 2009, 2010, 2011 }
                data = shift_data( data, 1.5, allCols );
                % data = shift_data( data, 0.5, all10hzCols );
            case 2012
                % Looks like datalogger clock was reset around day 342
                preResetIdx = 1 : DOYidx( 342.625 );
                data( preResetIdx, : ) = ...
                    shift_data( data( preResetIdx, : ), 1.5, allCols );
                % Data for rest of year still need to be shifted .5 hours
                postResetIdx = DOYidx( 342.64 ) : size( data, 1 );
                data( postResetIdx, : ) = ...
                    shift_data( data( postResetIdx, : ), 0.5, allCols );
            case { 2013, 2014 }
                data = shift_data( data, 0.5, allCols );
        end
    case UNM_sites.PJ_girdle
        switch year
            case { 2009, 2010, 2011, 2012, 2013, 2014 };
                data = shift_data( data, 0.5, allCols );
        end
        
    case UNM_sites.PPine
        switch year
            case 2007
                idx = DOYidx( 156.12 ) : DOYidx( 177.5 );
                % FIXME - Why shift just sonic temp?
                Tdry_col = 14;  %shift temperature record
                data( idx, : ) = shift_data( data( idx, : ), -1.5, ...
                    Tdry_col );
            case { 2009 2010 }
                data = shift_data( data, 1.5, allCols );
                % No idea why all this is below - GEM
%                 idx = DOYidx( 261 ) : DOYidx( 267 );
%                 data( idx, : ) = shift_data( data( idx, : ), -2.5, ...
%                     all30MinCols );
%                 idx = DOYidx( 267 ) : ( DOYidx( 268 ) - 1 );
%                 data( idx, : ) = shift_data( data( idx, : ), -3.0, ...
%                     all30MinCols );
%                 idx = DOYidx( 268 ) : DOYidx( 283 );
%                 data( idx, : ) = shift_data( data( idx, : ), -3.5, ...
%                     all30MinCols );
%                 idx = DOYidx( 283.0 ) : DOYidx( 293.5 );
%                 data( idx, : ) = shift_data( data( idx, : ), -4.5, ...
%                     all30MinCols );
%                 
%             case 2010
%                 data = shift_data( data, 1.0, all30MinCols );
                
            case 2011
                % Looks like datalogger clock was reset around day 54
                preClockSet = 1 : DOYidx( 54.395 );
                data( preClockSet, : ) = ...
                    shift_data( data( preClockSet, : ), 1.5, allCols );
                % Data for rest of year need to be shifted 0.5 hours
                postClockSet = DOYidx( 54.416 ) : size( data, 1 );
                data( postClockSet, : ) = ...
                    shift_data( data( postClockSet, : ), 1.0, allCols );
                
            case 2012 
                data = shift_data( data, 1.0, allCols );
                
            case 2013
                data = shift_data( data, 1.0, allCols );
                % There is a small period in Nov-Dec where time is shifted
                % even further
                shiftIdx = DOYidx( 323.69 ) : DOYidx( 362.52 );
                data( shiftIdx, : ) = ...
                    shift_data( data( shiftIdx, : ), 1.0, allCols );
            case 2014
                data = shift_data( data, 1.0, allCols );
                % There is a period in the summer where time is shifted
                % even further
                shiftIdx = DOYidx( 172.52 ) : DOYidx( 282.52 );
                data( shiftIdx, : ) = ...
                    shift_data( data( shiftIdx, : ), 1.0, allCols );
        end
        
    case UNM_sites.MCon
        switch year
            case 2008
                idx = DOYidx( 341.0 ) : size( data, 1 );
                data( idx, : ) = shift_data( data( idx, : ), 1.0, ...
                    all30MinCols );
                idx = 1 : DOYidx( 155 );
                data( idx, : ) = shift_data( data( idx, : ), -0.5, ...
                    all30MinCols );
            case 2009
                idx = DOYidx( 351.5 ) : size( data, 1 );
                data( idx, : ) = shift_data( data( idx, : ), 1.5, ...
                    all30MinCols );
                idx = DOYidx( 20 ) : size( data, 1 );
                data( idx, : ) = shift_data( data( idx, : ), 0.5, ...
                    all10hzCols);
                data = shift_data( data, 0.5, all10hzCols);
            case 2010
                col_idx = allCols;
                data = shift_data( data, 1.0, col_idx );
                idx = DOYidx( 25 ) : DOYidx( 47 );
                data( idx, : ) = shift_data( data( idx, : ), 1.0, col_idx);
                idx = DOYidx( 300 ) : size( data, 1 );
                data( idx, : ) = shift_data( data( idx, : ), 0.5, col_idx);
            case 2011
                col_idx = allCols;
                idx = 1 : DOYidx( 12.0 );
                data( idx, : ) = shift_data( data( idx, : ),  1.5, col_idx );
                idx = DOYidx( 12.0 ) : DOYidx( 48.0 );
                data( idx, : ) = shift_data( data( idx, : ),  2.5, col_idx );
                
            case 2012
                col_idx = allCols;
                idx = DOYidx( 133 ) : DOYidx( 224.0 );
                data( idx, : ) = shift_data( data( idx, : ), 4.5, col_idx );
                
                col_idx = allCols;
                
                Aug11_1710 = datenum( 2012, 8, 11, 17, 10, 0 ) - ...
                    datenum( 2012, 1, 0 );
                Nov14_1200 = datenum( 2012, 11, 14, 12, 0, 0 ) - ...
                    datenum( 2012, 1, 0 );
                Aug11_1710 = DOYidx( Aug11_1710 );
                Nov14_1200 = DOYidx( Nov14_1200 );
                Sep19_1700 = DOYidx( datenum( 2012, 9, 19, 17, 0, 0 ) - ...
                    datenum( 2012, 1, 0 ) );
                
                % data( Aug11_1710:Sep19_1700, : ) = ...
                %     shift_data( data( Aug11_1710:Sep19_1700, : ), 3.5, ...
                %                 'cols_to_shift', col_idx );
                data( Sep19_1700:Nov14_1200, : ) = ...
                    shift_data( data( Sep19_1700:Nov14_1200, : ), -3.5, ...
                    col_idx );
                
                % compensate for the 11 Aug 2012 datalogger clock reset
                % so that the clock would match the Ameriflux tech's clock.
                % From Skyler: "I swapped the card beforehand then changed
                % the clock from Aug 11, 2012 20:54 to Aug 11,
                % 2012 17:10."
                data( Aug11_1710:Nov14_1200, : ) = ...
                    shift_data( data( Aug11_1710:Nov14_1200, : ), 4.5, ...
                    col_idx );
                
            case 2013
                col_idx = allCols;
                idx = 1 : DOYidx( 30 );
                data( idx , : ) = shift_data( data( idx, : ), -0.5);%, col_idx );
                % idx = DOYidx( 72.01 ) : DOYidx( 337 );
                % data( idx , : ) = shift_data( data( idx, : ), 1.5, ...
                %     col_idx);
                % idx = DOYidx( 337.01 ) : DOYidx( 342 );
                % data( idx , : ) = shift_data( data( idx, : ), 1.0, ...
                %     all30MinCols );
                % idx = DOYidx( 342.01 ) : DOYidx( 365.98 );
                % data( idx , : ) = shift_data( data( idx, : ), 2.0 , ...
                %     col_idx);
        end
        
    case UNM_sites.TX
        switch year
            case { 2007, 2008, 2010, 2011, 2012 }
                data = shift_data( data, 1.0, all30MinCols );
            case 2009
                data = shift_data( data, 1.0, all30MinCols );
                idx = DOYidx( 314 ) : size( data, 1 );
                data( idx, : ) = shift_data( data( idx, : ), 1.0, ...
                    all30MinCols );
        end
        
    case UNM_sites.New_GLand
        switch year
            case 2010
                % Clock reset occured at 3pm on 6/27
                preClockSet = 1 : DOYidx( 178.6042 );
                data( preClockSet, : ) = ...
                    shift_data( data( preClockSet, : ), 0.5, allCols );
                % Data for rest of year need to be shifted 1.5 hours
                postClockSet = DOYidx( 178.625 ) : size( data, 1 );
                data( postClockSet, : ) = ...
                    shift_data( data( postClockSet, : ), 1.5, allCols );
            case 2011
                data = shift_data( data, 1.5, allCols );
            case 2012
                preClockSet = 1 : DOYidx( 342.625 );
                data( preClockSet, : ) = ...
                    shift_data( data( preClockSet, : ), 1.5, allCols );
                % Data for rest of year need to be shifted 0.5 hours
                postClockSet = DOYidx( 342.645 ) : size( data, 1 );
                data( postClockSet, : ) = ...
                    shift_data( data( postClockSet, : ), 0.5, allCols );
            case { 2013 2014 }
                data = shift_data( data, 0.5, allCols );
        end
        
end

%--------------------------------------------------------------------------

% Create the shifted table from the data array and the column names from
% the original dataTable
dataTableShifted = array2table( data, 'VariableNames', ...
    dataTable.Properties.VariableNames );

% Verify that data table timestamps are the same
test = dataTableShifted.timestamp == dataTable.timestamp;
if sum( test ) ~= nRows;
    error( ' The timestamps of the 2 created tables do not match ');
end

%==========================================================================
% Diagnostic plots
if debug
    diagnosticFig = plot_fixed_datalogger_timestamps( sitecode, year, ...
                                                      dataTable, ...
                                                      dataTableShifted );
    if save_figs
        save_dir = fullfile( getenv( 'PLOTS' ), 'Rad_Fingerprints' );
        is_folder = 7; % exist returns 7 if argument is a directory
        if exist( save_dir ) ~= is_folder
            mkdir( getenv( 'PLOTS' ), 'Rad_Fingerprints' );
        end
        
        fname = fullfile( save_dir, ...
            sprintf( '%s_%d_Rg_fingerprints.eps', ...
            char( sitecode ), year ) );
        
        fprintf( 'saving %s\n', fname );
        figure_2_eps( diagnosticFig, fname );
    end
end

% End function
end