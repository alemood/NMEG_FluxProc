classdef UNM_Ameriflux_daily_aggregator
% class that aggregates UNM gap-filled Ameriflux data to daily values.
%
% Applies mean, sum, and integrated sum where appropriate.
%
% variables aggregated by mean: USTAR, WS, PA, CO2, VPD_F, H2O, 'TA_F',
%                               RH_F
% variables aggregated by min: TA_F, VPD_F
% variables aggregated by max: TA_F, VPD_F
% variables aggregated by sum: P_F
% variables aggregated by integrated sum (radiation): RNET, PAR, SW_IN_F,
%                              SW_OUT, LW_IN, LW_OUT, LE_F, H_F 
% variables aggregated by integrated sum (C fluxes): FC_F, GPP, RECO
%
% USAGE:
%     agg = UNM_Ameriflux_daily_aggregator( sitecode )
%     agg = UNM_Ameriflux_daily_aggregator( sitecode, years )
%     agg = UNM_Ameriflux_daily_aggregator( sitecode, ..., 'binary_data' )
%
% INPUTS:
%     sitecode: UNM_sites object
%     years: optional; years to include.  Defaults to 2007-present
%     binary_data: optional, logical: if true, use binary data instead of
%          parsing ameriflux files
%
% OUTPUTS:
%     agg: UNM_Ameriflux_daily_aggregator object
%
% FIELDS:
%     sitecode
%     years
%     aflx_data: dataset array containing the aggregated data
%
% METHODS:
%    write_daily_file: write daily file to file.
%       USAGE
%          write_daily_file( 'use_Ameriflux_code', val )
%          write_daily_file( ..., 'outdir', dir )
%       INPUTS
%          use_Ameriflux_code: optional, logical; if true, uses the Ameriflux
%              site code in the file name (e.g. US-abc).  If false, uses the
%              internal UNM site abbreviation (e.g. GLand, SLand, etc.).
%              Default is true.
%          outdir: optional, char; path to directory in which to write output
%              files.  Default is $FLUXROOT/Ameriflux_files.
%
% author: Timothy W. Hilton, UNM, December 2012
    
    properties
        
        sitecode;
        years;
        aflx_data;
        soil_data;
        daily_data;
        monthly_data;
        
    end
    
    methods
        
        % --------------------------------------------------
        
        function obj = UNM_Ameriflux_daily_aggregator( sitecode, varargin );
            
            % -----
            % parse user arguments & typecheck
            args = inputParser;
            args.addRequired( 'sitecode', ...
                @(x) ( isnumeric(x) | isa( x, 'UNM_sites' ) ) );
            args.addOptional( 'years', NaN, @isnumeric );
            args.addOptional( 'soil',false,@islogical );
            args.parse( sitecode, varargin{ : } );
            % make sure sitecode is a UNM_sites object
            obj.sitecode = UNM_sites( args.Results.sitecode );
            obj.years = args.Results.years;
            
            soil = args.Results.soil;
            
            % if years not specified, collect all site-years
            if all( isnan( obj.years ) )
                [ this_year, ~, ~, ~, ~, ~ ] = datevec( now() );
                obj.years = 2007:this_year;
            end
            
            if ~soil
            obj.aflx_data = ...
                assemble_multiyear_ameriflux( args.Results.sitecode, ...
                obj.years, ...
                'suffix', 'gapfilled' );
            elseif soil
            obj.soil_data = ...
                assemble_multiyear_ameriflux(args.Results.sitecode,...
                obj.years,...
                'suffix','soil')
            end
            
            % no data from the future :)
            future_idx = obj.aflx_data.timestamp > now();
            
            obj.aflx_data( future_idx, : ) = [];
            
            obj = aggregate_daily( obj );
            obj = aggregate_monthly( obj );
            plot_growing_season_GPP(obj);
        end
        
        % --------------------------------------------------
        function obj = aggregate_daily_soil( obj )
        % If there are temp corrected probes, throw everything else out    
           uncor_idx = find( cellfun( @isempty, ...
               regexp( obj.soil_data.Properties.VariableNames, '_tcor|NIGHT|YEAR|DOY|timestamp|HRMIN|DTIME' )));
            if ~isempty( uncor_idx )
                obj.soil_data(:,uncor_idx) = [];
            end                
            % get shallow columns for averaging         
            [vars_shallow, ~] = regexp_header_vars( t, ...
                'SWC_\w*[OJPG][1-9]_[1-5][^1-9]' );
            
            % get mid depth columns (6-22 cm)
            [vars_mid, ~] = regexp_header_vars( t, ...
                'SWC_\w*[OJPG][1-9]_([6-9]|1[0-9]|2[0-2])' )
            
            % get deep columns (23 + cm)
            [vars_deep, ~] = regexp_header_vars( t,...
                'SWC_\w*[OJPG][1-9]_(2[3-9]|3[0-9]|4[0-9]|5[0-9]|6[0-9])' )
            
            vars_mean = { 'USTAR', 'WS', 'PA', 'CO2', 'VPD_F', 'H2O',...
                'TA_F', 'RH_F' };
            
            t_daynight = double( [ obj.soil_data.YEAR, obj.soil_data.NIGHT ] );
            
            
            t_30min = double( [ obj.soil_data.YEAR, obj.soil_data.DOY ] );
            units_time = { '-', '-' };
            
            % Aggregate the data using the "consolidator" function from the
            % MATLAB file exchange (John D'Errico)
            [ t, data_mean ]  = ...
                consolidator( t_30min, obj.soil_data{ :, vars_mean }, ...
                @nanmean );
        end
        
        % --------------------------------------------------
        function obj = aggregate_daily( obj )
            % AGGREGATE_DAILY 
            
            % carbon fluxes: integrate umol m-2 s-1 to gC m-2
            vars_Cfluxes = { 'FC_F', 'GPP', 'RECO' };
            units_Cfluxes = repmat( { 'gC m-2 d' }, 1, numel( vars_Cfluxes ) );
            % variables to be aggregated by daily mean
            vars_mean = { 'USTAR', 'WS', 'PA', 'CO2', 'VPD_F', 'H2O',...
                'TA_F', 'RH_F' };
            units_mean = { 'm s-1', 'm s-1', 'Pa', 'ppm', 'kPa',...
                'mmol mol-1', 'deg C', '%' };
            % variables to be aggregated by daily min / max
            vars_min = { 'TA_F', 'VPD_F' };
            vars_max = { 'TA_F', 'VPD_F' };
            % Have to make new varnames for these
            varnames_min = { 'TA_F_min', 'VPD_F_min' };
            varnames_max = { 'TA_F_max', 'VPD_F_max' };
            units_minmax = { 'deg C', 'kPa' };
            % variables to be aggregated by daily sum
            vars_sum = { 'P_F' };
            units_sum = { 'mm' };
            % radiation variables: aggregate by W m-2 to J m-2
            % FIXME - missing PAR_out (need to add to qc files)

            vars_rad = { 'NETRAD_F', 'PPFD_IN', 'SW_IN_F', 'SW_OUT', ...
                'LW_IN_F', 'LW_OUT', 'LE_F', 'H_F' };
            units_rad = repmat( { 'J m-2' }, 1, numel( vars_rad ) );
            
            t_30min = double( [ obj.aflx_data.YEAR, obj.aflx_data.DOY ] );
            units_time = { '-', '-' };
            
            % Aggregate the data using the "consolidator" function from the
            % MATLAB file exchange (John D'Errico)
            [ t, data_mean ]  = ...
                consolidator( t_30min, obj.aflx_data{ :, vars_mean }, ...
                @nanmean );
            
            [ t, data_sum ] = ...
                consolidator( t_30min, obj.aflx_data{ :, vars_sum }, ...
                @nansum );
            
            [ t, data_min ] = ...
                consolidator( t_30min, obj.aflx_data{ :, vars_min }, ...
                @nanmin );
            
            [ t, data_max ] = ...
                consolidator( t_30min, obj.aflx_data{ :, vars_max }, ...
                @nanmax );
            
            
            integrate_Cfluxes = @( x ) sum( umolPerSecPerM2_2_gcPerMSq( x ) );
            [ t, data_fluxes ] = ...
                consolidator( t_30min, obj.aflx_data{ :, vars_Cfluxes }, ...
                integrate_Cfluxes );
            
            secs_per_30mins = 60 * 30;
            integrate_radiation = @( x ) sum( secs_per_30mins .* x );
            [ t, data_rad ] = ...
                consolidator( t_30min, obj.aflx_data{ :, vars_rad }, ...
                integrate_radiation );
            
            % build a dataset from the aggregated data
            vars = horzcat( { 'year', 'doy' }, ...
                vars_sum, vars_mean, varnames_min, varnames_max, ...
                vars_Cfluxes, vars_rad );
            obj.daily_data = ...
                array2table( [t, data_sum, data_mean, data_min, data_max, ...
                data_fluxes, data_rad], 'VariableNames', vars );
            obj.daily_data.Properties.VariableUnits = horzcat( ...
                units_time, units_sum, ...
                units_mean, units_minmax, units_minmax, ...
                units_Cfluxes, units_rad );
            
        end
        
        % --------------------------------------------------
        function obj = aggregate_monthly( obj )
            % AGGREGATE_MONTHLY
            
            % Add a month column 
            [~,obj.daily_data.month,~] = ...
                datevec(datenum(obj.daily_data.year,1,0)+obj.daily_data.doy);
            
            % carbon fluxes: integrate umol m-2 s-1 to gC m-2
            vars_Cfluxes = { 'FC_F', 'GPP', 'RECO' };
            units_Cfluxes = repmat( { 'gC m-2 d' }, 1, numel( vars_Cfluxes ) );
            % variables to be aggregated by daily mean
            vars_mean = { 'USTAR', 'WS', 'PA', 'CO2', 'VPD_F', 'H2O',...
                'TA_F', 'RH_F' };
            units_mean = { 'm s-1', 'm s-1', 'Pa', 'ppm', 'kPa',...
                'mmol mol-1', 'deg C', '%' };
            % variables to be aggregated by daily min / max
            vars_min = { 'TA_F', 'VPD_F' };
            vars_max = { 'TA_F', 'VPD_F' };
            % Have to make new varnames for these
            varnames_min = { 'TA_F_min', 'VPD_F_min' };
            varnames_max = { 'TA_F_max', 'VPD_F_max' };
            units_minmax = { 'deg C', 'kPa' };
            % variables to be aggregated by daily sum
            vars_sum = { 'P_F' };
            units_sum = { 'mm' };
            % radiation variables: aggregate by W m-2 to J m-2
            % FIXME - missing PAR_out (need to add to qc files)

            vars_rad = { 'NETRAD_F', 'PPFD_IN', 'SW_IN_F', 'SW_OUT', ...
                'LW_IN_F', 'LW_OUT', 'LE_F', 'H_F' };
            units_rad = repmat( { 'W m-2' }, 1, numel( vars_rad ) );
            
            t_month = double( [ obj.daily_data.year, obj.daily_data.month ] );
            units_time = { '-', '-' };
            
            % Aggregate the data using the "consolidator" function from the
            % MATLAB file exchange (John D'Errico)
            [ t, data_mean ]  = ...
                consolidator( t_month, obj.daily_data{ :, vars_mean }, ...
                @nanmean );
            
            [ t, data_sum ] = ...
                consolidator( t_month, obj.daily_data{ :, vars_sum }, ...
                @nansum );
            
            [ t, data_min ] = ...
                consolidator( t_month, obj.daily_data{ :, vars_min }, ...
                @nanmin );
            
            [ t, data_max ] = ...
                consolidator( t_month, obj.daily_data{ :, vars_max }, ...
                @nanmax );
            
            
            % integrate_Cfluxes = @( x ) sum( umolPerSecPerM2_2_gcPerMSq( x ) );
            [ t, data_fluxes ] = ...
                consolidator( t_month, obj.daily_data{ :, vars_Cfluxes }, ...
                @nansum );
            
%             secs_per_30mins = 60 * 30;
%             integrate_radiation = @( x ) sum( secs_per_30mins .* x );
            [ t, data_rad ] = ...
                consolidator( t_month, obj.daily_data{ :, vars_rad }, ...
                @nansum );
            
            % Add a season column
            % 1 = dormant
            % 2 = early growing (pre-monsoon)
            % 3 = late growing (monsoon)
            % Initialize everything with dormant season
            season = repmat(1,length(t),1);
            earlyGrow = find( t(:,2) >= 4 & t(:,2) <=6);
            lateGrow =  find(t(:,2) >= 7 & t(:,2) <=8); 
            season(earlyGrow) = 2;
            season(lateGrow) = 3;
            
           
            
            % build a dataset from the aggregated data
            vars = horzcat( { 'year', 'month' ,'season'}, ...
                vars_sum, vars_mean, varnames_min, varnames_max, ...
                vars_Cfluxes, vars_rad );
            obj.monthly_data = ...
                array2table( [t, season, data_sum, data_mean, data_min, data_max, ...
                data_fluxes, data_rad], 'VariableNames', vars );
            obj.monthly_data.Properties.VariableUnits = horzcat( ...
                units_time,'-', units_sum, ...
                units_mean, units_minmax, units_minmax, ...
                units_Cfluxes, units_rad );
            
             if obj.sitecode == UNM_sites.MCon
                idx = find(t(:,1) == 2013);
                obj.monthly_data{idx,{'GPP' 'RECO' 'FC_F'}} = NaN;
             end
        end
        
  
        % --------------------------------------------------
        
        function write_daily_file( obj, varargin )
            % WRITE_DAILY_FILE -
            
            % -----
            args = inputParser;
            args.addRequired( 'obj', ...
                @(x) isa( x, 'UNM_Ameriflux_daily_aggregator' ) );
            args.addParameter( 'outdir', '', @ischar );
            args.addParameter( 'use_Ameriflux_code', true, @islogical );
            args.parse( obj, varargin{ : } );
            obj = args.Results.obj;
            % -----
            
            % determine where to put the output file
            if isempty( args.Results.outdir )
                outdir = fullfile( getenv( 'FLUXROOT' ), 'Ameriflux_files' );
            elseif strcmp( args.Results.outdir, 'prompt' )
                outdir = uigetdir( getenv( 'HOME' ), ...
                    'Choose directory for aggregated daily data' );
            else
                outdir = args.Results.outdir;
            end
            if exist( outdir ) ~= 7
                error( sprintf( 'directory %s does not exist; cannot write output', ...
                    outdir ) );
            end
            
            if args.Results.use_Ameriflux_code
                site_table = parse_UNM_site_table();
                site_abbrev = char( site_table.Ameriflux( obj.sitecode ) );
            else
                site_abbrev = char( obj.sitecode );
            end
            
            fname = fullfile( outdir, ...
                sprintf( '%s_%d_%d_daily.txt', ...
                site_abbrev, ...
                obj.years( 1 ), ...
                obj.years( end ) ) );
            
            fprintf( 'writing %s\n', fname );
            write_table_std( fname,  obj.daily_data, ...
                'replace_NaNs', -9999, ...
                'write_units', true );
        end
        
        % --------------------------------------------------
        function plot_growing_season_GPP( obj )
            
            h_fig = figure('Position',[149 449 1636 408]);
            subplot(1,3,[1,2])
            % TIMESERIES
            ts=datenum(obj.monthly_data.year, obj.monthly_data.month,15);
            idx = find(obj.monthly_data.season ~= 1);
            plot(ts(idx),obj.monthly_data.GPP(idx),':k');
            hold on
            idx2 = find(obj.monthly_data.season==2);
            plot(ts(idx2),...
                obj.monthly_data.GPP(idx2),'ok',...
                'MarkerFaceColor',[1  0.2 0.7]);
            hold on
            idx3 = find(obj.monthly_data.season==3);
            plot(ts(idx3),...
                obj.monthly_data.GPP(idx3),'ok',...
                'MarkerFaceColor',[0.7  0.7 0.7]);
            grid on;
            datetick('x');
            dynamicDateTicks
            
            t_season = double( [ obj.monthly_data.year, obj.monthly_data.season ] );
          
            
            % Aggregate the data using the "consolidator" function from the
            % MATLAB file exchange (John D'Errico)
            [ t, GPP_sum ]  = ...
                consolidator( t_season, obj.monthly_data.GPP, ...
                @nansum );
            
            subplot(1,3,3)
            % Scatter plot
            idx2 = find(t(:,2) == 2);
            idx3 = find(t(:,2) == 3);
            GPParray= unique(t(:,1));
            GPParray = horzcat( GPParray, GPP_sum(idx2), GPP_sum(idx3));
            
            gscatter(GPParray(:,2),GPParray(:,3),GPParray(:,1))
            xlabel('Cumulative Early Season GPP [gCm^{-2}]')
            ylabel('Cumulative Late Season GPP [gCm^{-2}]')
            
            suptitle(char(obj.sitecode))
            saveas(gcf,fullfile('C:\Research_Flux_Towers\Plots\early_late_GPP',...
                sprintf('%s_earlylateGPP.png',char(obj.sitecode))));
          
        end
            
    end %methods
end %classdef
