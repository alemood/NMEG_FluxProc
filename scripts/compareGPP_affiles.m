function compareGPP_affiles()

function t = loadaf( fname )
    delim = detect_delimiter( fname );
    
    fid = fopen( fname, 'r' );
    
    var_names = fgetl( fid );
    var_names = regexp( var_names, delim, 'split' );
    var_names = cellfun( @char, var_names, 'UniformOutput',  false );
    var_names = cellfun( @genvarname, var_names, 'UniformOutput',  false );
    var_units = fgetl( fid );
    var_units = regexp( var_units, delim, 'split' );
    var_units = cellfun( @char, var_units, 'UniformOutput',  false );
    
    n_vars = numel( var_names );
    fmt = repmat( '%f', 1, n_vars );
    data = cell2mat( textscan( fid, fmt, 'delimiter', delim ) );
    data =  replace_badvals( data, [ -9999 ], 1e-10 );
    
    fclose( fid );
    
    t = array2table( data, 'VariableNames', var_names );
    t.Properties.VariableUnits = var_units;
    
    
    yr_ts = datenum( t.year , 1, 0 );
    ts = yr_ts + t.doy ;
    t.timestamp = ts;
end


old_path = fullfile( getenv( 'FLUXROOT' ), 'Ameriflux_files', 'ftp_ameriflux', 'Daily' );
new_path = fullfile( getenv( 'FLUXROOT' ), 'Ameriflux_files' );

old_pjg = loadaf([ old_path, '\', 'US-Mpg_2007_2013_daily.txt']);
old_pjg_marcy = loadaf([ old_path, '\', 'PJ_girdle_2007_2013_daily.txt']);
old_pj = loadaf([ old_path, '\', 'US-Mpj_2007_2013_daily.txt']);
new_pjg = loadaf([ new_path, '\', 'US-Mpg_2007_2015_daily.txt']);
new_pj = loadaf([ new_path, '\', 'US-Mpj_2007_2015_daily.txt']);




figure();
plot(old_pjg.timestamp, old_pjg.GPP, '-k');
hold on;
plot(old_pj.timestamp, old_pj.GPP, '-b');
plot(new_pjg.timestamp, new_pjg.GPP_GL2010_ecb, '--g');
plot(new_pj.timestamp, new_pj.GPP_GL2010_ecb, '--r');

legend( 'Girdle_old', 'Control_old', 'Girdle_new', 'Control_new' );

datetick();


junk = 99;

end