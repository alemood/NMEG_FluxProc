% function parse_81x_file
fname  = 'C:\Research_Flux_Towers\SiteData\PJ\LI-8100-RawDataCards\PJC_8100_28Oct16.81x';

[n,flines] = parse_file_lines( fname );
flines = flines(1:9004);
% During the sampling period, there are around 26 seconds of timestamps
n_sample_vars = 20;
% Find empty lines, these denote transition to another sampling period
empty_idx = find(cellfun(@isempty,flines));
data_idx = find( cellfun(@isempty,flines));

% Splits each line into number of entries. Total columns = number of
% entries. 
flines_split = cellfun( @( x )  regexp( x , '\t', 'split'), ...
    flines, ...
    'UniformOutput',false);
flines_size = cellfun(@length, flines_split, 'UniformOutput',false)';

%-------------------------
% SELECT VARIABLES
%-------------------------
var_names = {'Obs#' 'Port#' 'Label' ...
    'Tcase' 'Tmux' 'Vin' 'V1' ...
    'TimeClosing' 'CrvFitStatus' ...
    'Lin_Flux' 'Lin_FluxCV' 'Lin_R2' ...
    'Exp_Flux' 'Exp_FluxCV' 'Exp_R2' 'Exp_Iter' ...
    


% Pull out desired variables
fmt =   'Lin_Flux:%f'; % This variable
[ lin_flux, count ] = cellfun( @( x, idx ) sscanf( x, fmt ), ...
    flines, ...
    'UniformOutput', false );
lin_flux = [lin_flux{:}];
 %find(~cellfun('isempty',lin_flux)); 

re = 'Lin_Flux*';
lin_flux = cellfun(@( x ) regexp( x , re ), flines, 'UniformOutput',false);
% Toss the observation data timeseries. These are still in the raw files,
% but for our purposes, we just need flux output.

[ data, count ] = cellfun( @( x) sscanf( x , '%s' ), ...
    flines_split, ...
    'UniformOutput', false );


throw_idx = find(cell2mat(flines_size) > 20 );
flines_split(throw_idx) = [];






% reject lines with fewer than n_numeric_vars readable numbers
full_line = cellfun( @(x) size( x, 1 ), data ) == n_numeric_vars;
data = [ data{ find( full_line ) } ]';