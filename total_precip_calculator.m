function precip_t = total_precip_calculator( t , sitecode, t_start, t_end, varargin ) 
% TOTAL_PRECIP_CALCULATOR - Converts in/5 minute precipitation data to temperature
% and wind corrected mm/30 min precipitation. Used at Mixed Conifer and New
% Mixed Conifer sites.
%
%
% USAGE
%    [ precip_t ] = total_precip_calculator( precip_table_from_NOAHII/CR1000)
%
% INPUTS
%     t: matlab table containing output tables from CR1000s logging ETI
%     NOAH II total precip gauge data. Contains variables for calculating
%     total precip like ActDepth, RefDepth, wind, air temp
%     sitecode: UNM_sites object.
%     t_start: MATLAB serial date
%     t_end: MATLAB serial date
%
% OUTPUTS
%     precip_t: corrected precip table to be appended to 
%
% SEE ALSO
%     
% author: Alex C Moody, UNM, November 2016

[ this_year, ~, ~ ] = datevec( now() );
args = inputParser;
args.addRequired( 't',  @(x) (istable(x)) );
args.addRequired( 'sitecode', @(x) ( isintval( x ) | isa( x, 'UNM_sites' ) ) );
args.addRequired( 't_start', @isnumeric );
args.addRequired( 't_end', @isnumeric );   
args.addParameter( 'draw_plots', true, ...
    @(x) ( islogical( x ) & numel( x ) == 1 ) );
args.parse( t,sitecode, t_start, t_end, varargin{ : } );
% -----

t = args.Results.t;
sitecode = args.Results.sitecode;
t_start = args.Results.t_start;
t_end = args.Results.t_end;
draw_plots = args.Results.draw_plots;
[year, ~ ,~ ] = datevec(t_start);


% Initialize some universal variables
 tol = 0.254; % [mm] precision of ETI NOAH II in mm to screen out noise in stable conditions (+/- 0.01 inches)
 max_30min_precip = 30; % [mm]  How much rain would we expect in a 30 minute period?
 
 % Start time vector at the beginning of the hour of the first precip
 % record. If the last record is not the beginning of an hour, end at the
 % start of the next hour to include all records.
 % Beginning of hour timestamp (01:00) reflects a sum of buckets tips from
 % 0:35, 0:40, 0:45 , 0:50, 0:55, and 01:00
 % Mid-hour timestamp reflects
 % 0:05, 0:10, 0:15 , 0:20, 0:25, and 0:30
 
 [y1 , m1 , d1 , h1 , min1 , ~ ] = datevec(t_start);
 [y2 , m2 , d2 , h2, min2, ~] = datevec(t_end);
 
 if min1 > 0 & min1 <= 30
     sum_start = datenum([ y1 , m1 , d1 , h1 , 5 , 0 ]);
 elseif min1 == 0
     sum_start = datenum([ y1 , m1 , d1, h1 - 1 , 35 , 0 ]);
 else
     sum_start = datenum([ y1 , m1 , d1, h1 , 35 , 0 ]);
 end
 
 if min2 > 0 & min2 <= 30
     sum_end = datenum([ y2 , m2 , d2 , h2 , 30 , 0 ]);
 elseif min2 == 0
     sum_end = datenum([ y2 , m2 , d2 , h2  , 0 , 0 ]);
 else
     sum_end = datenum([ y2 , m2 , d2 , h2 , 60 , 0 ]);
 end
 fprintf('\n------------- 5 MIN PRECIP AGGREGATION ---------------------\n')
 fprintf('1st Timestamp    1st Sum Int. |  End_Timestamp  Last Sum Int\n')
 fprintf('%s           %s                 %s          %s\n',...
     datestr(t_start,'mmm-dd'),datestr(sum_start,'mmm-dd'),...
     datestr(t_end,'mmm-dd'),datestr(sum_end,'mmm-dd'))
 fprintf('%s            %s-%s           %s           %s-%s\n',...
     datestr(t_start,'HH:MM'), datestr(sum_start,'HH:MM'),datestr(sum_start + 5/288 , 'HH:MM'),...
     datestr(t_end, 'HH:MM'), datestr(sum_end,'HH:MM'),datestr(sum_end + 5/288 , 'HH:MM') );
 fprintf('------------------------------------------------------------\n\n')
 
 % Expand data set ends to nearest half hours
 % There are systematic gaps in logger timestamps where whole rows are
 % missing. At MCon, this interval is about 1 day and 15 hrs. 
 t2 = table_fill_timestamps( t , 'timestamp', ...
     'delta_t', 1/288 ,...
     't_max',sum_end,...
     't_min', sum_start );

 % Calculate change between timesteps and convert to mm ( 1in = 25.4 mm)
 % I suspect only MCon Sulfur Spring is in inches and burned MCon is in
 % centimeters...wtf
 %if sitecode == UNM_sites.MCon_SS
     dz = diff(t2.ActDepth)*25.4;
 %else
 %    dz = diff(t2.ActDepth)*10;
 %end
 dz = vertcat( 0 , dz);
 % Save raw depth changes for plotting later
 dz_orig = dz;
   
 %Screen out negative increments. As long as the precip gauge is not
 %drained while it is raining, it should be OK. CR1000 program should
 %account for drains.
 neg_idx = find(dz < 0 );

 dz(neg_idx) = 0;
 dz(find(~isfinite(dz))) = 0;
 %NOAH II accuracy is +/- 0.01" or 0.254 mm
 dz(find( dz < tol)) = 0;
 dz(find( dz > max_30min_precip ) ) = 0;

 %-------------------------------------------------------------------------
 %                 Create 30 minute tipping bucket measurements
 %------------------------------------------------------------------------
 t2 = [t2 array2table(dz)];

 % Get 30 min averages of met variables
 [num_delt_int, nn] = size(t2);
 % Windspeed header variables are different
 [~,ws_id]= regexp_header_vars(t2,'^Wspd$|^Wspd_avg$');
 
 temp_array = reshape(t2.ActTemp, [6, num_delt_int/6 ] );
 ws_array =  reshape(t2{:,ws_id}, [6, num_delt_int/6 ] );
 ts_30min = reshape(t2.timestamp, [6, num_delt_int/6] );  
 temp_avg = nanmean(temp_array);
 ws_avg =  nanmean(ws_array);
 precip_array = (reshape(dz,[6, num_delt_int/6 ] ));
  
 % Totalize every half hour to get precip rate [mm/30min]
 ts_30min = max(ts_30min);
    ts_30min = (ts_30min);
 
 precip_mm30min = (sum(precip_array)); % put summed precip in table

 %-------------------------------------------------------------------------
 %         Apply wind velocity and solid precip corrections
 %-------------------------------------------------------------------------
 % Basic log wind profile. We could get fancier here if we had 3d wind data
 z0 = 2.0; % height of anemometer
 z = 3.0; % height of opening of NOAH II orifice
 alpha = 0.143; % empirical coeff. in stable conditions
 ws_corr = ws_avg.* ( z / z0 ) ^ alpha;
 
 % Calculate temperature and wind correction
 if temp_avg < 4
     corr = exp(4.606-0.036.* ws_corr ^ 1.75 ) ; 
 else
     corr = 101.04 - 5.62.* ws_corr;
 end
 % Corr is in percentage??? Divide by 100...
  corr = corr./100;

