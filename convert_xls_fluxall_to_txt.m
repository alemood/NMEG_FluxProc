% script to convert fluxall files to text, and save session transcript to a file

[ y, mon, d, h, m, s ] = datevec( now() );
transcript_fname = ...
    fullfile( '/tmp/', ...
              sprintf( '%d-%02d-%02d_%02d%02d_matlab_transcript.txt', ...
                       y, mon, d, h, m ) );
diary( transcript_fname );

for this_site = UNM_sites( [ 1, 2, 3, 4, 6, 5, 10, 11 ] )
    fprintf( 'made /tmp/%s\n', char( this_site ) );
    mkdir( '/tmp', char( this_site ) );
    for this_year = 2007:2011
        fprintf( 'processing %s %d\n', char( this_site ), this_year );
        try 
            saved_xls_fluxall_fname = ...
                fullfile( getenv( 'FLUXROOT' ), ...
                                  'FluxallConvert', ...
                                  sprintf( '%s_%d_FA_Convert.mat', ...
                                           char( this_site ), this_year ) );
            load( saved_xls_fluxall_fname );
            FA = standardize_fluxall_variables( sitecode, ...
                                                year_arg, ...
                                                headertext, ...
                                                timestamp, ...
                                                data );
            cdp = card_data_processor( sitecode, ...
                                       'date_start', datenum( year_arg, 1, 1 ),...
                                       'date_end', datenum( year_arg, 12, 31, ...
                                                            23, 59, 59 ) );
            cdp.write_fluxall( FA );
        catch err
            % if an error occurs, write the message and continue with next year
            disp( getReport( err ) );
        end
    end
end

diary off