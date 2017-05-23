function [] = make_irga_comparison( sitecode, varargin )
% MAKE_IRGA_COMPARISON - compares open and closed path irgas. 
%
% Two NMEG sites, SLand and MCon_SS, run open and closed path IRGAs
% side-by-side. This code grapicially compares available datasets processed
% in Eddypro. Must use the fluxall file to retrieve open path data and
% specify the closed path data file
%
% SLand closed path starts 2015_06_17_0000
% MCon_SS closed path starts 2015_12_03_0000
% INPUTS
%    sitecode: UNM_sites object (or corresponding integer)
%    year: integer: four digit year
%    date_start: serial datenum
%    date_end: serial datenum
%
% OUTPUTS
%    h: figure handle to comparison plots
%
% SEE ALSO
%    
%
% author: Alex Moody, UNM, 2016

[ this_year, ~, ~, ~, ~, ~ ] = datevec( now() );

% check user arguments
args = inputParser;
args.addRequired( 'sitecode', ...
    @(x) ( isintval( x ) | isa( x, 'UNM_sites' ) ) );
args.addParameter( 'filterdata',false, @islogical ) 
args.addParameter( 'showfig',true, @islogical ) 
% args.addParameter( 'date_end', ...
%     @(x) ( isnumeric( x ) & ( x >= 2006 ) & ( x <= this_year ) ) );
% args.addRequired( 'suffix', ...
%     @(x) any( strcmp( x, { 'with_gaps', 'gapfilled', 'soil' } ) ) ) ;
% args.addOptional( 'version', ...
%     '', @ischar);

args.parse( sitecode, varargin{ : } );



% Get start date based on site
switch char(sitecode)
    case 'SLand'
        t_start = datenum([2017,2,22]);
        [year_start,~,~,~,~,~] = datevec(t_start);
    case 'MCon_SS'
        t_start = datenum([2016,1,1]);
        [year_start,~,~,~,~,~] = datevec(t_start);
end
t_end = floor(now - 60);
t_end = datenum([2017,3,21]);
[year_end,~,~,~,~,~] = datevec(t_end);
fprintf('Comparing %s IRGAs from %s to %s.\n',char(sitecode),datestr(t_start),datestr(t_end));

% Eddypro output variables
myvars = {  'timestamp' 'daytime' 'H' 'LE'    'co2_flux'  'h2o_flux' ...
    'co2_molar_density' 'co2_mole_fraction' 'co2_mixing_ratio'...
    'h2o_molar_density' 'h2o_mole_fraction' 'h2o_mixing_ratio' ...
    'un_H'    'un_LE'    'un_co2_flux'    'un_h2o_flux' ...
    };
ep_var = {'un_co2_flux' 'co2_flux',...
    'un_H', 'H',...
    'un_LE' 'LE',...
    'un_h2o_flux' 'h2o_flux'};
ep_var = {'H' 'LE'    'co2_flux'  'h2o_flux' ...
    'co2_molar_density' 'co2_mole_fraction' 'co2_mixing_ratio'...
    'h2o_molar_density' 'h2o_mole_fraction' 'h2o_mixing_ratio' ...
    'un_H'    'un_LE'    'un_co2_flux'    'un_h2o_flux'};

% Retrieve data. irga1 is open path, irga2 is closed path
yearlist = year_start:year_end;

T75 = table();
for i = 1:length(yearlist)
    fname75 = fullfile( getenv('FLUXROOT'), 'FluxOut/ep_data/', ...
        sprintf( '%s_ep_%d.mat', ...
        char( sitecode ), ...
        yearlist(i) ) );
    load(fname75);
    T75 = vertcat(T75,all_data( : , myvars ));
end

% HARD CODED BALOGNE
fname72 = fullfile( getenv('FLUXROOT'), 'FluxOut/ep_data/', ...
        sprintf( '%s_closedpath_ep_new_calibration.mat', ...
        char( sitecode ) ) );
load( fname72 );
T72 = all_data(:,myvars);

T = outerjoin( T75, T72, 'Keys', 'timestamp','MergeKeys',true );

% Discard data outside of requested time period
discard_idx = ( ( T.timestamp < t_start ) | ...
                ( T.timestamp > t_end ) ); 
T( discard_idx, : ) = [];
% Add correction magnitude columns
T.FCcorrect_T72 = T{:,'un_co2_flux_T72'} - T{:,'co2_flux_T72'} ;
T.FCcorrect_T75 = T{:,'un_co2_flux_T75'} - T{:,'co2_flux_T75'} ;
T.daytime_T75 = [];
ts = T.timestamp;

% Elementary RBD 
windowsize = 1 ;
std_dev = 3.5;
max_diff = 40;
ignore_nans = true;
debug_plots = false;