%-------------------------------------------------------------------------
%                 Make 30 minute output table
%-------------------------------------------------------------------------  
precip_t= [ts_30min', ...
    precip_mm30min',(precip_mm30min.*corr)',...
    corr',...
    temp_avg'];

var_names ={'timestamp',...
    'P_NOAH','P_NOAH_corr',...
    'NOAH_wind_corr'};
var_units = { '--' ,...
    'mm','mm',...
    '--'};
precip_t = array2table(precip_t(:,[1:4]),'VariableNames', var_names);
precip_t.Properties.VariableUnits = var_units;

%-------------------------------------------------------------------------
%                 Plots
%------------------------------------------------------------------------- 
if draw_plots
    figure('Position',[680 574 442 524],'Name',[char(sitecode),' Total Precip Diagnostics 1']);
    ax2(1) = subplot(2,1,1); 
        plot(precip_t.timestamp,precip_t.P_NOAH,'ok',...
            'MarkerFaceColor',[0.800 0.8 0.8],'LineWidth',1,...
            'Color',[0 0 0]); hold on
        plot( precip_t.timestamp,precip_t.P_NOAH_corr,'.',...
            'MarkerSize',10,'Color',[0.33 0.75 0.93]); hold off
        ylabel('mm/5min')
        legend('uncorrected','corrected')
       
        
    ax2(2) = subplot(2,1,2); 
         plot(precip_t.timestamp,[cumsum(precip_t.P_NOAH),cumsum(precip_t.P_NOAH_corr)],...
             'LineWidth',1)
         ylabel('mm')
         title(['Cumulative precip = ', num2str(max(cumsum(precip_t.P_NOAH_corr))), ' mm',...
             ' (',  num2str(max(cumsum(precip_t.P_NOAH_corr))/25.4), ' in )' ] ) 
         
   linkaxes(ax2,'x')
   dynamicDateTicks(ax2,'linked')
   
fillData = getFillPrecip(sitecode, year,t_start, t_end );   

% Compare filled Precip with total precip gage
[fillData precip_t ] = ...
    merge_tables_by_datenum(fillData,precip_t,'timestamp','timestamp',0.01,t_start,t_end);
P = precip_t.P_NOAH;
Pf = fillData.P;
ts1 = precip_t.timestamp;
ts2 = fillData.timestamp;

figure('Name','Total Precip Diagnostics 2');
plot(ts1,cumsum(P,'omitnan'),':k',ts2,cumsum(Pf,'omitnan'),'r');
legend(sprintf('%s Gauge',char(sitecode)),'Redondo','Location','Best');
ylabel('cumulative precip [mm]');
datetick('x','keepticks', 'keeplimits' );
title(sprintf('Redondo = %3.1f mm NMCon = %3.1f mm', ...
    max(cumsum(Pf,'omitnan')),...
    max(cumsum(P,'omitnan')))); 
end
end


%========================= SUBFUNCTIONS ==================================

function fillData = getFillPrecip(sitecode, year,t_start,t_end )

% Get gapfilled data
fillData = parse_forgapfilling_file(sitecode,year);
keepidx = fillData.timestamp > t_start &...
          fillData.timestamp < t_end;
fillData(~keepidx,:) = [];

fillData = fillData(:,{'timestamp','P'});

end
  

