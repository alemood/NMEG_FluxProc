clear all; close all
site = UNM_sites.PJ;
siteVars = parse_yaml_config(site,'SiteVars');
aflx_site = siteVars.ameriflux_name;
yearlist = 2012;
% QC Parameters
write_qc = true;
write_gf = true;
% Ameriflux Paramaeters
make_daily = false;
write_files = true;
old_fluxall = false;
process_soil = false;
version = 'aflx';  %'in_house';  
partmethod = 'eddyproc';
% QC Issue
qc_issue = 'ts_shift';


for i = 1:length(yearlist)
    year = yearlist(i);
    
    
    UNM_RemoveBadData(site, year, 'draw_plots',3, ...
        'write_QC', write_qc, 'write_GF', write_gf, ...
        'old_fluxall', old_fluxall);
    
    %UNM_fill_met_gaps_from_nearby_site( site, year, 'write_output', write_gf );
    
    UNM_Ameriflux_File_Maker( site, year, ...
        'write_files', write_files, ...
        'write_daily_file', make_daily, ...
        'process_soil_data', process_soil,...
        'version', version , ...
        'gf_part_source', partmethod);
    
    % Load AFLX modeled SW_in
    AMPdir = 'C:\Research_Flux_Towers\Ameriflux_files\NM-Cluster-POT_SW_IN-2007-2017\NM-Cluster';
    fname = sprintf('%s_%d.csv',aflx_site,year);
    SWfile = fullfile(AMPdir,fname);
    sw_data = text_2_table(SWfile,'n_header_lines',1);
 %%   
    % Load new ameriflux data
    aflx_data = ...
        text_2_table(...
        sprintf('C:\\Research_Flux_Towers\\FluxOut\\%s_HH_%d01010000_%d01010000.csv',...
        aflx_site,year,year+1),...
        'n_header_lines',1);
    aflx_data.timestamp = [datenum(year,1,1,0,30,0):1/48:datenum(year,12,31,24,0,0)]'; 
    aflx_data.Properties.VariableUnits(:) = {'--'};
    aflx_data = replace_badvals(aflx_data,-9999,1);

    h_viewer = fluxraw_table_viewer(aflx_data, site, ...
                now);
            figure( h_viewer );  % bring h_viewer to the front
            waitfor( h_viewer );
            clear('fluxraw');
            
            %%
            
    switch qc_issue
        case 'ts_shift'
            aflx_data.SW_IN;
            sw_data.SW_IN_POT;
            flags = find(sw_data.SW_IN_POT == 0 & aflx_data.SW_IN ~= 0 & aflx_data.SW_IN ~= -9999);
            fprintf('%d remaining positive nighttime SW_IN values\n\n',length(flags))
        case 'ustar_night'
            close all
            FCflagday = find(aflx_data.FC ~= -9999 & aflx_data.SW_IN ~= 0);
            figure; subplot(2,1,1)
            ts = datenum(year,1,1,0,30,0):1/48:datenum(year,12,31,24,0,0);
            plot(ts,aflx_data.USTAR,'.k',...
                ts(FCflagday),aflx_data.USTAR(FCflagday),'.r');
            ylim([0 1.75])
            legend('USTAR(all)','USTAR FC not missing');
            title('daytime')
            
            subplot(2,1,2)
            FCflagnight = find(aflx_data.USTAR ~= -9999 & aflx_data.SW_IN == 0);
            plot(ts,aflx_data.USTAR,'.k',...
                ts(FCflagnight),aflx_data.USTAR(FCflagnight),'.r');
            ylim([0 1.75])
            legend('USTAR(all)','USTAR FC not missing');
            title('nighttime')
    end
end

