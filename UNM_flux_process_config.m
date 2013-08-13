function fluxrc =  UNM_flux_process_config()
% UNM_flux_process_config() -- defines and sets values for number of
% configuration items for flux processing.  
%
% My plan is to parse this information from an ASCII configuration file.  For
% now, UNM_flux_process_config.m should be directly edited to change the
% options described below.
%
% INPUTS: 
%   none
%
% OUTPUTS:
%   Returns a structure with the following fields:
%   site_names: acceptable site abbreviation--site code pairs.  This field is
%      a cell array of strings containing site abbreviations (e.g. 'GLand',
%      'PJ', etc.)  Abbreviations not in this list cannot be processed.  The
%      order of abbreviations in the list defines their numeric site codes.
%   FLUXROOT: path to the directory containing the flux data.  The individual
%      sites' data directories are assumed to reside here.
%   sitefolder: The directory within FLUXROOT containing the sites'
%      directories (e.g. 'Flux_Tower_Data_by_Site').
%   outfolder: directory where processed fluxes will be placed.
%
% author: Timothy W. Hilton, UNM, Aug 2011    

% define the allowed site abbreviations and their site codes the order
% matters -- each abbreviation's position in the list is its site code
%  This could be changed in get_site_code.m
%             Site Abbrev          Site Code
site_names = {'GLand', ...         % 1
              'SLand', ...         % 2
              'JSav', ...          % 3
              'PJ', ...            % 4
              'PPine', ...         % 5
              'MCon', ...          % 6
              'TX', ...            % 7
              'TX_forest', ...     % 8
              'TX_grassland', ...  % 9
              'PJ_girdle', ...     % 10
              'New_GLand', ...      % 11
              'SevEco'};        % 12

FLUXROOT = getenv('FLUXROOT');
while length(FLUXROOT) == 0
    %error('environment variable fluxroot not defined');
    FLUXROOT = input( [ 'environment variable fluxroot not defined; please ' ...
                        'define FLUXROOT (e.g. C:\Research_Flux_Towers): ' ], ...
                      's' );
    if ( exist( FLUXROOT ) ~= 7 )
        disp( sprintf( '%s is not a valid directory.\n', FLUXROOT ) );
        FLUXROOT = '';
    end
end

sitefolder = fullfile(FLUXROOT, 'Flux_Tower_Data_by_Site');
outfolder = fullfile(FLUXROOT, 'FluxOut');

fluxrc = struct('site_names', {site_names}, ...
                'FLUXROOT', FLUXROOT, ...
                'sitefolder', sitefolder, ...
                'outfolder', outfolder);


