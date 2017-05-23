function [ G_s , storage_wm2 ] = calculate_heat_flux( TCAV, ...
                                                 VWC, ...
                                                 SHF_pars, ...
                                                 SHF, ...
                                                 SHF_conv_factor,...
                                                 diagnostic_plots, ...
                                                 year,...
                                                 sitecode)
% CALCULATE_HEAT_FLUX - calculates total soil heat flux by adding storage term
% to flux measured by plate. This gets called by soil_met_correct in the QC
% workflow for soil
% 
% USAGE:
%
%    SHF_with_storage = calculate_heat_flux( TCAV, ...
%                                            VWC, ...
%                                            SHF_pars, ...
%                                            SHF, ...
%                                            SHF_conv_factor )
%   
% INPUTS:
%
%   TCAV: N x M matrix; soil temperature measurement from TCAV; [ C ]
%   VWC: N x M matrix; soil volumetric water content
%   SHF_pars: structure with fields scap, wcap, depth, bulk
%       scap: heat capacity of dry soil [ J/(kg K) ]
%       wcap: heat capacity of moist soil [ J/(kg K) ]
%       depth: depth of heat flux plate [ m ]
%       bulk: bulk density of soil [ kg / m^3 ]
%   SHF: N x M matrix; soil heat flux measurements for one pit; [ mV ]
%   SHF_conv_factor: 1 x M matrix; conversion factors to convert soil heat
%       fluxes from mV to  W / m2.  [ W / m2 / mV ]
%
%   M is the number of [heat flux plate - TCAV] pairs
%
% OUTPUTS:
%
%    SHF_with_storage: N x M dataset; heat flux plus storage.  Has same column
%        labels and order as shf input; [ W / m2 ]
%
% SEE ALSO
%    dataset
%
% author: Timothy W. Hilton, UNM, Dec 2011
% edited by: Alex Moody , UNM , 2017

nrow = size( TCAV, 1 );


[ TCAV, VWC, SHF ] = match_cover_types( TCAV, VWC, SHF );

% If version > 2016b ; fill with fillmissing
TCAV = table_fill_missing( TCAV );
VWC = table_fill_missing( VWC ) ;
SHF = table_fill_missing( SHF ) ;

TCAV = table2dataset( TCAV ) ;
VWC = table2dataset( VWC ) ;
SHF = table2dataset( SHF ) ;

% -----
% calculate storage according to eqs 1, 3 in HFT3 heat flux plate manual.
% -----
rho_w = 1000;  % density of water, kg/m^3
Cw = 4187; % specific heat of water, J/(kg K)
% specific heat of moist soil, J/(m^3 K) -- HFT3 manual eq. 1 (page 5)
Cs = ( SHF_pars.bulk * SHF_pars.scap ) + ...
     ( double( VWC ) .* rho_w * Cw ); 

delta_T = [ repmat( NaN, 1, size( TCAV, 2 ) ); ...
            diff( double( TCAV ) ) ];
fprintf('mean delta t = %f \n', nanmean(nanmean(delta_T)) )
% storage -- HFT3 manual eq. 3 (page 5)
storage_J = delta_T .* Cs .* SHF_pars.depth;  %% storage [ J/m2/30 min ]
storage_wm2 = storage_J ./ ( 60 * 30 );   %% storage [ W / m2 ]

% -----
% calculate heat flux plux storage
% -----

% convert soil heat fluxes to W / m2
G_8 = double( SHF ) .* repmat( SHF_conv_factor, size( SHF ) ); %Heat flux density in wm^-2

% heat flux plus storage -- HFT3 manual eq. 4 (page 5)
G_s = G_8 + storage_wm2;

%  Prep and average surface soil heat flux table 
SHF_labels = SHF.Properties.VarNames;
SHF_labels_new = strrep( SHF_labels , 'SHF_','SHFSFC_' );
G_s = dataset( { single( G_s ) , SHF_labels_new{ : } } );
G_s = dataset2table( G_s ) ;
G_s = site_cover_avg( G_s );

