% WRITE_FOOTPRINT_INPUT
% This script creates a csv that is formatted for use in Kljun's footprint
% model, found at http://geography.swansea.ac.uk/nkljun/ffp/www/upload.php
% and implemented in Eddypro.
%
% The online tool has some features that would be nice to use, such as
% maps and a 2-D estimator.
%
% OUTPUTS
% foot_tbl - MATLAB table with the following output variables
% yyyy     - Year
% mm	   - Month [1 - 12]
% day	   - Day of Month
% HH_UTC   - UTC Hour [+7 for New Mexico]
% MM	   - Minutes
% zm	   - Measurement height above ground [m]
% d	       - Displacement height [m] approximated at 0.67 * canopy height
% z0       - Roughness length [m] approximated at 0.15 * canopy height
% u_mean   - Mean wind speed at zm
% L        - Obukhov length [m]
% sigma_v  - Standard deviation of laterval velocity fluctations after rotations
% u_star
% wind_dir
%
% Note: Either z0 or u_mean is required. If both are given, z0 is slected 
% to calculate the footprint

% Site and year selection
sitecode = UNM_sites.MCon_SS

year = 2016;

% Site configuration
conf = parse_yaml_config( sitecode ,'SiteVars' );
z_canopy = conf.canopy_height_m;
zm = conf.z_sonic_m;

% Estimate d and z0
z0 = 0.15 * z_canopy;
d = 0.67 * z_canopy;

% -----------------------------
% Load tables
% -----------------------------
% Fluxall for cross-wind covariances used in Obukhov Length Calc
flux_tbl = parse_fluxall_txt_file( sitecode , year );
% QC for most variables
qc_tbl = parse_fluxall_qc_file(sitecode,year);
% Filled table get ustar

% ---------------------------------
%       Calculate Obukhov Length
% --------------------------------
USTAR = qc_tbl.u_star;
TD = qc_tbl.Tdry;
cov_Ts_Uz = flux_tbl.cov_Ts_Uz;
L = -( ( USTAR ).^3.* TD )./ ( 0.4.* 9.81.* cov_Ts_Uz);

% Filter out periods where flux values were screened?
noflux_id = find( isnan(qc_tbl.fc_raw_massman_wpl) );

% ---------------------
%  Calculate UTC time
% --------------------
hrs_per_day = 24;
UTC_offset = 7;
[ yyy , mm , day , HH_UTC , MM , ~ ] = ...
    datevec( qc_tbl.timestamp  + UTC_offset/hrs_per_day );

% -----------
% Calculate remaining variables
% -----------------------------
n = height(flux_tbl);

[ sigma_v ] = sqrt( flux_tbl.cross_wind_velocity_variance );


zm = repmat( zm , n ,1 );
d = repmat( d, n , 1);
z0 = repmat( z0 , n , 1);
% -----------------------------
%       Make Output Tables
% -----------------------------

 ffpvarnames = {'yyy'	'mm'	'day'	'HH_UTC'	'MM' , ...
     'zm'	'd'	'z0'	'u_mean'	'L'	'sigma_v' ,...
     'u_star'	'wind_dir' };
 
 ffpvars = [ yyy mm day HH_UTC MM ,...
             zm  d z0 qc_tbl.wnd_spd L sigma_v ,...
             USTAR  qc_tbl.wnd_dir_compass];
 ffpvars( isnan( ffpvars ) ) = -999;

 
tbl_out = array2table(ffpvars,'VariableNames',ffpvarnames);

fname_out = fullfile( get_site_directory(sitecode), ...
    'processed_flux',...
    sprintf('data_ffp_%d.csv',year));
writetable( tbl_out , fname_out);

