function precip_t = total_precip_calculator( t ) 
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
%     tvar1, tvar2: strings containing names of table variables containing
%         the timestamps in tbl_in1 and tbl_in2.  These timestamps must be matlab
%         datenum objects.
%
% OUTPUTS
%     precip_t: corrected precip 
%
% SEE ALSO
%     
% 
% author: Alex C Moody, UNM, November 2016


% Initialize some universal variables

 tol = 0.254; % precision of ETI NOAH II in mm to screen out noise in stable conditions (+/- 0.01 inches)
 plotfig = true;
 colors = { '.r', '.m', '.b', '.y', '.g', '.c' };
% Load precip table
% load(fullfile(getenv('FLUXROOT'),'NOAH_II_precip.mat'));
 
% % Get precip table
%  if exist('t') ~= 1
%  t = toa5_2_table;
%  end
%  
 
 [y1 , m1 , d1 , h1 , min1 , ~ ] = datevec(t.timestamp(1));
 [y2 , m2 , d2 , h2, min2, ~] = datevec(t.timestamp(end));
  
 % Start time vector at the beginning of the hour of the first precip
 % record. If the last record is not the beginning of an hour, end at the
 % start of the next hour to include all records.
 % Beginning of hour timestamp (01:00) reflects a sum of buckets tips from
 % 0:35, 0:40, 0:45 , 0:50, 0:55, and 01:00
 % Mid-hour timestamp reflects
 % 0:05, 0:10, 0:15 , 0:20, 0:25, and 0:30
 
 if min1 > 0 & min1 < 30
     sum_start = datenum([ y1 , m1 , d1 , h1 , 5 , 0 ]);
 else
     sum_start = datenum([ y1 , m1 , d1, h1, 35 , 0 ]);
 end
 
 if min2 > 0 & min2 < 30
     sum_end = datenum([ y2 , m2 , d2 , h2 , 30 , 0 ]);
 else
     sum_end = datenum([ y2 , m2 , d2 , h2 , 60 , 0 ]);
 end
 
 % Expand data set ends to nearest half hours
 % There are systematic gaps in logger timestamps where whole rows are
 % missing. At MCon, this interval is about 1 day and 15 hrs. 
 t2 = table_fill_timestamps( t , 'timestamp', ...
     'delta_t', 1/288 ,...
     't_max',sum_end,...
     't_min', sum_start );

 % Calculate change between timesteps and convert to mm ( 1in = 25.4 mm)
 dz = diff(t2.ActDepth)*25.4;
 dz = vertcat( 0 , dz);
   
 %Screen out negative increments. As long as the precip gauge is not
 %drained while it is raining, it should be OK. CR1000 program should
 %account for drains.
 neg_idx = find(dz < 0 );
 if plotfig
     ax(1) = subplot(4,1,1);
     plot(t2.timestamp,dz,'.');
     title('raw dz')
 end
  % Align diffs to t_(i+1). First time step will be 0
 dz(neg_idx) = 0;
  if plotfig
     ax(2) = subplot(4,1,2);
     plot(t2.timestamp,dz,'.');
       title(' > 0')
 end
 
 dz(find(~isfinite(dz))) = 0;
 
 %NOAH II accuracy is +/- 0.01" or 0.254 mm
 dz(find( dz < tol)) = 0;
 if plotfig
     ax(3) = subplot(4,1,3);
     plot(t2.timestamp,dz,'.');
      title('>0 , > 0.254 mm')
 end
 dz(find( dz > 8 * nanstd(dz))) = 0;
 dz(find( dz > 10 ) ) = 0;
 if plotfig
     ax(4) = subplot(4,1,4);
     plot(t2.timestamp,dz,'.');
     title('> 0 , > 0.254 mm, < 5 \sigma')
 end
 linkaxes(ax,'x')
 dynamicDateTicks(ax,'linked')
 % Create a new table with 'tipping bucket' measurements
 t2 = [t2 array2table(dz)];

 % Get 30 min averages of met variables
 [num_delt_int, nn] = size(t2);

 temp_array = reshape(t2.ActTemp, [6, num_delt_int/6 ] );
 ws_array =  reshape(t2.Wspd, [6, num_delt_int/6 ] );
 ts_30min = reshape(t2.timestamp, [6, num_delt_int/6] );  
 temp_avg = nanmean(temp_array);
 ws_avg =  nanmean(ws_array);
 precip_array = (reshape(dz,[6, num_delt_int/6 ] ));
  
 % Totalize every half hour to get precip rate [mm/30min]
 ts_30min = max(ts_30min);
    ts_30min = (ts_30min);
 
 precip_mm30min = (sum(precip_array)); % put summed precip in table


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
  
precip_t= [ts_30min', precip_mm30min',(precip_mm30min.*corr)',corr'];
var_names ={'timestamp','precip','precip_corr', 'corr'};
precip_t = array2table(precip_t,'VariableNames', var_names);

if plotfig
    figure;
    ax2(1) = subplot(2,1,1); 
        plot(precip_t.timestamp,[precip_t.precip,precip_t.precip_corr],'.')
        ylabel('mm/5min')
    ax2(2) = subplot(2,1,2); 
         plot(precip_t.timestamp,[cumsum(precip_t.precip),cumsum(precip_t.precip_corr)])
         ylabel('mm')
         title(['Cumulative precip = ', num2str(max(cumsum(precip_t.precip_corr))), ' mm',...
             '/',  num2str(max(cumsum(precip_t.precip_corr))/25.4), ' in' ] ) 
         linkaxes(ax2,'x')
         dynamicDateTicks(ax2,'linked')
