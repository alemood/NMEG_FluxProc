close all;
clear all;

sitelist = { UNM_sites.GLand, UNM_sites.SLand, UNM_sites.New_GLand, ...
    UNM_sites.JSav, UNM_sites.PJ, UNM_sites.PJ_girdle ,...
    UNM_sites.PPine, UNM_sites.MCon, UNM_sites.MCon_SS };

sitelist = { UNM_sites.PPine};%, UNM_sites.SLand, UNM_sites.New_GLand };
yearlist = 2008;

% True, overwrite files; False; do not overwrite
write_qc = true;
write_gf = true;
old_fluxall = false;
rungapfiller = false;

for i = 1:length(sitelist);
    for j = 1:length(yearlist)
        site = sitelist{i};
        year = yearlist(j);
        % Run remove bad data, view the time offsets, and run the
        % nearby site met gap filler  %draw plots == 3
        
        % FIRST RBD
        UNM_RemoveBadData(site, year, 'draw_plots',0, ...
            'write_QC', write_qc, 'write_GF', write_gf, ...
            'old_fluxall', old_fluxall);
        
        %   UNM_site_plot_fullyear_time_offsets( site, year );
        
        % WARNING - if the "for_gapfilling" files from other NMEG sites are
        % not created AND correct (timeshifts especially) this script will
        % not do a good job of filling the data.
        
        UNM_fill_met_gaps_from_nearby_site( site, year, 'write_output', write_gf );
        
        
        %          UNM_RemoveBadData( site, year, 'draw_plots', 0,  ...
        %              'write_QC', write_qc, 'write_GF', write_gf, ...
        %              'old_fluxall', old_fluxall);
     
        % Fill in gaps using the REddyProc package
        if rungapfiller
            UNM_run_gapfiller(site, year);
        end
        
        % Otherwise, send the resulting for_gapfilling files to
        % the MPI eddyproc web service.
        
      
         close all
    end
end
