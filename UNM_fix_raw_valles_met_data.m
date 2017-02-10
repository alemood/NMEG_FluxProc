function t_filled = UNM_fix_raw_valles_met_data( station_name, year_arg )
%  This is a non-functioning script right now and should be cleaned up to
%  be run without user input. However, it was created to quickly fill data
%  gaps in raw WRCC DRI met stations in the Valles that were interfering
%  with filling of our data gaps for 2016.
path = fullfile(getenv('FLUXROOT'), 'Ancillary_met_data');
fname_re = [ sprintf( 'VC_%s', station_name ), '_dri_.*\.dat'];
file_list = list_files( path, fname_re );

i=3;
t = openVC( file_list{i} );
t2 = table_fill_timestamps( t, 'timestamp','delta_t',1/24);
t2.YYMMDDhhmm = datestr(t2.timestamp,'yymmddHHMM');
myfname = strrep(file_list{1},'.dat','_bak.dat')
writetable(t2(:,2:end),myfname,'Delimiter',',');

  function tbl = openVC( fname )
        % Set delimiter and open file
        delim = ',';
        fid = fopen( fname, 'r' );
        % Read header and units
        var_units = fgetl( fid );
        var_units = regexp( var_units, delim, 'split' );
        var_units = cellfun( @char, var_units, 'UniformOutput',  false );
        var_names = fgetl( fid );
        var_names = regexp( var_names, delim, 'split' );
        var_names = cellfun( @char, var_names, 'UniformOutput',  false );
        % Read data to array and replace bad data values
        n_vars = numel( var_names );
        fmt = repmat( '%f', 1, n_vars );
        data = cell2mat( textscan( fid, fmt, 'delimiter', delim ) );
        data =  replace_badvals( data, [ -9999 ], 1e-10 );
        % Close file
        fclose( fid );
        % Create table
        tbl = array2table( data, 'VariableNames', var_names );
        tbl.Properties.VariableUnits =  var_units;
        % Create at timestamp
        dstring = num2str( tbl.YYMMDDhhmm, '%010u' );
        tbl.timestamp = datenum( dstring, 'YYmmDDHHMM' );