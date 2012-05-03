function ds  = UNM_parse_fluxall_txt_file2( sitecode, year, synch_tstamps )
% UNM_PARSE_FLUXALL_XLS_FILE - parse fluxall data and timestamps from excel
% file to matlab matrices
%   
% ds  = UNM_parse_fluxall_xls_file( sitecode, year )
%
% Timothy W. Hilton, UNM, January 2012
    
    [ lastcolumn, filelength_n ] = get_FluxAll_File_Properties( sitecode, year );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up file name and file path
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fluxrc = UNM_flux_process_config();
    site = get_site_name( sitecode );
    
    fname = sprintf( '%s_FLUX_all_%d.txt', site, year );
    full_fname = fullfile( get_site_directory( sitecode ), fname );
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Open file and parse out dates and times
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf( 'reading %s...', fname );
    
    fid = fopen( full_fname, 'r' );
    headers = fgetl( fid );
    discard = fgetl( fid );
    discard = fgetl( fid );

    % -----
    % parse the headers
    % -----

    % split the headers on tab characters
    headers = regexp( headers, '\t', 'split' );
    % remove or replace characters that are illegal in matlab variable names
    headers_orig = headers;
    headers = regexprep( headers, '[\(\),/;]', '_' );
    headers = regexprep( headers, '[\^" -]', '' );
    headers = regexprep( headers, '_+$', '' ); % remove trailing _
    headers = regexprep( headers, '^_+', '' ); % remove leading _
    % replace decimals in headers with 'p'
    headers = regexprep( headers, '([0-9])\.([0-9])', '$1p$2' );

    tstamp_cols = ~cellfun( @(x) length( x ) == 0, ...
                            regexpi( headers, 'timestamp.*' ) );

    % -----
    % read the numeric data
    % -----
    
    % build format string with %s for timestamp columns, %f elsewhere
    fmt = repmat( { '%f' }, 1, numel( headers ) );
    fmt( tstamp_cols ) = { '%s' };
    fmt = cell2mat( fmt );

    % read the data
    data = textscan( fid, ...
                     fmt, ...
                     'Delimiter', '\t' );
    tstamp_cols = find( tstamp_cols );

    % translate data timestamps to matlab datenums
    for i = 1:numel( tstamp_cols )
        this_tstamps = data{ tstamp_cols( i ) };
        idx = ~cellfun( @isempty, this_tstamps );
        this_stamps = cellfun( @(x) nan_datenum( x, 'mm/dd/yyyy HH:MM' ), ...
                               this_tstamps, ...
                               'UniformOutput', false );
        data{ tstamp_cols( i ) } = this_tstamps;
    end
    keyboard()
    % combine data into double array
    data = cell2mat( data );

    % -----
    % optionally, synchronize timestamps of 10 hz, TOA5 sections of file
    % -----

    if synch_tstamps
        ten_hz = data( :, 1:tstamp_cols( 3 ) );
        TOA5 = data( :, tstamp_cols( 3 ):end );
        thirty_mins = 1 / 48;  % 30 minutes expressed un units of days
        ten_hz = dataset_fill_timestamps( ten_hz, ...
                                          headers( 1 ), ...
                                          thirty_mins, ...
                                          datenum( year, 1, 1, 0, 0, 0 ), ...
                                          datenum( year, 12, 31, 23, 30, 0 ) );
        TOA5 = dataset_fill_timestamps( TOA5, ...
                                        headers( 1 ), ...
                                        thirty_mins, ...
                                        datenum( year, 1, 1, 0, 0, 0 ), ...
                                        datenum( year, 12, 31, 23, 30, 0 ) );
        data = horzcat( ten_hz, TOA5 );
    end

    % -----
    %% replace -9999s with NaN using floating point test with tolerance of 0.0001
    % -----
    data = replace_badvals( data, [ -9999 ], 0.0001 );
    
    % -----
    % create matlab dataset from data
    % -----

    empty_columns = find( cellfun( @length, headers ) == 0 );
    headers( empty_columns ) = [];
    data( :, empty_columns ) = [];
    ds = dataset( { data, headers{ : } } );

    % ds.timestamp = datenum( ds.year, ds.month, ds.day, ...
    %                         ds.hour, ds.min, ds.second );

    fprintf( ' file read\n' );

    