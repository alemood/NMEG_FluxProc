classdef aflxAnalyzer
    
    properties
        sitelist;
        date_start;
        date_end;
        daily_data;
        monthly_data;
        daily_data_already_parsed;
        pallette;
    end
    
    methods
        function obj = aflxAnalyzer( sitelist, varargin )
            p = inputParser;
            p.addRequired( 'sitelist', @( x ) iscell( x ) );
            p.addParameter( 'date_start', ...
                datenum(2007,1,1), ...
                @isnumeric );
            p.addParameter( 'date_end', ...
                now, ...
                @isnumeric );
            p.addParameter( 'daily_data',...
                cell(1),...
                @( x ) isa( x, 'cell' ) );
            p.addParameter( 'daily_data_already_parsed',...
                false, ...
                @islogical );
            
            args = p.parse( sitelist, varargin{ : } );
            obj.sitelist = p.Results.sitelist;
            obj.date_start = p.Results.date_start;
            obj.date_end = p.Results.date_end;
            obj.daily_data = p.Results.daily_data;
            obj.daily_data_already_parsed = p.Results.daily_data_already_parsed;
            
            [obj spIDX] = getPlotconfig( obj );
            
            % Get the daily data file from Python processing
            obj = getDailyData( obj );
            
        end
        
        % --------------------------------------------------
        
        function [obj ] = getDailyData( obj )
            
            [year_start , ~ , ~ ] = datevec(obj.date_start);
            [year_end , ~ , ~ ] = datevec(obj.date_end);
            yearlist = year_start:year_end;
            aflx_path = 'C:\Research_Flux_Towers\Ameriflux_files\FLUXNET2017\daily_aflx';
            
            % Loop through sites and get data
            for i = 1:numel(obj.sitelist)
                this_conf = UNM_sites_info( obj.sitelist{i } );
                aflx_site_name = this_conf.ameriflux;
                
                if obj.daily_data_already_parsed
                    fname_flux = fullfile( aflx_path,...
                        [ aflx_site_name , '_daily_aflx.mat']);
                    load( fname_flux)
  
                    % Add water year
                    data = calcWaterYear( obj, data );
                    % Add Drought codes
                    data =setDroughtYears( obj, data );
             
                    % Place data table into object
                    obj.daily_data{i,1} = data;
                    obj.daily_data{i,2} = char( obj.sitelist{ i } );
                else
                    fname_flux = fullfile( aflx_path,...
                        [ aflx_site_name , '_daily_aflx.csv']);
                    sitecode = obj.sitelist{i};
                    fprintf('Loading %s\n', [ aflx_site_name , '_daily_aflx.csv'])
                    data = parse_aflx_daily_file( fname_flux );
                    obj.daily_data{i} = data;
                    % Save .mat file for faster uploading later
                    save( strrep(fname_flux,'csv','mat'), 'data' );
                end
            end
        end %getDailyData
        
        % --------------------------------------------------
        
        function obj = getMonthlyData( obj )
            
            for i = 1:numel(obj.sitelist)
                this_conf = UNM_sites_info( obj.sitelist{i } );
                aflx_site_name = this_conf.ameriflux;
                
                % Add a month column
                [obj.daily_data{i,1}.year,obj.daily_data{i,1}.month,~] = ...
                    datevec(obj.daily_data{i,1}.TIMESTAMP);
                
                data = aggregate_monthly( obj,...
                    obj.daily_data{i,1} , ...
                    obj.sitelist{1});
                
                % Place data in object
                obj.monthly_data{i,1} = data;
                obj.monthly_data{i,2} = char( obj.sitelist{ i } );
                
            end
  
        end %getMonthlyData
        
        function data = setDroughtYears( obj, data )
            % Set codes for dates relative to the drought between 2011-2012
            % 1 = Predrought; 2007-2010
            % 2 = Drought; 2011-2012
            % 3 = Post Drought; 2014-on *
            % Marcy has made the decision to exclude 2013 because it was
            % unusually wet.
            % These are based on calendar year, not water year, currently
            
            
            predroughtID = find(data.year > 2006 & data.year <= 2010);
            droughtID = find(data.year == 2011 | data.year == 2012);
            postdroughtID = find(data.year >= 2014 );
            
            % Initialize column for drought codes
            data.droughtID = NaN(height(data),1);
            data.droughtID(predroughtID) = 1;
            data.droughtID(droughtID) = 2;
            data.droughtID(postdroughtID) = 3;
            
            
        end %setDroughtYears
        
        % --------------------------------------------------
        function [obj pallette spIDX] = getPlotconfig( obj )
            % Set color pallette
            pallette = [];
            elevationID = []; % For elevations. Used for sorting and subplot ID
            for i = 1:numel(obj.sitelist)
                this_conf = UNM_sites_info( obj.sitelist{i} );
                pallette(i,:) = this_conf.color;
                elevationID( i ) = this_conf.elevation;
            end
            
            % Set order for subplots based on elevation
            [ ~ , spIDX ] = sort( elevationID );
            obj.pallette = pallette(spIDX,:);
            
            % Make sure sites are ordered based on elevation
            obj.sitelist = obj.sitelist( spIDX );
        end
        
        % --------------------------------------------------
        function [obj h_fig] = plotExceedanceCurves( obj , varNames , varargin )
            p = inputParser;
            p.addRequired( 'obj', @( x ) isa( x, 'aflxAnalyzer' ) );
            p.addRequired( 'varNames', @( x ) isa( x ,'cell') );
            p.addParameter( 'savefig', false, @(x) islogical(x) );
            p.addParameter( 'donorm' , false , @(x) islogical(x));
            p.addParameter( 'figname','',@(x) ischar(x) ) ;
            p.addParameter( 'plot_start',datenum(2007,1,1),@isnumeric);
            p.addParameter( 'plot_end',now, @isnumeric );
            
            args = p.parse( obj , varNames, varargin{ : } );
            obj = p.Results.obj;
            varNames = p.Results.varNames;
            savefig = p.Results.savefig;
            donorm = p.Results.donorm;
            figname = p.Results.figname;
            plot_start = p.Results.plot_start;
            plot_end = p.Results.plot_end;
            
            for j = 1:numel(varNames)
                
                varName = varNames{j};
                
                h_fig( j ) = figure('Name',sprintf('%s-%s',varName,figname));
                
                for i = 1:numel(obj.sitelist)
                    % Get indices out of range
                    ts = obj.daily_data{i,1}{:,'TIMESTAMP'};
                    throw_idx = find( ts< plot_start | ...
                        ts > plot_end );
                    
                    % Save variable
                    Y =  obj.daily_data{i,1}{:,varName};
                    Y(throw_idx) = [];
                    if donorm; Y = normalize_vector( Y, 0 , 1 );end
                    [F X ]= ecdf(Y);
                    plot( 1- F , X ,...
                        'LineWidth',1.5,...
                        'Color', obj.pallette( i ,:),...
                        'DisplayName',obj.daily_data{i,2});
                    hold on
                end
                hold off
                % set(gca,'yscale','log');
                grid on
                %legend([all_data(:,1)],'Location','Best')
                ylabel( [ strrep(varName,'_',' ') , ' [g C m^{-2} d^{-1}]'])
                %ylim([0 6])
                grid on
                xlabel('% of time given value was exceeded')
                if savefig
                    fname = fullfile(getenv('FLUXROOT'),...
                        'Plots','aflxAnalyzer','exceedance',...
                        sprintf('%s_%s_exceedance.png',varName,figname));
                    saveas( gcf ,fname);
                end
            end
        end
        
        % --------------------------------------------------
        
        function [ h_fig] = plotCumulativeDOY( obj , varName,varargin )
            % Plot cumulative P - ET for every year for all sites.
            % Each site has all years plotted on one plot, 6 panel plot
            p = inputParser;
            p.addRequired( 'obj', @( x ) isa( x, 'aflxAnalyzer' ) );
            p.addRequired( 'varName', @( x ) isa( x ,'char') );
            p.addParameter( 'savefig', false, @(x) islogical(x) );
            p.addParameter( 'donorm' , false , @(x) islogical(x));
            p.addParameter( 'figname','',@(x) ischar(x) ) ;
            p.addParameter( 'plot_start',datenum(2007,1,1),@isnumeric);
            p.addParameter( 'plot_end',now, @isnumeric );
            
            args = p.parse( obj , varName, varargin{ : } );
            obj = p.Results.obj;
            varName = p.Results.varName;
            savefig = p.Results.savefig;
            donorm = p.Results.donorm;
            figname = p.Results.figname;
            plot_start = p.Results.plot_start;
            plot_end = p.Results.plot_end;
            
           
           h_fig = figure('Name',sprintf('%s-%s',varName,figname));
               
           for i = 1:numel(obj.sitelist)
           data = obj.daily_data{i,1};
           
           % Cumulative Annual Fluxes (resets to zero at beginning of water year)
           [uniqueWY,idxToUnique,idxFromUniqueBackToAll] = unique(data.year);
           % Accumulate Precip and ET values over water year
           cumVar = accumarray(idxFromUniqueBackToAll,data{:,varName},[],@(x) {cumsum(x,'omitnan')}); 
           droughtCode = accumarray(idxFromUniqueBackToAll,data{:,'droughtID'},[],@(x) mode(x))
           numdays=cellfun(@numel,cumVar);
           cumVar(find(numdays < 350 )) = [];
         
           if donorm
                maxVal = cellfun(@max,cumVar(droughtCode == 1)); maxVal = max(maxVal);
                minVal = cellfun(@min,cumVar(droughtCode == 1)); minVal = min(minVal);
                Y = ...
                    cellfun( @(x) (x - minVal)./(maxVal - minVal),...
                    cumVar,'UniformOutput',false);
           else
               Y = cumVar;
           end
              
                % idx = find(all_data{i,2}.hydroyear == uniqueWY(j) );
                for j = 1:numel(cumVar)
                    idx = idxFromUniqueBackToAll == j ; 
                    this_ts = data.TIMESTAMP(idx);
                    
                    subplotrc(2,3,i)
                    plot(data.wyDOY(idx),Y(idx) ,'LineWidth',2,'DisplayName',num2str(uniqueWY(i)))%'Color',colour(j,:));
                    %datetick('x','m')
                    grid on
                    hold on
                end
                hold off
                %legend('Location','Best')
                ylabel(varName)
                xlabel('Day of Water Year')
                xlim([0 366])
                title(sprintf('%s',obj.daily_data{i,2}))
                
            end
            
        end %plotCumulativeDOY
        
        % --------------------------------------------------

        function monthly_data = aggregate_monthly(  obj, data ,sitecode )
            
            % carbon fluxes: integrate umol m-2 s-1 to gC m-2
            vars_Cfluxes = { 'FC_F_g_int', 'GPP_g_int', 'RECO_g_int' };
            units_Cfluxes = repmat( { 'gC m^{-2} d^{-1}' }, 1, numel( vars_Cfluxes ) );
            % variables to be aggregated by daily mean
            vars_mean = { 'VPD_F_avg', ...
                'TA_F_avg', 'RH_F_avg' };
            units_mean = {  'kPa',...
                'deg C', '%' };
            
            % variables to be aggregated by daily min / max
            vars_min = { 'TA_F_min', 'VPD_F_min' };
            vars_max = { 'TA_F_max', 'VPD_F_max' };
            % Have to make new varnames for these
            varnames_min = { 'TA_F_min', 'VPD_F_min' };
            varnames_max = { 'TA_F_max', 'VPD_F_max' };
            units_minmax = { 'deg C', 'kPa' };
            % variables to be aggregated by daily sum
            vars_sum = { 'ET_mm_dayint' };
            units_sum = { 'mm' };
            % radiation variables: aggregate by W m-2 to J m-2
            % FIXME - missing PAR_out (need to add to qc files)
            
            vars_rad = { 'NETRAD_F_avg', 'PPFD_IN_avg', 'SW_IN_F_avg', 'LE_F_int', 'H_F_int' };
            units_rad = repmat( { 'W m-2' }, 1, numel( vars_rad ) );
            
            t_month = double( [ data.year, data.month ] );
            units_time = { '-', '-' };
            
            % Aggregate the data using the "consolidator" function from the
            % MATLAB file exchange (John D'Errico)
            [ t, data_mean ]  = ...
                consolidator( t_month, data{ :, vars_mean }, ...
                @nanmean );
            
            [ t, data_sum ] = ...
                consolidator( t_month, data{ :, vars_sum }, ...
                @nansum );
            
            [ t, data_min ] = ...
                consolidator( t_month, data{ :, vars_min }, ...
                @nanmin );
            
            [ t, data_max ] = ...
                consolidator( t_month, data{ :, vars_max }, ...
                @nanmax );
            
            
            % integrate_Cfluxes
            [ t, data_fluxes ] = ...
                consolidator( t_month, data{ :, vars_Cfluxes }, ...
                @nansum );
            
            [ t, data_rad ] = ...
                consolidator( t_month, data{ :, vars_rad }, ...
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
            monthly_data = ...
                array2table( [t, season, data_sum, data_mean, data_min, data_max, ...
                data_fluxes, data_rad], 'VariableNames', vars );
            monthly_data.Properties.VariableUnits = horzcat( ...
                units_time,'-', units_sum, ...
                units_mean, units_minmax, units_minmax, ...
                units_Cfluxes, units_rad );
            
            if sitecode == UNM_sites.MCon
                idx = find(t(:,1) == 2013);
                monthly_data{idx,{'GPP_g_int' 'RECO_g_int' 'FC_F_g_int'}} = NaN;
            end
        end %aggregate_monthly 
        
        function  data_out = calcWaterYear( obj, data)
        % The USGS 'water year' is defined as the 12-month period October 1 
        % for any given year through September 30, of the following year.
        % The water year is designated by the calendar year in which it
        % ends and which includes 9 of the 12 months. Thus, the year ending 
        % September 30, 1999 is called the "1999" water year.   
        
                ts = data.TIMESTAMP;
                [data.year, data.month , data.day,~,~,~] = ...
                    datevec(ts);
                yearvec = unique(data.year);
                wateryear = zeros(height(data),1);
                season = zeros(height(data),1);
                % Calculate water year in loop
                for j = 1:length(yearvec)
                    wy_idx = find( ts <= datenum( yearvec(j) , 9 , 30) & ...
                        ts >= datenum( yearvec(j) - 1 , 10, 1) );
                    wateryear(wy_idx) = yearvec(j)  ;
                end
                
                data.wateryear = wateryear;
                data.wyDOY =  data.TIMESTAMP - datenum(  data.wateryear-1, 10, 1 ) +1;
                
                
%                 cold_idx = find(data.wyDOY <= 182 );
%                 season(cold_idx,:) = 1; % COLD SEASON
%                 spring_idx = find(data.wyDOY > 182 & data.wyDOY <= 273 );
%                 season(spring_idx) = 2; % SPRING
%                 monsoon_idx = find(data.wyDOY > 273 & data.wyDOY <= 366 );
%                 season(monsoon_idx) = 3; % MONSOON
%                 data.season = season;
                                
                % Cumulative Annual Fluxes (resets to zero at beginning of water year)
                [uniqueWY,idxToUnique,idxFromUniqueBackToAll] = unique(data.wateryear);
                % Accumulatve Precip and ET values over water year
                cumulativeET = accumarray(idxFromUniqueBackToAll,data.ET_mm_dayint,[],@(x) {cumsum(x,'omitnan')});
                data.cumETannual = vertcat(cumulativeET{:});
                
                data_out = data;
        end % calcWaterYear
    end % methods
end % classdef