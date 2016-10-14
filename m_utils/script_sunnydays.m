%CALCULATE SUNNY DAYS
%Sandbox script to calculate time periods that are not light-limited.
%   -Could be merged into 'local' UNM use ameriflux files
%   - Maybe develop a 'light reponse curve' of photosynthesis(GPP?) vs. PAR?
%   - Uses 'old' pre-AMP PI meeting 2016 ameriflux files [FLUXNET2015_a Formatting is
%   slightly different.
sitelist = {UNM_sites.GLand, UNM_sites.SLand, UNM_sites.JSav,...
    UNM_sites.PPine, UNM_sites.MCon };
sitelist = {UNM_sites.PJ};
yearlist = 2014;

gapfilled = true;

%----------------------------------------------------------------
% PAR threshold value (micromol m-2 s-1) that constitutes "sunny"
%-----------------------------------------------------------------
sunthresh = 800;

if gapfilled
    fname_suffix = 'gapfilled';
else
    fname_suffix = 'withgaps';
end

for i = 1:length(sitelist);
    for j = 1:length(yearlist)
        sitecode = sitelist{i};
        year = yearlist(j);
    
        
        outdir = get_out_directory( sitecode );
        sites_info = parse_UNM_site_table();
        aflx_site_name = char( sites_info.Ameriflux( sitecode ) );
        fname = fullfile( getenv('FLUXROOT'), ...
            'Ameriflux_files\FLUXNET2015_a',...
            sprintf( '%s_%d_%s.txt', ...
            aflx_site_name, ...
            year, ...
            fname_suffix ) );
        
        t = parse_ameriflux_file( fname );
        
        % Suntimes = 0 when PAR < sunthresh, 1 when PAR > sunthresh
        suntimes = t.PAR > sunthresh;
        aa = reshape(suntimes(2:end),48,365);
        suncount = sum(aa);
        sunhours = suncount*30/60;
        
% fh = figure( 'Units', 'Normalized' );
% pos = get( fh, 'Position' );
% pos( [ 2, 4 ] ) = [ 0, 1 ];
% set( fh, 'Position', pos );

%Diel plot of PAR colored by Sunny and non-sunny time periods
    H = mod(t.DTIME, floor(t.DTIME))*24
    %all_axes( 1 ) = subplot( numel( years ), 1, 1 );
    scatter( H, t.PAR,50,t.PAR > 800);
    xlim( [ 0, 24 ] );
    %ylim( [ -50, 500 ] );
    xlabel( 'hour' );
    ylabel( 'PAR' );
    %title( sprintf( '%s %d', sd.SITE_NAME{ sitecode }, years( i ) ) );
end

    end
end
