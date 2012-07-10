function ds_out =  UNM_Ameriflux_prepare_soil_met( sitecode, year, ...
                                                  data, ds_qc )
% UNM_AMERIFLUX_PREPARE_SOIL_MET - 
%   
% contains the section of UNM_Ameriflux_file_maker.m as of 15 Aug 2011 that
% gathers/calculates all the soil met properties.  By modularizing it here it
% should make it easier to streamline this going into the future.  I have gone
% through and replaced QC columns with ds_qc -- the dataset created by
% fluxallqc_2_dataset.m
%   
%
t0 = now();
fprintf( 1, 'Begin soil met properties...' );

% some site-years have non-descriptive labels for soil data columns.  Replace
% these with descriptive labels.
data = UNM_assign_soil_data_labels( sitecode, year, data );

%% create a column of -9999s to place in the dataset where a site does not
%% record a particular variable
dummy = repmat( -9999, size( data, 1 ), 1 );

% find any soil heat flux columns within QC data
shf_vars = regexp_ds_vars( ds_qc, '(SHF|soil_heat_flux).*' );
n_shf_vars = numel( shf_vars );  % how many SHF columns are there?    

% -----
% get soil water content and soil temperature data
% -----

switch sitecode
  case { UNM_sites.GLand, UNM_sites.SLand, UNM_sites.JSav, UNM_sites.MCon, ...
         UNM_sites.TX, UNM_sites.TX_forest, UNM_sites.TX_grass, ...
         UNM_sites.New_GLand }
    % all sites except PJ and PJ_girdle store their soil data in the
    % FluxAll file

    % pull soil water content (SWC), soil temperature (T), and TCAV soil T
    % measurements out of the FluxAll data.

    % get the soil water content and soil T columns and labels
    
    Tsoil = data( :, regexp_ds_vars( data, ...
                                     'soilT_[A-Za-z]+_[0-9]+_[0-9]+.*' ) );

    cs616 = data( :, regexp_ds_vars( data, ...
                                     'cs616SWC_[A-Za-z]+_[0-9]+_[0-9]+.*' ) );
    [ cs616, cs616_Tc ] = cs616_period2vwc( cs616, Tsoil );

    TCAV = data( :, regexp_ds_vars( data, ...
                                     'TCAV_[A-Za-z]+.*' ) );

  case { UNM_sites.PJ, UNM_sites.PJ_girdle }
    % PJ and PJ_girdle store their soil data outside of FluxAll.
    % These data are already converted to VWC.

    [ Tsoil, cs616 ] = preprocess_PJ_soil_data( sitecode, year );
    %[ cs616, cs616_Tc ] = cs616_period2vwc( cs616,  Tsoil );
    cs616_Tc = cs616;
end

[ Tsoil_hilo_removed, ...
  Tsoil_hilo_replaced, ...
  Tsoil_runmean ] = UNM_soil_data_smoother( Tsoil );
[ cs616_hilo_removed, ...
  cs616_hilo_replaced, ...
  cs616_runmean ] = UNM_soil_data_smoother( cs616 );
[ cs616_Tc_hilo_removed, ...
  cs616_Tc_hilo_replaced, ...
  cs616_Tc_runmean ] = UNM_soil_data_smoother( cs616_Tc );

[ Tsoil_cover_depth_avg, ...
  Tsoil_cover_avg ] = soil_data_averager( Tsoil_runmean );
[ VWC_cover_depth_avg, ...
  VWC_cover_avg ] = soil_data_averager( cs616_runmean );

% -----
% -----
% now we have VWC and soil T. Calculate heat flux with storage.
% -----
% -----

SHF_pars = define_SHF_pars( sitecode, year );
SHF = ds_qc( :, shf_vars );

SHF = calculate_heat_flux( TCAV, ...
                           VWC_cover_avg, ...
                           SHF_pars, ...
                           SHF, ...
                           1.0 );

%%======================================================================
%% assign all the variables created above to a dataset to be returned to
%% the caller
%%======================================================================