if args.Results.filterdata
    for i = 1:length(ep_var)
        % Filter Open Path Variable
        cvarname = strcat( ep_var{ i } , '_T72' );
        cvar = T{:,cvarname};
        [c_filtered, ~]  = filterseries( cvar , 'sigma' , 48*windowsize, ...
            max_diff, ignore_nans, debug_plots);
        [c_filtered, ~]  = filterseries( c_filtered , 'shift' , [], ...
            max_diff, ignore_nans, debug_plots);
        T{:,cvarname} = c_filtered;
        % Filter closed path variable
        ovarname = strcat( ep_var{ i } , '_T75' );
        ovar = T{:,ovarname};
        [o_filtered, ~]  = filterseries( ovar ,'sigma', 48*windowsize, ...
            std_dev, ignore_nans, debug_plots);
        [o_filtered, ~]  = filterseries( o_filtered , 'shift' , [], ...
            max_diff, ignore_nans, debug_plots);
        T{:,ovarname} = o_filtered;
    end
end

if args.Results.showfig
type = 'irga';
% For comparing open and closed path analyzers from eddypro processing
 for i=1:length( ep_var )
       closedvar = strcat( ep_var{ i } , '_T72' );
       openvar = strcat( ep_var{ i } , '_T75' );
       varname = char( ep_var{ i } ) ; 
       plot_bivariate_comparison( T{:,openvar},T{:,closedvar},...
                                  T.timestamp, type, ...
                                  'fig_name', varname , ...
                                  'sitecode' , char(sitecode) );
        %------- Plot cumulative NEE 
        if strcmpi( varname ,'co2_flux') 
            T = eddypro_rbd( T, openvar );
            T = eddypro_rbd( T, closedvar);            
            NEEaxis = figure;
            handles = compare_cumulative_series( NEEaxis, T ); 
        end
 end 
 %------- Plot corrected/uncorrected FC  
 plot_bivariate_comparison( T{:,'un_co2_flux_T72'},T{:,'co2_flux_T72'},...
                            T.timestamp, type, ...
                            'fig_name', 'Corrected vs Uncorrected FC, Closed' , ...
                            'sitecode' , char(sitecode) );
 plot_bivariate_comparison( T{:,'un_co2_flux_T75'},T{:,'co2_flux_T75'},...
                            T.timestamp, type, ...
                            'fig_name', 'Corrected vs Uncorrected FC, Open' , ...
                            'sitecode' , char(sitecode) );
end
 

 % Calculate some basic stats
 statT =  grpstats(T,{'daytime_T72'},{'min','max','mean'});
 statT(:,1:5) = [];
 % Do some reshaping to print table to txt file
 checkstats = statT;
 statT =  table2array(statT);
 nightstat = reshape(statT(1,(1:end)),3,30)';
 daystat = reshape(statT(2,(1:end)),3,30)';
 allstats = horzcat(nightstat,daystat);
 Tprint =array2table(allstats);
 T.daytime_T72 = [];
 Tprint.Properties.RowNames = T.Properties.VariableNames(2:end);
 Tprint.Properties.VariableNames = ...
     {'nightMin' 'nightMax' 'nightMean' 'dayMin' 'dayMax' 'dayMean'};
 Tprint = sortrows(Tprint,'RowNames');
 writetable(Tprint, ...
     fullfile(getenv('FLUXROOT'),'QAQC_analyses',...
        strcat(char(sitecode),'_irga_compare_stats.csv')),...
     'Delimiter',',',...
     'WriteRowNames',true );

% ---------------
% Subfunctions
%---------------
% Plot the cumulative series
function handles = compare_cumulative_series( axis, tbl )

        tbl_vars = {'co2_flux_T75' 'co2_flux_T72'};
        %sc = -1; % GPP has a negative sign convention
            
        plot( tbl.timestamp, ...
            nan_cumsum( tbl.( tbl_vars{ 1 } )) * sc, '.k' );
        hold on;
        plot( tbl.timestamp, ...
            nan_cumsum( tbl.( tbl_vars{ 2 } )) * sc, '.b' );
        
        ylabel(  'Cum. NEE (umol/m2/s)' );
        datetick();
        legend( 'Open Path' , 'Closed Path' );
        handles = axis;
end

% Small function to cumsum over invalid values ( NaN )
function nonan = nan_cumsum( arr )
    nonan = arr;
    nonan( find( isnan( nonan ) )) = 0;
    nonan = cumsum( nonan );
end

function tbl = eddypro_rbd( tbl_in , var )
%    bad_idx = (  tbl_in.(var) > prctile(tbl_in.(var), 99.8) & ...
%                     tbl_in.(var) < prctile(tbl_in.(var), 0.1) );
%    tbl_in{ bad_idx , var } = NaN ;
   bad_idx = find((  tbl_in.(var) > 30  | ...
                    tbl_in.(var) < -30 ));
   tbl_in{ bad_idx , var } = NaN ;
   tbl = tbl_in;
end
end
%    savefig( h , fullfile( getenv('FLUXROOT'),'SiteData', ...
%        sitecode,'fluxcompare_plots',num2str(year) ) )