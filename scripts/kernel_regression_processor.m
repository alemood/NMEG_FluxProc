classdef kernel_regression_processor

properties
    sitecode;
    date_start;
    date_end;
    data_aflx_daily;    
end

methods

    % --------------------------------------------------
    function obj = kernel_regression_processor( sitecode, varargin )
        % Class for processing daily flux files into surfaces using kernel
        % regression
        %
        % The class constructor for card_data_processor (CDP) creates a new
        % CDP and initializes fields.  The main top-level method for the class
        % is update_fluxall.  Typical use of CDP class, then, would look
        % something like:
        %
        %     cdp = card_data_processor( UNM_sites.WHICH_SITE, options );
        %     cdp.update_fluxall();
        %
        % INPUTS:
        %    sitecode: UNM_sites object; the site to process
        % OPTIONAL PARAMETER-VALUE PAIRS:
        %    'date_start': matlab serial datenumber; date to begin processing.
        %        If unspecified default is 00:00:00 on 1 Jan of current year
        %        (that is, the year specified by now()).
        %    'date_end': Matlab serial datenumber; date to end processing.  If
        %        unspecified the default is the current system time (as
        %        provided by now()).
        %   
        %
        % SEE ALSO
        %    sonic_rotation, UNM_sites, table, now, datenum
        %
        % author: Timothy W. Hilton, UNM, 2012, extensively modified by
        %         Gregory Maurer, UNM, 2014-2015

        % -----
        % parse and typecheck arguments

        p = inputParser;
        p.addRequired( 'sitecode', @( x ) isa( x, 'UNM_sites' ) );
        p.addParameter( 'date_start', ...
            [], ...
            @isnumeric );
        p.addParameter( 'date_end', ...
            [], ...
            @isnumeric );
        p.addParameter( 'data_aflx_daily', ...
            table([]), ...
            @( x ) isa( x, 'table' ) );
        args = p.parse( sitecode, varargin{ : } );

        % -----
        % assign arguments to class fields

        obj.sitecode = p.Results.sitecode;
        obj.date_start = p.Results.date_start;
        obj.date_end = p.Results.date_end;
        obj.data_aflx_daily = p.Results.data_aflx_daily;


        % if start date not specified, default to 1 Jan of current year
        [ year, ~, ~, ~, ~, ~ ] = datevec( now() );
        if isempty( p.Results.date_start )
            obj.date_start = datenum( year, 1, 1, 0, 0, 0 );
        end

        % if end date not specified, default to right now.  This will process
        % everything through the most recent data available.
        if isempty( p.Results.date_end )
            obj.date_end = now();
        end

        % make sure date_start is earlier than date_end
        if obj.date_start > obj.date_end
            err = MException('card_data_processor:DateError', ...
                'date_end precedes date_start');
            throw( err );
        end
        
    end %constructor
    
    % --------------------------------------------------

    
    % --------------------------------------------------
    function [obj, daily_aflx_data ] = get_daily_aflx_data( obj )       
% GET_KERNEL_REGRESSION_DATA - parse ameriflux files to grab necessary data
%   


sitecode = obj.sitecode;
date_start = obj.date_start;
date_end = obj.date_end; 

fprintf( 'parsing %s %d\n', char( UNM_sites( sitecode ) ) );
site_info = parse_yaml_config( sitecode , 'SiteVars');
aflx_site_name = site_info.ameriflux_name;
fname_flux = fullfile( 'C:' , 'Code', 'NMEG_utils',...
                'processed_data', 'daily_aflx',...
                'FLUXNET2015_b', 'NMEG',...
                [ aflx_site_name , '_daily_aflx.csv']);
fname_soil = fullfile( 'C:' , 'Code', 'NMEG_utils',...
                'processed_data', 'daily_soilmet',...
                [ aflx_site_name , '_daily_soilmet.csv']);
                

if not( exist( fname_flux ) ) | not( exist( fname_soil ) )
    % if the input data are not present, exit now
    data = [];
else
    
    aflx_data = parse_aflx_daily_file( fname_flux );
    aflx_soil = parse_aflx_daily_file( fname_soil );
    
    % fill in missing PAR from global radiation (Rg)
    % Reading in filled data now. Ignore
    
    % idx = isnan( aflx_data.PAR );
    % aflx_data.PAR( idx ) = ( aflx_data.Rg( idx ) .* 2.1032 ) - 8.2985;

    %--------------
    % Line up timestamps from soil and flux data
    if ( length( aflx_data.TIMESTAMP ) ~= length( aflx_soil.TIMESTAMP ) )
        
       % aflx_soil.TIMESTAMP = ...
        %    datenum( aflx_soil.YEAR, 1, 0 ) + aflx_soil.DTIME;
        t_min = ...
            min( [ aflx_data.TIMESTAMP; aflx_soil.TIMESTAMP ] );
        t_max = ...
            max( [ aflx_data.TIMESTAMP; aflx_soil.TIMESTAMP ] );
%         two_minutes = 2 / ( 24 * 60 );  % two mins in units of days
%         [ aflx_data, aflx_soil ] = ...
%             merge_tables_by_datenum( aflx_data, aflx_soil, ...
%             'TIMESTAMP', 'TIMESTAMP', ...
%             two_minutes, ...
%             t_min, t_max );
        del_t = 1;
        aflx_data = table_fill_timestamps( aflx_data, ...
                                   'TIMESTAMP', ...
                                   'delta_t', del_t,...
                                   't_min', t_min, ...
                                   't_max', t_max );

        aflx_soil = table_fill_timestamps( aflx_soil, ...
                                   'TIMESTAMP', ...
                                   'delta_t', del_t,...
                                   't_min', t_min, ...
                                   't_max', t_max );
    end
    
    if ~isempty(date_start)
        discard_idx = ( ( aflx_data.TIMESTAMP < date_start ) | ...
            ( aflx_data.TIMESTAMP  > date_end ) );
        aflx_data( discard_idx, : ) = [];
        aflx_soil( discard_idx, : ) = [];
    end

    end

   
end 
end % methods  
end % classdef