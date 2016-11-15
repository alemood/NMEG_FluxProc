function precip_t = total_precip_calculator( t ) 
% APPLY_NOAH_CORRECTIONS - Calculates total 
%
% Where a timestamp is present in A but not B or vice versa , adds the timestamp
% to B and fills data with NaNs.
%
% USAGE
%    [ tbl_out1, tbl_out2 ] = total_precip_calculator( tbl_in1, tbl_in2, ...
%                                                      tvar1, tvar2, ...
%                                                      tol, ...
%                                                      t_start, t_end )
% INPUTS
%     tbl_in1, tbl_in2: matlab table objects containing data to be merged
%     tvar1, tvar2: strings containing names of table variables containing
%         the timestamps in tbl_in1 and tbl_in2.  These timestamps must be matlab
%         datenum objects.
%
% OUTPUTS
%     tbl_out1, tbl_out2: matlab table objects containing the filled data.
%
% SEE ALSO
%     
% 
% author: Alex C Moody, UNM, November 2016


% Initialize some universal variables

 tol = 0.05; % precision of ETI NOAH II in mm to screen out noise in stable conditions
  
% Get precip table
 if exist('t') ~= 1
 t = toa5_2_table;
 end
 
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
 t2 = table_fill_timestamps( t , 'timestamp', ...
     'delta_t', 1/288 ,...
     't_max',sum_end,...
     't_min', sum_start );

 % Calculate change between timesteps and convert to mm
 dz = diff(t2.ActDepth)/25.4;
 
 %Screen out negative increments. As long as the precip gauge is not
 %drained while it is raining, it should be OK. CR1000 program should
 %account for drains.
 neg_idx = find(dz < 0 );
 dz(neg_idx) = 0;
 % Screen out extreme increments. 
 ext_idx = find(dz > 3*nanstd(dz)); 
 dz(ext_idx) = 0;
 % Align diffs to t_(i+1). First time step will be 0
 dz = vertcat( 0, dz);
 dz(find(~isfinite(dz))) = 0;
 %NOAH II accuracy is +/- 0.01" or 0.254 mm
 dz(find( dz < tol)) = 0;

 % Create a new table with 'tipping bucket' measurements
 t2 = [t2 array2table(dz)];

 
 % Totalize every half hour to get precip rate [mm/30min]
 [num_delt_int, nn] = size(t2);
 precip_array = (reshape(t2.dz,[6, num_delt_int/6 ] ));
 temp_array = reshape(t2.ActTemp, [6, num_delt_int/6 ] );
 ws_array =  reshape(t2.Wspd, [6, num_delt_int/6 ] );
 ts_30min = reshape(t2.timestamp, [6, num_delt_int/6] );
    ts_30min = max(ts_30min);
 
 precip_mm30min = (sum(precip_array));
 temp_avg = nanmean(temp_array);
 ws_avg =  nanmean(ws_array);
 ts_30min = (ts_30min);
 
 % Basic log wind profile. We could get fancier here if we had 3d wind data
 z0 = 2.0; % height of anemometer
 z = 3.0; % height of opening of NOAH II orifice
 alpha = 0.143; % empirical coeff. in stable conditions
 ws_corr = ws_avg.* ( z / z0 ) ^ alpha;
 
 % Calculate correction
 if temp_avg < 4
     corr = exp(4.606-0.036.* ws_corr ^ 1.75 ) ; 
 else
     corr = 101.04 - 5.62.* ws_corr;
 end
 
%  precip_t = [ts_30min', precip_mm30min', precip_mm30min'.*corr',... 
%      corr', ws_avg', temp_avg' ];
%  var_names ={'timestamp','precip_raw', 'precip_corr',...
%      'correction', 'ws', 'temperature'};
%  var_units = {'serial date', 'mm' , 'mm', 'unitless', 'ms-1','C'};
%  precip_t = array2table(precip_t,'VariableNames',var_names);
%  precip_t.Properties.VariableUnits = var_units;

precip_t= [ts_30min', precip_mm30min'.*corr];
var_names ={'timestamp','total_precip'};
precip_t = array2table(precip_t,'VariableNames', var_names);
 
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
% 

 
 
 
 
 
