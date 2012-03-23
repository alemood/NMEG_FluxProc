%reads from file "data to run.xls" and feeds to fluxes
%freemanKA
% modified by Timothy W. Hilton, Aug 2011

function [args] = UNM_data_feeder_xls()
  
  filein = 'C:\Research_Flux_Towers\data to run.xls';
% $$$   if exist(filein != 2)
% $$$     filein = uigetfile()
% $$$   end
  matrix=xlsread(filein,'current','A1:I100');
  site=matrix(:,1);
  year=matrix(:,2);
  start_jday=matrix(:,5);
  end_jday=matrix(:,8);
  starttime_num=matrix(:,9);
  n=size(matrix,1);

  args = struct('site', site, ...
		'year_start', year, ...
		'year_end', year, ...
		'jday_start', start_jday, ...
		'jday_end', end_jday, ...
		'hour_start', floor(starttime_num / 100), ...
		'min_start', mod(starttime_num, 100), ...
		'n', n, ...
		'cmon_start', NaN, ...   %placeholders for unnecessary fields
		'cday_start', NaN, ...
		'cmon_end', NaN, ...
		'cday_end', NaN);
  

  