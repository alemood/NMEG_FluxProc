function [ success, toa5_fname ] = ...
    manipulate_wireless_toa5_file( this_site, remote_toa5_path, varargin);

args = inputParser;
args.addRequired( 'this_site', @(x) ( isintval(x) | isa( x, 'UNM_sites' )));
args.addRequired( 'remote_toa5_path', @isstr);
args.addParameter( 'append', false, @islogical);


% parse optional inputs
args.parse( this_site, remote_toa5_path, varargin{:} );

% place user arguments into variables
this_site = args.Results.this_site;
remote_toa5_path = args.Results.remote_toa5_path;
append = args.Results.append;


success = 0;

% Get TOA5 storage directory
toa5_dir = fullfile( get_site_directory( this_site ), 'toa5' ) ;

% List files in directory
re = '^TOA5_.*_(\d\d\d\d)_(\d\d)_(\d\d)_(\d\d)(\d\d).*\.(dat|DAT)$';
toa5_fnames = list_files( toa5_dir , re);

% make serial datenums for dates
dns = tstamps_from_filenames(toa5_fnames);

% find latest toa5 file
[ ~ , idx ]  = min( now - dns );

% Extract latest filename from list
toa5_fname = toa5_fnames{ idx };

% read wireless data into table

% Make a new TOA5 filename starting from one half hour past the last time
% stamp of the most recent TOA5 file.
if ~append
    old_t = toa5_2_table(toa5_fname);
    new_t = toa5_2_table(remote_toa5_path);
    [~,~,new_ts_id] = intersect(old_t.timestamp,new_t.timestamp);
    % If there is no new data, return to process_card_main
    if new_ts_id(end) == height(new_t)
        fprintf('---------\n')
        fprintf('The wireless download contains no new data\n')
        fprintf('Last timestamp on wireless is %s\n',...
            datestr(new_t.timestamp(end),'yy-mmm-dd HH:MM'))
        fprintf('Last timestamp from card is %s\n',...
            datestr(old_t.timestamp(end),'yy-mmm-dd HH:MM'))
        fprintf('---------\n')
        success = 0;
        return
    end
    toa5_2_write= strrep(toa5_fname,'\d\d\d\d_(\d\d)_(\d\d)(\d\d)',...
        datestr(new_t.timestamp(1),'yyyy_mm_dd_HHMM'));
    
elseif append
    % Append wireless download to latest TOA5 file
    new_t = combine_and_fill_datalogger_files( ...
        this_site, 'TOA5','file_names', {wireless_toa5, toa5_fname},...
        'resolve_headers', true ,...
        'datalogger_name', 'flux' );
    toa5_2_write= toa5_fname;
end
% find the intersection bewtween the combined table and wireless table
%[val, wire_idx , comb_idx] = intersect(wireless_t.timestamp,new_t.timestamp);
% The set difference between the wireless table and
%[new_obs , wire_idx] = setdiff( wireless_t.timestamp, local_t.timestamp );

% Remove timestamp column and reformat to yyyy-mm-dd hh:MM:SS
dn_str = datestr(new_t.timestamp,'"yyyy-mm-dd HH:MM:SS"');
new_t.TIMESTAMP = dn_str;
% Place timestamp field at beginning of table
new_t = new_t(:,[end 1:end-1]);
% Remove RECORD and MATLAB serial timestamp
new_t.timestamp = [];
new_t.RECORD = [];

new_t_cell = table2cell( new_t );
% Get header for rewriting file. Compare the old and new TOA5 in case there
% was a header change or added variables Defer to newest file. Maybe
% change this to the table with more variables
[ headerlines ] = get_toa5_headers( remote_toa5_path );

% open the local TOA5 file to write
% Headers
fid = fopen(toa5_2_write,'w+');
for i = 1:4
    n_fields = numel( headerlines{ i } );
    hfmt = [repmat( '%s,', 1, n_fields  - 1 ),'%s'];
    C = [headerlines{i}];
    fprintf( fid, [hfmt,'\n'], C{ 1 , : } );
end
% Data
dfmt = [repmat( '%s,', 1 , width(new_t) - 1 ), '%s' ];
for i = 1:height(new_t);
    C = cellfun(@(x) num2str(x,8),new_t_cell(i,:),'Uniformoutput',false);
    fprintf( fid, [dfmt,'\n'], C{1,:});
end

fclose(fid);
success = 1;

end % main

function  [ headerlines ] = get_toa5_headers( fname )

n_header_lines = 4;
first_data_line = n_header_lines + 1;
delim = detect_delimiter( fname );

% read file one line at a time into a cell array of strings
fid = fopen(fname, 'rt');
file_lines = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
file_lines = file_lines{1,1};

re = sprintf( '(?:^|%s)(\"(?:[^\"]+|\"\")*\"|[^%s]*)', delim, delim );
header =  regexp( file_lines{ 1 }, re, 'tokens' );
header = [ header{ : } ];
var_names = regexp( file_lines{ 2 }, re, 'tokens' );
var_names = [ var_names{ : } ];  % 'unnest' the cell array
var_units = regexp( file_lines{ 3 }, re, 'tokens' );
var_units = [ var_units{ : } ];  % 'unnest' the cell array
var_type  = regexp( file_lines{ 4 }, re , 'tokens' );
var_type  = [ var_type{ : } ];

% Remove RECORD field from wireless data
record_field_boolean=cellfun(@(x) strcmp(x,'"RECORD"'),var_names);
record_field_idx = find( record_field_boolean == 1 );
var_names( record_field_idx ) = [];
var_units( record_field_idx ) = [];
var_type( record_field_idx ) = [];

headerlines = { header , var_names, var_units, var_type };

end



