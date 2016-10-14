% this script runs a series of checks on completed Ameriflux files to makes
% sure that some things that ORNL has pointed out to us in the past are, in
% fact, corrected.  I intend to turn this into a stand-alone function to run at
% the end of Ameriflux_File_Maker.  -TWH, June 2013

sites = UNM_sites.PPine;
years = 2007:2014;

parse_files = true;
check_FH2O = false;
check_Rg_daily_cycle = false;
check_precip = false;
check_ustar = true;
 
if parse_files
    % initialize empty cell array
    ca = cell( 1, length(sites) );
    for i = 1:length(sites)
        this_site = sites(i);
        ca{ i }   = ...
            assemble_multiyear_ameriflux( this_site, years,...
                                           'suffix', 'with_gaps' )                                           
    end
end

ca2=ca{1,1};
clear ca
ca = ca2; 
clear ca2

if check_ustar
    gscatter(ca.timestamp,ca.USTAR,~isfinite(ca.FC),...
        'rb',... %color
        '..',...  %symbol
        15,...
        'doleg','on');
    title(get_site_name(thissite));
    datetick('x')
    ylabel('USTAR')
    ylim([0 1]);
end

%----------------------------------------------------------------------
% plot H2O flux to check values are <= 200
%----------------------------------------------------------------------
if check_FH2O
    fprintf( 'Maximum FH2O\n' );
    for this_site = sites
        fprintf( '%s: %f\n', ...
                 char( this_site ), ...
                 nanmax( ca{ this_site }.FH2O ) );
        
        % h = figure();
        % plot( ca{ this_site }.FH2O, '.' );
        % title( sprintf( '%s FH2O', char( this_site ) ) );
        % waitfor( h );
    end
end


%----------------------------------------------------------------------
% plot monthly mean daily Rg cycle
%----------------------------------------------------------------------
if check_Rg_daily_cycle
    for this_site = sites

        mm = monthly_aggregated_daily_cycle( ca{ this_site }.timestamp, ...
                                             ca{ this_site}.Rg, ...
                                             @nanmean );

        fname = fullfile( 'Monthly_mean_Rg', ...
                          sprintf( '%s_monthly_Rg_cycle_fromAflux.eps', ...
                                   char( this_site ) ) );
        fname = '';  % empty fname causes figure not to be saved
        plot_monthly_aggregated_daily_cycle( mm, ...
                                             'main_title', char( this_site ), ...
                                             'figure_file_name', fname );
    end
end

if check_precip    
    for this_site = sites
        annual_precip = annual_aggregate( ca{ this_site }.timestamp, ...
                                          ca{ this_site }.PRECIP, ...
                                          @nansum );
        fprintf( '%s\n', char( this_site ) );
        disp( annual_precip );
    end
end