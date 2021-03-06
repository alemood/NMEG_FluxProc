function h_fig = RBD_plot_fingerprints( sitecode, year, decimal_day, ...
                                        sw_incoming, rH, ...
                                        Tair, NEE, LE, H_dry, main_t_str )
% RBD_PLOT_FINGERPRINTS - Creates a figure with six panels displaying
% "fingerprint" plots for Rg, RH, T, NEE, LE, H.
% 
% Helper function for UNM_RemoveBadData (RBD).
% 
% USAGE
% RBD_plot_fingerprints( sitecode, year, decimal_day, ...
%                        sw_incoming, rH, Tair, NEE, LE, H_dry, ...
%                        main_t_str );
%
% INPUTS
%     sitecode: UNM_sites object; specifies the site (for plot labels)
%     year: four digit year: specifies the year (for plot labels)
%     decimal_day: fractional day of year (internal variable within RBD)
%     sw_incoming: incoming shortwave radiation (internal variable within RBD)
%     rH: relative humidity (internal variable within RBD)
%     NEE: net ecosystem exchange (internal variable within RBD)
%     LE: latent heat (internal variable within RBD)
%     H_dry: sensible heat (internal variable within RBD)
%     main_t_str: title for the plot, to appear centered above all panels
%
% OUTPUTS
%     h_fig: handle to the figure containing the plot
%
% SEE ALSO
%     dataset, UNM_RemoveBadData, UNM_RemoveBadData_pre2012
%
% author: Timothy W. Hilton, UNM, June 2012

h_fig = figure( 'Units', 'Normalized' );

ax1 = subplot( 2, 3, 1 );
pal = colormap( cbrewer( 'seq', 'YlOrRd', 9 ) );
Rg_cmap = [ interp1( 1:6, pal( 1:6, : ), linspace( 1, 6, 10 ) ); ...
            interp1( 0:3, pal( 6:9, : ), linspace( 0, 3, 1000 ) ) ];
plot_fingerprint( decimal_day, sw_incoming, ...
                  sprintf( '%s %d Rg fingerprint', ...
                           char( sitecode ), year ), ...
                  'h_fig', h_fig, ...
                  'h_ax', ax1, ...
                  'cmap', Rg_cmap, ...
                  'clim', [ -10, 1400 ] );

ax2 = subplot( 2, 3, 2 );
% Hopefully rH is standardized now
% if max( rH ) > 1
%     rH_max = 100;
% else
% DAN K
rH_max = 100.0;

plot_fingerprint( decimal_day, rH, ...
                  sprintf( '%s %d RH fingerprint', ...
                           char( sitecode ), year ), ...
                  'h_fig', h_fig, ...
                  'h_ax', ax2, ...
                  'clim', [ 0, rH_max ] );

ax3 = subplot( 2, 3, 3 );
plot_fingerprint( decimal_day, Tair, ...
                  sprintf( '%s %d T fingerprint', ...
                           char( sitecode ), year ), ...
                  'h_fig', h_fig, ...
                  'h_ax', ax3, ...
                  'clim', [ -20, 40 ] );

ax4 = subplot( 2, 3, 4 );
NEE_nobad = replace_badvals( NEE, [ -9999 ], 1e-6 );
pal = colormap( cbrewer( 'div', 'PRGn', 9 ) );
NEE_cmap = [ interp1( 1:9, pal, linspace( 1, 9, 100 ) ) ];
NEE_cmap = flipud( NEE_cmap );
plot_fingerprint( decimal_day, NEE_nobad, ...
                  sprintf( '%s %d NEE fingerprint', ...
                           char( sitecode ), year ), ...
                  'h_fig', h_fig, ...
                  'h_ax', ax4, ...
                  'cmap', NEE_cmap, ...
                  'center_caxis', true, ...
                  'clim', [ -2, 2 ] );

ax5 = subplot( 2, 3, 5 );
plot_fingerprint( decimal_day, LE, ...
                  sprintf( '%s %d LE fingerprint', ...
                           char( sitecode ), year ), ...
                  'h_fig', h_fig, ...
                  'h_ax', ax5, ...
                  'clim', [ 0, 200 ] );

ax6 = subplot( 2, 3, 6 );
plot_fingerprint( decimal_day, H_dry, ...
                  sprintf( '%s %d H fingerprint', ...
                           char( sitecode ), year ), ...
                  'h_fig', h_fig, ...
                  'h_ax', ax6, ...
                  'clim', [0, 500 ] ); 

set( h_fig, 'Units', 'Normalized', ...
            'outerposition', [ 0, 0, 1, 1 ], ...
            'Name', main_t_str );

% create a "main" title above the six subplots
ha = axes( 'Position', [0 0 1 1], ...
           'Xlim',[0 1], 'Ylim',[0 1],...
           'Box','off','Visible','off',...
           'Units','normalized', ...
           'clipping' , 'off');
text(0.5, 1, strcat( '\bf ', ...
                     strrep( main_t_str, '_', '\_' ) ),...
     'HorizontalAlignment' ,'center',...
     'VerticalAlignment', 'top');

%save the fingerprints plot to a PDF
fname = sprintf( 'fingerprint_%s_%s_%d.eps', ...
                 main_t_str, ...
                 char( UNM_sites( sitecode ) ), ...
                 year );
fprintf( 'fname: %s\n', fname );

% make the figure the same size regardless of screen size
set( h_fig, 'Units', 'Inches' );
pos = get( h_fig, 'Position' );
pos( 3:4 ) = [ 10.0, 7.5 ]; %size for 8.5 x 11 paper with 0.5" margins
set( h_fig, 'Position', pos ); 

%full_fname = fullfile( 'C:', 'Users', 'Tim', 'Plots', 'RadiationOffset', fname )
% full_fname = fullfile( getenv( 'PLOTS' ), ...
%                        'RadiationOffset', 'AmerifluxFingerprints6Jul', fname );
% figure_2_eps( h_fig, full_fname  );
%close( h_fig );
