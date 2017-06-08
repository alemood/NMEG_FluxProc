
sitelist =     { UNM_sites.PJ, UNM_sites.PJ_girdle,...
    UNM_sites.SLand, UNM_sites.GLand, UNM_sites.New_GLand, ...
    UNM_sites.PPine, UNM_sites.MCon};
sitelist = {UNM_sites.MCon};

releasename = 'FLUXNET2015_c';
path_to_aflx = fullfile(getenv('FLUXROOT'),'Ameriflux_files',releasename);

years = 2010:2016;

for i = 1:length(sitelist);
    % Get site code
    sitecode = sitelist{i};
    
    % Plot! Saves to FLUXROOT/Plots/CZO_figures
    plot_CZO_figure(sitecode, years, ...
        'aflx_path',path_to_aflx) ;
    
end