% Average HFPs
SHF = site_cover_avg( SHF );

% Prep and average storage term
storage_labels =  strrep( SHF_labels, 'SHF', 'STORAGE' );
storage_wm2 = array2table( single( storage_wm2  ), 'VariableNames', storage_labels ) ;
storage_wm2 = site_cover_avg( storage_wm2);

% -------- plot all variables for diagnostics
if diagnostic_plots
% x = 1:length(TCAV);
% 
% % figure;
% subplotrc(2,3,1,1 );fanChart( x ,double( SHF ) ); title('SHF')
% subplotrc(2,3,1,2 );fanChart( x ,double( TCAV ) ); title('TCAV')
% subplotrc(2,3,1,3 );fanChart( x ,double( VWC ) ); title('VWC')
% subplotrc(2,3,2,1 );fanChart( x , G_s ); title('SHF sfc wm2')
% subplotrc(2,3,2,2 );fanChart( x , storage_wm2 ); title('Storage')
% subplotrc(2,3,2,3 );fanChart( x , Cs ); title('Specific heat of moist soil')

% stacked time series
% figure;strips(table2array(SHF))

% FINGERPRINT PLOTS
h_fig = plot_shf_fingerprints(table2dataset(SHF) , ...
    table2dataset(storage_wm2) ,...
    table2dataset(G_s),...
    sitecode, year);
%close all

fprintf(' Done calculating Surface SHF \n')

end


% --------------------------------------------------

function tbl_out = site_cover_avg( tbl )

tbl_avg = table();
if ~istable( tbl )
    tbl = dataset2table( tbl );
end

vars = regexp(tbl.Properties.VariableNames,'_','split');
vars = vertcat( vars{ : } );

% Determine if this is shf, swc, tcav, or otherwise. This name is in the
% first column
loggername = unique( vars( :, 1 ) );  
loggername = loggername{:};

% Determine the types of cover( i.e. P, J, O , G)
coverlist = regexp( vars( : ,2 ),'([A-Za-z])','match') ;
cover_cell = unique([coverlist{:}]);

% Average all pits
avg_allpits = nanmean( tbl{ : , : } , 2 ) ;
tbl_avg = [tbl_avg , array2table(avg_allpits,'VariableNames',{strcat(loggername,'_ALL_AVG') } ) ];


for i = 1 : length(cover_cell);
    [ grp_vars grp_idx ] = regexp_header_vars( tbl , cover_cell{ i } );
    if isempty(grp_vars)
        fprintf('No %s cover, moving on...\n',cover_cell{ i } );
    else
    grp_avg = nanmean( tbl{ : , grp_idx } , 2 );
    grp_name = strcat( loggername,'_',cover_cell{i},'_AVG');
    tbl_avg = [ tbl_avg, array2table( grp_avg, 'VariableNames' , { grp_name } ) ] ;
    end
end
% Concatenate tables
tbl_out = [ tbl tbl_avg];
% --------------------------------------------------

function h_fig = plot_shf_fingerprints(SHF , storage_wm2 , G_s , sitecode , year)
jday = IDXjday([1:length(SHF)])';


n_colors = 9;
fig_visible = false;

% Uncomment this if we just want to plot pit and site averages
[pit_names pit_idx]= regexp_header_vars(SHF,'([A-Z]*)(?=_AVG)');
pit_names = regexp(pit_names,'([A-Z]*)(?=_AVG)','tokens');
n_cols = length(pit_idx);
% Uncomment this if we want to plot everything
%[ n_obs n_cols] = size(SHF);
%pit_names = regexp(SHF.Properties.VarNames, '([A-Z]*\d*)(?=_AVG)','match' );