var_names = { 'Tsoil_1', 'Tsoil_2', 'Tsoil_3', ...
              'SWC_1', 'SWC_2', 'SWC_3', ...
              'SWC_21', 'SWC_22', 'SWC_23', ...
              'par_down_Avg', ...
              'bulk', 'scap', 'wcap', 'depth' };

%% initialize the datset to NaNs
ds_vals = repmat( NaN, size( data, 1 ), numel( var_names ) );
ds_out = dataset( { ds_vals, var_names{:} } );

%% assign values to the dataset
%% soil temperature
ds_out.Tsoil_1 = Tsoil_1;
ds_out.Tsoil_2 = Tsoil_2;
ds_out.Tsoil_3 = Tsoil_3;

%% soil water content
ds_out.SWC_1 = SWC_1;
ds_out.SWC_2 = SWC_2;
ds_out.SWC_3 = SWC_3;

%% the following variables only exist at some sites, so check before
%% assigning them
vars = who();
if exist( 'SWC_21' ) == 1
    ds_out.SWC_21 = SWC_21;
end
if exist( 'SWC_22' ) == 1
    ds_out.out.SWC_22 = SWC_22;
end
if exist( 'SWC_23' ) == 1
    ds_outout.SWC_23 = SWC_23;
end

save hf_restart.mat

ds_out = [ ds_out, ds_shf ];

%% add timestamp

ds_out.timestamp = data_timestamp;

%% calculate execution time and write status message
t_tot = ( now() - t0 ) * 24 * 60 * 60;
fprintf( 1, ' Done (%.0f secs)\n', t_tot );

%----------------------------------------------------------------------    

function [ ds ] = soildata_2_dataset(fluxall, columns, labels)

% SOILDATA_2_DATASET - pulls soil data from parsed Fluxall data into matlab
% dataset.  Helper function for UNM_Ameriflux_prepare_soil_met.
%   

% '.' is not a legal character for matlab variable names -- replace '.' in depth
% labels (now in format e.g. 12.5) with p (e.g. 12p5)
varnames = regexprep( labels, '([0-9])\.([0-9])', '$1p$2' );

ds = dataset( { fluxall( : ,columns ), varnames{ : } } );

%----------------------------------------------------------------------

function SHF_pars = define_SHF_pars( sitecode, year )
% DEFINE_SHF_PARS - specifies parameters for calculating soil heat flux.
% Helper function for UNM_Ameriflux_prepare_soil_met
%   
% (c) Timothy W. Hilton, UNM, April 2012

% set parameter values for soil heat flux
% scap and wcap do not vary among sites
SHF_pars.scap = 837; 
SHF_pars.wcap = 4.19e6; 
SHF_pars.depth = 0.05;

switch sitecode
    % bulk and depth vary across site-year
  case UNM_sites.GLand
    SHF_pars.bulk = 1398; 
  case UNM_sites.SLand
    SHF_pars.bulk=1327; 
  case UNM_sites.JSav
    SHF_pars.bulk=1720; 
  case UNM_sites.PJ
    SHF_pars.bulk=1437; 
  case UNM_sites.PPine
    warning( 'check PPine SHF parameters' );
    SHF_pars.bulk = 1071;
  case UNM_sites.MCon
    warning( 'check MCon SHF parameters' );
    SHF_pars.bulk = 1071;
  case UNM_sites.TX
    SHF_pars.bulk = 1114;
  case UNM_sites.TX_forest
    warning( 'check TX_forest SHF parameters -- bulk is currently NaN' );
    SHF_pars.bulk = NaN;
  case UNM_sites.TX_grass
    warning( 'check TX_grass SHF parameters -- bulk is currently NaN' );
    SHF_pars.bulk = NaN;
  case UNM_sites.PJ_girdle
    SHF_pars.bulk = NaN;
  case UNM_sites.New_GLand
    SHF_pars.bulk = 1398;
end %switch sitecode -- soil heat flux parameters
