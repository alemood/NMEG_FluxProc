function success = insert_new_sev_met_data( varargin )

% INSERT_NEW_SEV_MET_DATA - Adds new measurements from the Deepwell ( ID 40) 
% and Fivepoints (ID 49) met stations at the Sevilleta NWR to the current 
% ancillary met data file.
%
% As of 2011, and due to header changes in the past, this file has the name
% sev1_meteorology_2011-YYYY , where YYYY is the year of the latest data in
% the file. 
%
% USAGE
%  
%
% INPUTS
%   new_met_path : optional string, full path to most recent download from FTP
% OUTPUTS
%   success : logical , true if this script executes properly, false
%   otherwise.
%
% SEE ALSO:
%     
%
% author: Alex Moody , UNM, 2017

success = 0;

path = fullfile(getenv('FLUXROOT'), 'Ancillary_met_data');
fname_re = [ 'sev1_meteorology_2011-\d\d\d\d.txt'];
file_list = list_files( path, fname_re );

oldMet = readtable( file_list{1}, 'Delimiter', ',' );

% If no file path defined, pull up GUI interface
if nargin==0
    % no files specified; prompt user to select files
    [ fname, pathname, filterindex ] = uigetfile( ...
        { '*.dat','Datalogger files (*.dat)' }, ...
        'select CR10 file to open', ...
         path, ...
        'MultiSelect', 'off' );
    fname =  fullfile( pathname, fname );
else
    fname = varargin{1};
end

thisStation = regexp(fname,'Met(\d){1,2}_[\w]+_CR10_1.dat','tokens');
thisStation = [thisStation{:}];
thisStation = thisStation{1,1};

newMet = readtable( fname , 'Delimiter', ',' );

% Remove timestamps that are in the old met table
% idx = find(newMet.Var2 < 2016) ;
% newMet(idx,:) = [];

% Remove rows without the appropriate site ID
idx = find(newMet.Var1 ~= str2num( thisStation) ) ;
newMet(idx,:) = [];

% Remove rows with odd timestamps ( not on the hour )
fractional_hours  = mod( newMet.Var4 / 100 , 10 );
top_of_hour = mod( fractional_hours , 1 );
not_hour_idx = find( top_of_hour > 0 );
newMet( not_hour_idx, : ) = [];

% Two extraneous columns exist in the new data (battV maybe?) that aren't
% in our sev table
newMet( : ,27:28 ) = [];
newMet.Properties.VariableNames = oldMet.Properties.VariableNames;

% Concatenate tables and sort 
 combined_t = vertcat(oldMet, newMet );

% Remove duplicate rows
combined_t = unique(combined_t,'rows');

% write new table after backing up old one
if exist( file_list{1} )
    bak_fname = regexprep( file_list{1}, '\.txt', '_bak.txt' );
    fprintf( 'backing up %s\n',file_list{1} );
    [copy_success, msg, msgid] = copyfile( file_list{1}, ...
        bak_fname );
end

max_year = max(combined_t.Year);
new_fname = sprintf('sev1_meteorology_2011-%d.txt',max_year);
fprintf( 'writing %s\n',new_fname )
writetable( combined_t , fullfile( path ,new_fname) )

success = 1;
    
