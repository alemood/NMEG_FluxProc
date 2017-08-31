function T = text_2_table( fname, varargin )
% TEXT_2_TABLE - parse a generic delimited file to a matlab table
% array.
%
% Determines variable names, file size, and delimiter and loads file.
% This file requires a lot of manual manipulation, but is used to load and
% cr23x files from the PJ sites for now. Wireless downloads seem to be
% doing better than site visit downloads. The table get screwed up when
% downloading.
% %
% INPUTS:
%    fname: string; full path of file to be parsed
%    n_header_lines: integer; number of header lines.
%
% OUTPUTS:
%    T: matlab table array; the data from the TOA5 file
%
% SEE ALSO
%    table, cr23x_2_table
%
% author: Alex Moody, UNM, 2017

args = inputParser;
args.addRequired( 'fname' );
args.addParameter( 'n_header_lines',  0 , @isnumeric );
args.addParameter( 'captureTime', 0 , @islogical );

% parse optional inputs
args.parse( fname , varargin{ : } );
fname = args.Results.fname;
n_header_lines = args.Results.n_header_lines;
captureTime = args.Results.captureTime;

if strcmpi(fname,'nopath')
    % no files specified; prompt user to select files
    [ fname, pathname, filterindex ] = uigetfile( ...
        'select text file to open', ...
        fullfile( getenv('FLUXROOT'), 'SiteData' ), ...
        'MultiSelect', 'off' );
    fname =  fullfile( pathname, fname );
end

% Read the lines of the data file into a cell array
[ numlines, file_lines ] = parse_file_lines( fname );
% Get the delimiter
delim = detect_delimiter( fname );

% Parse file headers
if n_header_lines > 0
    header_lines = file_lines( 1: n_header_lines ) ;
    re = sprintf( '(?:^|%s)(\"(?:[^\"]+|\"\")*\"|[^%s]*)', delim, delim );
    var_names = regexp( header_lines, re, 'tokens' );
    var_names = [ var_names{ : } ];
    var_names = [ var_names{ : } ];% 'unnest' the cell array
end

% Separate data lines from header
file_lines = file_lines(n_header_lines + 1 : end);

if captureTime
    % match yyyy/mm/dd or mm/dd/yyyy; allow / or - as separator
    date_re = '(\d){1,4}[/-](\d){1,2}[/-](\d){2,4}';
    % match hh:mm or hh:mm:ss, allow one or two digits for all three fields
    time_re = '(\d{1,2}):(\d{1,2}):((\d{1,2})){0,1}';
    
    tstamp_re = [ date_re, '[\s,]*', time_re ];
    
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
    
    [ m n ] = size( tstamps);
    if m > n; ts_sz = m; else; ts_sz = n; end
    
    for i = 1:ts_sz
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
        error( 'invalid_timestamp', 'Error parsing CSV timestamp' )
    end
    
    dn = datenum( t_num( :, [ year_col, month_col, day_col, 4, 5, 6 ] ) );
    
end

% Count the number of columns in the file
try
    n_numeric_vars = length(var_names);
catch
    n_numeric_vars = 118;
end

% Count the number of numerics in each line of the raw data file
data_idx = cell(size(file_lines));
data_idx( : ) = {0};
fmt = repmat( sprintf( '%%f%s', delim ), 1, n_numeric_vars );
[ data, count ] = cellfun( @( x, idx ) sscanf( x( ( idx+1 ):end ), fmt ), ...
    file_lines, ...
    data_idx, ...
    'UniformOutput', false );

% reject lines with fewer than n_numeric_vars readable numbers
full_line = cellfun( @(x) size( x, 1 ), data ) == n_numeric_vars;
data = [ data{ find( full_line ) } ]';

T = array2table( data, 'VariableNames', var_names );
if captureTime
% Add a timestamp
T.timestamp = dn;
end

