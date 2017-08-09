function T = eddypro_2_table( varargin )
% EDDYPRO_2_TABLE - parse an EddyPro full output CSV file to a matlab table
% array. 
%
% Uses parse_edypro_file_headers to determine variable names, variable units,
% file size, and delimiter.  Adds a 'timestamp' variable of the file's
% timetamps converted to Matlab serial datenumbers.  Uses clean_up_varnames
% to convert variable names to legal Matlab variables.
% 
% INPUTS:
%    fname: string; full path of file to be parsed
%
% OUTPUTS:
%    T: matlab table array; the data from the TOA5 file
%
% SEE ALSO
%    table, datenum, parse_TOA5_file_headers, clean_up_varnames
%
% author: Alex Moody, UNM, April 2016
% modified from: toa5_2_dataset by Timothy Hilton

if nargin==0
    % no files specified; prompt user to select files
    [ fname, pathname, filterindex ] = uigetfile( ...
        { '*.*','All files' }, ...
        'select CSV file to open', ...
         fullfile( getenv('FLUXROOT'), 'SiteData' ), ...
        'MultiSelect', 'on' );
    fname =  fullfile( pathname, fname );
else
    fname = varargin{1};
end

[ var_names, var_units, file_lines, first_data_line, delim ] = ...
    parse_eddypro_file_headers( fname );

% scan the data portion of the matrix into a matlab array
n_numeric_vars = length( var_names ) - 3; % all the variables except
% the timestamp

% done with header now
file_lines = file_lines( first_data_line : end );

%remove quotations from the file text (some NaNs are quoted)
file_lines = strrep( file_lines, '"', '' );

% ---------
% parse timestamps into matlab datenums
%
% There are a variety of timestamp formats in the TOA5 files:
% yyyy/mm/dd, mm/dd/yyyy both appear, sometimes with '-' instead of
% '/'. Months 1 to 9 are sometimes written with one digit, sometimes two
% (with leading zero).
% For times, HH:MM:SS, with seconds somtimes omitted and HH and MM
% sometimes only having one digit.  This code uses regular expressions to
% identify the timestamps and pull the numeric components into tokens.
%
% match yyyy/mm/dd or mm/dd/yyyy; allow / or - as separator
date_re = '(\d){1,4}[/-](\d){1,2}[/-](\d){2,4}';
% match hh:mm or hh:mm:ss, allow one or two digits for all three fields
time_re = '(\d{1,2}):(\d{1,2})(:(\d{1,2})){0,1}';
tstamp_re = [ date_re, ',*', time_re ];

% find timestamps
[ tstamps, data_idx ] = regexp( file_lines, ...
    tstamp_re, 'tokens', 'end' );

% reject lines with no valid timestamp
has_valid_tstamp = not( cellfun( @isempty, tstamps ) );
file_lines = file_lines( has_valid_tstamp );
tstamps = tstamps( has_valid_tstamp );
data_idx = data_idx( has_valid_tstamp );

% reformulate tstamps to Nx6 array of doubles
t_num = cell( size( tstamps, 1 ), 6 );
for i = 1:size( tstamps )
    t_num( i, : ) = tstamps{ i }{ 1 };
    t_num{ i, 6 }  = strrep( t_num{ i, 6 }, ':', '' );
    if isempty( t_num{ i, 6 } )
        t_num{ i, 6 } = '00';
    end
end
t_num = cellfun( @str2num, t_num );

% year could be in column 1 or column 3
temp = sum( t_num > 2000 );
year_col = find( temp == max( temp ) );
if year_col == 1
    month_col = 2;
    day_col = 3;
elseif year_col == 3
    month_col = 1;
    day_col = 2;
else
    error( 'invalid_timestamp', 'Error parsing TOA5 timestamp' )
end

dn = datenum( t_num( :, [ year_col, month_col, day_col, 4, 5, 6 ] ) );

fmt = repmat( sprintf( '%s%%f', delim ), 1, n_numeric_vars );
[ data, count ] = cellfun( @( x, idx ) sscanf( x( ( idx+1 ):end ), fmt ), ...
    file_lines, ...
    data_idx, ...
    'UniformOutput', false );

% reject lines with fewer than n_numeric_vars readable numbers
full_line = cellfun( @(x) size( x, 1 ), data ) == n_numeric_vars;
data = [ data{ find( full_line ) } ]';

% Clean up timestamp units and variable names
var_units = var_units( 3:end );
var_names = clean_up_varnames( var_names( 4:end ) );

% There are two columns called mean at the end of the eddypro file that are
% not needed and that interfere with the combination of the fluxall and
% eddypro tables.
idx = find( ~cellfun( @isempty, regexp( var_names, 'mean(?!.)' ) ) );
data(:,idx) = [];
var_units(:,idx) = [];
var_names(:,idx) = [];
T = array2table( data, 'VariableNames', var_names );
T.Properties.VariableUnits = var_units;
% add timestamp
T.timestamp = dn;