end
end
  
 % Plot of corrections
%  ws_test = linspace(1,10,20)';
%  figure;plot(ws_test, [exp(4.606 - 0.036 .* (ws_test .^ 1.75 )) ,...
%                  101.04 - 5.62.* ws_test ])
%  legend('Solid Precip','Liquid Precip')
%  xlabel('Wind Speed [m/s]'); ylabel('Precip wind correction')
 
%  precip_t = [ts_30min', precip_mm30min', precip_mm30min'.*corr',... 
%      corr', ws_avg', temp_avg' ];
%  var_names ={'timestamp','precip_raw', 'precip_corr',...
%      'correction', 'ws', 'temperature'};
%  var_units = {'serial date', 'mm' , 'mm', 'unitless', 'ms-1','C'};
%  precip_t = array2table(precip_t,'VariableNames',var_names);
%  precip_t.Properties.VariableUnits = var_units;


% 
% nonan = precip_t.precip_corr;
% nonan( find( isnan( nonan ) )) = 0;
% cum_precip_corr = cumsum( nonan );
% 
% figure
% ax(1) = subplot(2,1,1);
%     plot(precip_t.timestamp,[precip_t.precip, precip_t.precip_corr]);
% ax(2) = subplot(2,1,2);
%     plot(precip_t.timestamp,[cumsum(precip_t.precip), cum_precip_corr]);
% linkaxes(ax,'x')
% dynamicDateTicks([ax(1) ax(2)],'linked')
 
%%%%%%%%
% PLOTS
%%%%%%%%
%
%  h_viewer = fluxraw_table_viewer(precip_t, 'this_site', ...
%                 max(ts_30min));
%             figure( h_viewer );  % bring h_viewer to the front
%             waitfor( h_viewer );
% Test different tolerances for filtering noise             
%   subplot(3,1,1) 
%     plot( t2.timestamp, dz ); datetick('x'); title('raw')
%  subplot(3,1,2)
%      tol = 0.05;
%      dz1 = dz;
%      dz1(find( dz1 < tol)) = 0;
%     plot( t2.timestamp, dz1 ); datetick('x')
%  subplot(3,1,3)
%      tol = 0.254;
%      dz2 = dz;
%      dz2(find( dz2 < tol)) = 0;
%     plot( t2.timestamp, dz2 ); datetick('x')
%  figure;
%   subplot(3,1,1)
%   hist(dz)
%   subplot(3,1,2)
%   hist(dz1)
%   subplot(3,1,3)
%   hist(dz2)

 %%%%%%%%%%%%%%%%%
 %%% PLOTS
 %%%%%%%%%%%%%%%%%
%  % Plot 1 - 5 min precip data with varying threshold cutoffs
%  ax(1) = subplot(3,1,1) ;
%     plot( t2.timestamp, dz ); datetick('x'); title('raw');
%     sumP = max(cumsum(dz));
%     numobs = numel(dz);
%     ylabel('P [mm/5min]');title(...
%         sprintf('Cumulative P = %3.2f mm (%3.2f in) \n %d raw obs.',...
%         sumP,sumP/25.4,numobs));
%     datetick
%  ax(2) = subplot(3,1,2);
%      tol = 0.05;
%      dz1 = dz;
%      remove_idx = find( dz1 < tol);
%      dz1(remove_idx) = 0;
%      sumP = max(cumsum(dz1));
%     plot( t2.timestamp, dz1 ); datetick('x')
%     ylabel('P [mm/5min]');title(...
%         sprintf('Thresh = 0.05 mm Cumulative P = %3.2f mm (%3.2f in) \n %d (%3.1f%%) obs. removed',...
%         sumP,sumP/25.4,numel(remove_idx),numel(remove_idx)/numobs*100));
%  ax(3) = subplot(3,1,3);
%      tol = 0.254;
%      dz2 = dz;
%      remove_idx = find( dz2 < tol);
%      dz2(remove_idx) = 0;
%      sumP = max(cumsum(dz2));
%     plot( t2.timestamp, dz2 ); datetick('x')
%     ylabel('P [mm/5min]');title(...
%         sprintf('Thresh = 0.254 mm   Cumulative P = %3.2f mm (%3.2f in)\n %d (%3.1f%%) obs. removed',...
%         sumP,sumP/25.4,numel(remove_idx),numel(remove_idx)/numobs*100));
%     
%  linkaxes(ax,'x')
%  dynamicDateTicks(ax,'linked')
% 
% function nonan = nan_cumsum( arr )
%     nonan = arr;
%     nonan( find( isnan( nonan ) )) = 0;
%     nonan = cumsum( nonan );
% end
%  
%   % Plot 2 - 30 min precip rates with corrections
%  dz_array = [dz dz1 dz2];   % compile dz with varying cutoffs into table
%  dztbl = array2table(dz_array);
%  dztbl.Properties.VariableNames = {'raw' ,'k_p05', 'k_p254'};
 
 
