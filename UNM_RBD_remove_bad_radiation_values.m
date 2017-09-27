function [ sw_incoming, sw_outgoing,lw_incoming, lw_outgoing, Par_Avg ] = ...
    UNM_RBD_remove_bad_radiation_values( sitecode, year_arg, decimal_day, ...
    sw_incoming, sw_outgoing, lw_incoming, lw_outgoing, Par_Avg,NR_tot );
% UNM_RBD_REMOVE_BAD_RADIATION_VALUES - Checks Radiation values against
% potential values from NOAA radiation calculator
%Called from UNM_RBD.m
%
% FIXME - this needs to be finished....
%
% INPUTS
%    sitecode: UNM_sites object; specifies the site to show
%    year: four-digit year: specifies the year to show
%    dataOrig: NxM numeric: the original, unshifted fluxall data
%    dataShifted: NxM numeric: the shifted fluxall data.
%
% OUTPUTS
%    2 figure handles
%
% SEE ALSO
%    UNM_sites, dataset, UNM_fix_datalogger_timestamps, shift_data
%
% author: Alex Moody, July 2017

% Select modeled radiation source
radPotSource = 'AFLX'; %'NOAA'

% Set tolerance for how much higher measured SW_IN can be 
tol = 30;

sitevars = parse_yaml_config( sitecode , 'SiteVars');

dns = datenum( year_arg, 1, 1, 0, 30, 0 ): datenum(year_arg, 12 ,31,24,0,0);
yr_solCalcs = arrayfun( @(x) noaa_potential_rad( ...
    sitevars.latitude, ...
    sitevars.longitude, ...
    floor( x ) ), dns, 'UniformOutput', false );
yr_solCalcs = vertcat(yr_solCalcs{:});
yr_swinpot = yr_solCalcs(:,2);

% Load SW data used by Ameriflux Data Team
AMPdir = 'C:\Research_Flux_Towers\Ameriflux_files\FLUXNET2015\NM-Cluster-POT_SW_IN-2007-2017\NM-Cluster';
fname = sprintf('%s_%d.csv',sitevars.ameriflux_name,year_arg);
SWfile = fullfile(AMPdir,fname);
swinpot2 = text_2_table(SWfile,'n_header_lines',1);

% Determine night flag based on apparent sunrise/sunset
switch radPotSource
    case 'NOAA'
        day_flag = yr_solCalcs(:,1) > yr_solCalcs(:,3) & ...
            yr_solCalcs(:,1) < yr_solCalcs(:,4);
    case 'AFLX'
        day_flag = swinpot2{:,3} ~= 0;
end

% Save raw SW data for plotting
sw_in_old = sw_incoming;

% Remove negative nighttime values
neg_idx = find(sw_incoming < 0);
sw_incoming( neg_idx) = 0;
% Remove positive nighttime values.
 night_idx = find(sw_incoming > 0 & ~day_flag);
 sw_incoming( night_idx ) = 0;

% Apply tolerance
switch radPotSource
    case 'NOAA'
        difftest = sw_incoming - yr_swinpot;
    case 'AFLX'
        difftest = sw_incoming - swinpot2{:,3};
end
bad_idx = find(difftest > tol);
sw_incoming(bad_idx) = NaN;

idx = unique([bad_idx;neg_idx;night_idx]);

% Plot removed data
ts =  datenum( year_arg, 1, 1, 0, 30, 0 ):1/48: datenum(year_arg, 12 ,31,24,0,0);
h_fig = ...
    figure('Position',[486 403 1387 674],'name',sprintf('%s %d SW_IN check',char(sitecode),year_arg));
plot(ts,yr_swinpot,ts,swinpot2{:,3},':',ts,sw_incoming,'.',ts(idx),sw_in_old(idx),'og');
legend('SW_{in,pot}','SW_{in,aflx}','SW_{in,measured}','removed')
datetick;dynamicDateTicks