for i = 1:n_cols
    
    % Get column ID for plotting
    col_id = pit_idx( i );
    h_fig(i) = figure( 'Units', 'Normalized' , ...
        'Position',[  0.02    0.41   0.99    0.39 ],...
        'Visible', 'off');
    pal = colormap( cbrewer( 'div', 'RdYlBu', n_colors ) );
    Rg_cmap =  flipud ([ interp1( 1:n_colors, pal, linspace( 1, n_colors, 100)) ] );
    %SHF_8cm
    ax1 = subplot( 1, 3, 1 );
   
    plot_fingerprint( jday, double( SHF(:, col_id) ) , ...
        sprintf( 'SHF_{8cm} ') , ...
        'h_fig', h_fig, ...
        'h_ax', ax1, ...
        'cmap', Rg_cmap, ...
        'clim', [ -120, 120 ],...
        'fig_visible', fig_visible); 
    %STORAGE
    ax2 = subplot( 1, 3, 2 );
    plot_fingerprint( jday, double( storage_wm2(:,col_id) ) , ...
        sprintf( 'Storage' ), ...
        'h_fig', h_fig, ...
        'h_ax', ax2, ...
        'cmap', Rg_cmap, ...
        'clim', [ -120, 120],...
        'fig_visible', fig_visible);    
    %SHF_surface
    ax3 = subplot( 1, 3, 3 );
    plot_fingerprint( jday, double( G_s(:,col_id) ) , ...
        sprintf( 'SHF_{sfc}'), ...
        'h_fig', h_fig, ...
        'h_ax', ax3, ...
        'cmap', Rg_cmap, ...
        'clim', [ -120, 120] ,...
        'fig_visible', fig_visible);  
    
    this_pit_str = pit_names{1,i}{1,1}{1,1};
    suptitle( ...
        sprintf('%s %s %d SHF fingerprints',...
        this_pit_str, char(sitecode), year ) ) ;
    
figure_path = fullfile(getenv('FLUXROOT'),'Plots','soil_heat_flux', ...
    sprintf('%s_%s_%d_SHF_fingerprint.png',char(sitecode),this_pit_str,year) );
saveas(gcf, figure_path );    
end
 

function [TCAV, VWC, SHF] = match_cover_types( TCAV, VWC, SHF )
% MATCH_COVER_TYPES - makes sure TCAV, VWC, and SHF observations observe the
%   same set of ground covers; sorts their columns if necessary to put cover
%   types in same order.  Issues error if duplicate cover types are
%   encountered or if one or more inputs are missing a cover type that is
%   present elsewhere in the inputs.
%
% USAGE
%    [TCAV, VWC, SHF] = match_cover_types( TCAV, VWC, SHF );
%
% INPUTS:
%    TCAV, VWC, SHF: dataset arrays; observations of temperature (TCAV), soil
%        volumetric water content (VWC), and soil heat flux (SHF).  The
%        variables must be named in the format VAR_COVER_DEPTH, where VAR
%        is the variable observed (T, VWC, SHF), COVER is the cover type
%        (e.g. grass, open, juniper, etc.), and depth the depth of the probe
%        in cm.
%
% OUTPUTS:
%    TCAV, VWC, SHF: dataset arrays; as inputs, but with the cover types
%        guaranteed to be identical and in the same order.  
%
% SEE ALSO
%    dataset
% -----
% make sure there are no duplicated cover types -- we are reporting one soil
% heat flux plus storage per cover type.

grp_vars = regexp( SHF.Properties.VariableNames, '_', 'split' );
grp_vars = vertcat( grp_vars{ : } ); 
%cover is 2nd '_'-delimited field
[ SHF_cov, idx_SHF, ~ ] = unique( grp_vars( :, 2 ) );  

grp_vars = regexp( TCAV.Properties.VariableNames, '_', 'split' );
grp_vars = vertcat( grp_vars{ : } ); 
%cover is 2nd '_'-delimited field
[ TCAV_cov, idx_TCAV, ~ ] = unique( grp_vars( :, 2 ) );  

grp_vars = regexp( VWC.Properties.VariableNames, '_', 'split' );
grp_vars = vertcat( grp_vars{ : } ); 
%cover is 2nd '_'-delimited field
[ VWC_cov, idx_VWC, ~ ] = unique( grp_vars( :, 2 ) );  

