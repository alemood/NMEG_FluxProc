function remote_site_dir = harvest_sftp( sitecode ,  varargin )
%
% HARVEST_SFTP - Downloads NMEG data from the Socorro SFTP. This intended
% for processing purposes only right now (17 Nov 16) since I have not
% placed in options to omit certain files in the case of querying for site
% checks. Unless you don't mind waiting for the 10hz data to download.
% 
% USAGE
%   success = harvest_sftp( sitecode, date_start, date_end ,  )
%
% INPUTS
%   site: site name *string* -- e.g. UNM_sites.GLand
%   date_start: matlab datenum
%
% OPTIONAL INPUTS
%   date_end: matlab datenum 
%
% OUTPUTS
%   success 
%
% 
% author: Alex C Moody, 2016, UNM
% -----
% parse and typecheck inputs
p = inputParser;
p.addRequired( 'sitecode', @(x) ( isintval(x) | isa( x, 'UNM_sites' )));
p.addParameter( 'date_start', datenum([2006, 12 ,31]), @isnumeric);
p.addParameter( 'date_end', now, @isnumeric );
p.parse( sitecode, varargin{ : } );
sitecode = p.Results.sitecode;
first_mod_date = p.Results.date_start;
last_mod_date = p.Results.date_end;

harvest_success = 1;

conf = parse_yaml_config( sitecode, 'Dataloggers',...
     [ first_mod_date, last_mod_date ] );
conf = struct2table(conf.dataloggers);

remote_site_dir = ['/net/ladron/export/db/work/wireless/nmufn/',...
    strrep(lower(char( UNM_sites(sitecode))),'_','')];...

%--------
% Switch site prefix on SFTP. VC sites have VCNP prefix
if  regexpi(char(UNM_sites(sitecode)),'PPine|MCon') == 1
    site_prefix ='/NMUFN_VCNP_' ;
else
    site_prefix = '/NMUFN_' ;
end
 
loggers = {conf.make};
addpath(genpath('A:\Code\NMEG_HarvestSftp'));
cd('A:\Code\NMEG_HarvestSftp')
for i = 1:numel(loggers)
    fmts = char(conf(i,:).conv_file_fmt);
    fmts = strsplit(fmts,{',',' '});
    %FIXME - add an option to omit certain file names? Could be useful if
    %we are just trying to plot diagnostics on flux data.
    for j = 1:numel(fmts)
        fmt = char(fmts(j));
        switch fmt
            case 'TOA5' 
                remote_file = [site_prefix,...
                    upper(strrep(char( UNM_sites( sitecode )),'_','')),...
                    '_',char(conf(i,:).make),'_flux.dat'];
            case 'TOB1'
                remote_file = [site_prefix,...
                    upper(char( UNM_sites( sitecode ))),...
                    '_',char(conf(i,:).make),'_ts_data.dat'];
            case 'CR23X'
                remote_file = [site_prefix,...
                    upper(char( UNM_sites( sitecode ))),...
                    '_',char(conf(i,:).make),'_1.dat'];    
        end
        % DOWNLOAD FROM SFTP
        
        ssh2_conn = scp_simple_get('socorro.unm.edu', 'eddyflux','ravafru8',... %Server info
            [remote_site_dir,remote_file],...                                   % File to retrieve
            fullfile( getenv('FLUXROOT'),'SiteData',char(UNM_sites(sitecode)),'wireless_data')); %Destination
    end
    rmpath(genpath('A:\Code\NMEG_HarvestSftp'))
    cd('A:\Code\NMEG_fluxproc')
end


