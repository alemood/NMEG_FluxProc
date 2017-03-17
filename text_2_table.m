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

% parse optional inputs
args.parse( fname , varargin{ : } );
fname = args.Results.fname;
n_header_lines = args.Results.n_header_lines;

if strcmpi(fname,'nopath')
    % no files specified; prompt user to select files
    [ fname, pathname, filterindex ] = uigetfile( ...
        { '*.dat','Datalogger files (*.dat)' }, ...
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

