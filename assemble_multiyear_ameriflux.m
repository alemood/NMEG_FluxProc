function tab = assemble_multi_year_ameriflux( sitecode, years, varargin )
% ASSEMBLE_MULTI_YEAR_AMERIFLUX - parses ameriflux files from a range of years
%   and appends them into one table
%
% USAGE:
%    tab = assemble_multi_year_ameriflux( sitecode, years )
%    tab = assemble_multi_year_ameriflux( sitecode, years, 'suffix', SUFFIX )
% INPUTS:
%    sitecode: integer or UNM_sites object; the site to be assembled
%    years: integer array; array of years
% PARAMETER-VALUE PAIRS
%    suffix: string; 'gapfilled' | {'with_gaps'} | {'soil'}
%    releasename: string; path to ameriflux files
%
% OUTPUTS:
%    tab: table containing the amerflux data for all requested years
%
% SEE ALSO
%    table, parse_ameriflux_file, UNM_parse_both_ameriflux_files
%
% author: Timothy W. Hilton, UNM, May 2012

% parse user arguments & typecheck
args = inputParser;
args.addRequired( 'sitecode', @(x) ( isnumeric(x) | isa( x, 'UNM_sites' ) ) );
args.addRequired( 'years', @isnumeric );
args.addParameter( 'suffix', 'with_gaps', ...
    @(x) ismember( x, { 'gapfilled', 'with_gaps', 'soil' } ) );
args.addParameter( 'path_to_aflx', '',@ischar)
args.parse( sitecode, years, varargin{ : } );
args = args.Results;

sitecode = args.sitecode;
years = args.years;

soil = false;
if strcmpi(args.suffix,'soil')
    soil = true;
end

% parse ASCII Ameriflux files
all_data = {};

% Pop up a dialog asking user to select release folder
if soil
    % Soil 'release' is just QCed soil data.
    releasename = fullfile(getenv('FLUXROOT'),'SiteData',...
        char(sitecode),'processed_soil');
elseif exist(args.path_to_aflx) ~= 7 | isempty(args.path_to_aflx)
    releasename = uigetdir(fullfile( getenv( 'FLUXROOT' ), ...
        'Ameriflux_files'));
else
    releasename = args.path_to_aflx;
end
%releasename = fullfile( getenv( 'FLUXROOT' ), ...
%        'Ameriflux_files', 'FLUXNET2015');

for i = 1:numel( years );
    if soil
        fname = sprintf('%s_%d_soilmet_qc_rbd.txt', char(sitecode) , years( i ) );
        fprintf( 'parsing %s\n', fname );
        fpath = fullfile( releasename, fname );
        if exist( fpath )
            this_data = parse_soilmet_qc_file( sitecode, ...
                years( i ), ...
                'suffix','qc_rbd' );
            all_data{ end+1 } = this_data;
            clear this_data;
        else
            fprintf( 'file does not exist - moving on...\n' );
        end      
    elseif ~soil
        % get this year's ameriflux data
        fname = sprintf( '%s_%d_%s.txt', ...
            UNM_sites_info( args.sitecode ).ameriflux, ...
            years( i ), ...
            args.suffix );
        fprintf( 'parsing %s\n', fname );
        fname = fullfile( releasename, fname );
        if exist( fname )
            this_data = parse_ameriflux_file( fname );
            
            % Get the timestamp for the table
            this_data = ameriflux_table_get_tstamp( this_data );
            
            all_data{ end+1 } = this_data;
            clear this_data;
        else
            fprintf( 'file does not exist - moving on\n' );
        end
    end
end

% now do some bookkeeping to combine the tables.  Any variables that are
% only present in a subset of years are filled with NaN
vars_all = all_data{ 1 }.Properties.VariableNames;
for i = 2:numel( all_data )
    vars_all = union( vars_all, all_data{ i }.Properties.VariableNames );
end
for i = 1:numel( all_data )
    vars_to_fill = setdiff( vars_all, all_data{ i }.Properties.VariableNames );
    if not( isempty (vars_to_fill ) )
        tab_fill = array2table( repmat( NaN, ...
            size( all_data{ i }, 1 ), ...
            numel( vars_to_fill ) ), ...
            'VariableNames', vars_to_fill );
        all_data{ i } = horzcat( all_data{ i }, tab_fill );
    end
end

% combine the years into one large table
tab = vertcat( all_data{ : } );

% verify timestamps
fprintf( 'verifying timestamps\n' );

tab = table_fill_timestamps( ...
    tab, ...
    'timestamp', ...
    't_min', datenum( min( years ), 1, 1 ), ...
    't_max', datenum( max( years ), 12, 31, 23, 59, 59 ) );

tab.YEAR = str2num( datestr( tab.timestamp, 'YYYY' ) );
tab.DTIME = tab.timestamp - datenum( tab.YEAR, 1, 1 ) + 1;
tab.DOY = floor( tab.DTIME );
tab.HRMIN = str2num( datestr( tab.timestamp, 'HHMM' ) );