make_error_msg = @( ds, name ) ...
    sprintf( '%s contains duplicate cover types: %s\n', ...
             name, cellstrcat( ds.Properties.VarNames, ', ' ) );

%---- Keep only pits where all sensors exist -------         
if numel( SHF_cov ) ~= numel( TCAV_cov ) | ...
        numel( SHF_cov ) ~= numel( VWC_cov )
[ ~ , idx_VWC , idx_SHF ] = intersect( VWC_cov , SHF_cov );
[ ~ , idx_TCAV , idx_SHF ] = intersect( TCAV_cov , SHF_cov  );    
[ ~ , idx_TCAV , idx_VWC ] = intersect( TCAV_cov , VWC_cov );
end

if numel( SHF_cov ) ~= size( SHF, 2 )
    error( make_error_msg( SHF, 'SHF' ) );
end

if numel( TCAV_cov ) ~= size( TCAV, 2 )
    error( make_error_msg( TCAV, 'TCAV' ) );
end

if numel( VWC_cov ) ~= size( VWC, 2 )
    error( make_error_msg( VWC, 'VWC' ) );
end

% -----

% make sure all three have their ground cover types in the same order
SHF = SHF( :, idx_SHF );
TCAV = TCAV( :, idx_TCAV );
VWC = VWC( :, idx_VWC );

function table_avg = average_by_cover( tbl_in )

grp_vars = regexp( SHF.Properties.VariableNames, '_', 'split' );
grp_vars = vertcat( grp_vars{ : } ); 
%cover is 2nd '_'-delimited field
[ SHF_cov, idx_SHF, ~ ] = unique( grp_vars( :, 2 ) );  

grp_vars = regexp( TCAV.Properties.VariableNames, '_', 'split' );
grp_vars = vertcat( grp_vars{ : } ); 
%cover is 2nd '_'-delimited field
[ TCAV_cov, idx_TCAV, ~ ] = unique( grp_vars( :, 2 ) );  

grp_vars = regexp( VWC.Properties.VariableNames, '_', 'split' );
grp_vars = vertcat( grp_vars{ : } ); 
%cover is 2nd '_'-delimited field
[ VWC_cov, idx_VWC, ~ ] = unique( grp_vars( :, 2 ) );  

make_error_msg = @( ds, name ) ...
    sprintf( '%s contains duplicate cover types: %s\n', ...
             name, cellstrcat( ds.Properties.VarNames, ', ' ) );

%---- Keep only pits where all sensors exist -------         
if numel( SHF_cov ) ~= numel( TCAV_cov ) | ...
        numel( SHF_cov ) ~= numel( VWC_cov )
[ ~ , idx_VWC , idx_SHF ] = intersect( VWC_cov , SHF_cov );
[ ~ , idx_TCAV , idx_SHF ] = intersect( TCAV_cov , SHF_cov  );    
[ ~ , idx_TCAV , idx_VWC ] = intersect( TCAV_cov , VWC_cov );
end

if numel( SHF_cov ) ~= size( SHF, 2 )
    error( make_error_msg( SHF, 'SHF' ) );
end

if numel( TCAV_cov ) ~= size( TCAV, 2 )
    error( make_error_msg( TCAV, 'TCAV' ) );
end

if numel( VWC_cov ) ~= size( VWC, 2 )
    error( make_error_msg( VWC, 'VWC' ) );
end

% -----

% make sure all three have their ground cover types in the same order
SHF = SHF( :, idx_SHF );
TCAV = TCAV( :, idx_TCAV );
VWC = VWC( :, idx_VWC );

function tbl_filled = table_fill_missing( tbl_in )
    
    filled_array = fillmissing( table2array(tbl_in) ,'movmedian',10);
    tbl_filled = ...
        array2table(filled_array,'VariableNames',tbl_in.Properties.VariableNames );
    
    