function amflux_tab = parse_aflx_daily_file( fname )
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
% modified by Gregory E. Maurer, UNM, Feb 2016

headerlines = 6;
delim = detect_delimiter( fname );

fid = fopen( fname, 'r' );

for i = 1:headerlines
    discard = fgetl( fid );
end

var_names = fgetl( fid );
var_names = regexp( var_names, delim, 'split' );
var_names = cellfun( @char, var_names, 'UniformOutput',  false );
var_names = cellfun( @genvarname, var_names, 'UniformOutput',  false );
var_names{1} = 'TIMESTAMP';
%warning('Parse_aflx_daily_file is NOT deprecated...apparently');
%var_units = fgetl( fid );
%var_units = regexp( var_units, delim, 'split' );
%var_units = cellfun( @char, var_units, 'UniformOutput',  false );

n_vars = numel( var_names );
%fmt = ['%s', repmat( ',%f', 1, n_vars -1  )];
file_lines = textscan(fid, '%s', 'delimiter', '\n');
fclose( fid );

file_lines = file_lines{:,1};
file_lines = strrep(file_lines,'NA','-9999');

data = cellfun(@(x) strsplit(x,delim), file_lines, 'UniformOutput', false);
data = vertcat(data{:}); %unnest cell arrays
data(:,1) = cellfun(@(x) datenum(x,'yyyy-mm-dd'), data(:,1),'UniformOutput',false); %serialize dates
data(:,2:end) = cellfun(@(x) str2num(x), data(:,2:end), 'UniformOutput', false);   % Convert strings to numbers


%file_lines = strrep( file_lines, 'NA', '-9999');
%data = cell2mat( data );
%data =  replace_badvals( data, [ -9999 ], 1e-10 );



amflux_tab = cell2table( data, 'VariableNames', var_names );
amflux_tab = replace_badvals( amflux_tab, [-9999], 1e-10 );
%amflux_tab.Properties.VariableUnits =  var_units;


