% SCRIPT_QC_AFLX - Run a site through all steps of the QC pipeline and plot
% diagnostics related to timestamp shifts and u-start filtering. This
% script was made to double check and troubleshoot files being sent to
% Ameriflux which had been returned by Housen Chu due to chronic shifts in
% solar noon and not removing U-star filtering
%
% Run script entirely or cell-by-cell. If you wish to use the cell
% option, delineate each cell with %% on the preceding line. Then run each
% cell with the keystroke CNTRL+ENTER or the Run section buttonin the editor
% toolbar
%
% author: Alex Moody, UNM, July 2017

clear all; close all

site = UNM_sites.PJ;
siteVars = parse_yaml_config(site,'SiteVars');
aflx_site = siteVars.ameriflux_name;
yearlist = 2008;

% QC Parameters
write_qc = false;
write_gf = false;
% Ameriflux Paramaeters
make_daily = false;
write_files = true;
old_fluxall = false;
process_soil = false;
version = 'NMEG';  %'in_house';
partmethod = 'eddyproc';
do_qc =false;
% %%
% UNM_RemoveBadData(site, year, 'draw_plots',0, ...
%    'write_QC', write_qc, 'write_GF', write_gf, ...
%    'old_fluxall', old_fluxall);
% %%
% UNM_fill_met_gaps_from_nearby_site( site, year, 'write_output', write_gf );
% 
% %%
% UNM_Ameriflux_File_Maker( site, year, ...
%     'write_files', write_files, ...
%     'write_daily_file', make_daily, ...
%     'process_soil_data', process_soil,...
%     'version', version , ...
%     'gf_part_source', partmethod);
%   
for i = 1:length(sitelist)
    site = sitelist{i};
    siteVars = parse_yaml_config(site,'SiteVars');
aflx_site = siteVars.ameriflux_name;
    for j = 1:length(yearlist)
        year = yearlist(j);
%%   
% Load new ameriflux data
if strcmpi(version, 'aflx')
  fstr =  sprintf('C:\\Research_Flux_Towers\\FluxOut\\%s_HH_%d01010000_%d01010000.csv',...
    aflx_site,year,year+1);
aflx_data = ...
    text_2_table(fstr,...
    'n_header_lines',1);
elseif strcmpi(version,'NMEG')
   fstr= sprintf('C:\\Research_Flux_Towers\\FluxOut\\%s_%d_with_gaps.txt',...
       aflx_site, year);
   aflx_data = parse_ameriflux_file(fstr,'version','NMEG');
end

%%
aflx_data.timestamp = [datenum(year,1,1,0,30,0):1/48:datenum(year,12,31,24,0,0)]';
aflx_data.Properties.VariableUnits(:) = {'--'};
aflx_data = replace_badvals(aflx_data,-9999,1);

h_viewer = fluxraw_table_viewer(aflx_data, site, ...
    now);
figure( h_viewer );  % bring h_viewer to the front
waitfor( h_viewer );
clear('fluxraw');
            
%%
% Load AFLX modeled SW_in
AMPdir = 'C:\Research_Flux_Towers\Ameriflux_files\NM-Cluster-POT_SW_IN-2007-2017\NM-Cluster';
fname = sprintf('%s_%d.csv',aflx_site,year);
SWfile = fullfile(AMPdir,fname);
sw_data = text_2_table(SWfile,'n_header_lines',1);
aflx_data.SW_IN;
sw_data.SW_IN_POT;
flags = find(sw_data.SW_IN_POT == 0 & aflx_data.SW_IN ~= 0 & aflx_data.SW_IN ~= -9999);
fprintf('%d remaining positive nighttime SW_IN values\n\n',length(flags))
% Plot AMP SW_IN Model vs. measured values in ameriflux file
idx = find(aflx_data.SW_IN > sw_data.SW_IN_POT);
ts = [datenum(year,1,1,0,30,0):1/48:datenum(year,12,31,24,0,0)];
h1=figure;
plot(ts,sw_data.SW_IN_POT,':k',...
    ts,aflx_data.SW_IN,'ok','MarkerFaceColor',[0.6 0.6 0.6],'MarkerSize',4);
hold on
plot(ts(idx),aflx_data.SW_IN(idx),'ok','MarkerFaceColor',[ 0 1 .1])
legend('SW_{in,pot}','SW_{in,meas}','SW_{in,meas} > SW_{in,pot}')
datetick;dynamicDateTicks

%waitfor( h1 );
              
%%
FCflagday = find(aflx_data.FC ~= -9999 & aflx_data.SW_IN ~= 0);
h2 = figure; subplot(2,1,1)
ts = datenum(year,1,1,0,30,0):1/48:datenum(year,12,31,24,0,0);
plot(ts,aflx_data.USTAR,'.k',...
    ts(FCflagday),aflx_data.USTAR(FCflagday),'.r');
ylim([0 1.75])
legend('USTAR(all)','USTAR FC not missing');
title('daytime')

subplot(2,1,2)
FCflagnight = find(aflx_data.FC ~= -9999 & aflx_data.SW_IN == 0);
plot(ts,aflx_data.USTAR,'.k',...
    ts(FCflagnight),aflx_data.USTAR(FCflagnight),'.r');
ylim([0 1.75])
legend('USTAR(all)','USTAR FC not missing');
title('nighttime')

waitfor(h2)

    end
end



