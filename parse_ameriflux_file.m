function amflux_tab = parse_ameriflux_file( fname , varargin)
% PARSE_AMERIFLUX_FILE - parse an ameriflux file to a matlab table
%
% If necessary, variable names are converted to Matlab-legal variable names
% using genvarname.
% 
% USAGE:
%   amflux_tab = parse_ameriflux_file( fname )
%
% INPUTS
%   fname: character string; full path to the Ameriflux file to be parsed
%
% OUTPUTS
%   amflux_tab: table array containing the parsed Ameriflux data
%
% SEE ALSO
%   table, genvarname
%
% author: Timothy W. Hilton, UNM, Dec 2011
% modified by -Gregory E. Maurer, UNM, Feb 2016 ; 
%             - Alex Moody, UNM, Sep 2016

args = inputParser;
args.addRequired( 'fname', @ischar );
args.addParameter( 'version', 'in_house', @ischar);

args.parse( fname, varargin{ : } );

fname = args.Results.fname;
version = args.Results.version;

if strcmp(version,'in_house')
    headerlines = 6;
else
    headerlines = 0;
end

delim = detect_delimiter( fname );

fid = fopen( fname, 'r' );

for i = 1:headerlines
    discard = fgetl( fid );
end

var_names = fgetl( fid );
var_names = regexp( var_names, delim, 'split' );
var_names = cellfun( @char, var_names, 'UniformOutput',  false );
var_names = cellfun( @genvarname, var_names, 'UniformOutput',  false );

if strcmp(version,'in_house')
var_units = fgetl( fid );
var_units = regexp( var_units, delim, 'split' );
var_units = cellfun( @char, var_units, 'UniformOutput',  false );
end

n_vars = numel( var_names );
fmt = repmat( '%f', 1, n_vars );
data = cell2mat( textscan( fid, fmt, 'delimiter', delim ) );
data =  replace_badvals( data, [ -9999 ], 1e-10 );

fclose( fid );

amflux_tab = array2table( data, 'VariableNames', var_names );
if strcmp( version , 'in_house' )
amflux_tab.Properties.VariableUnits =  var_units;
end

