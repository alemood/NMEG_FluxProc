function success = transfer_2_glacier(site, compressed_data_fname)
% TRANSFER_2_GLACIER- transfer compressed tower raw data to Amazon Glacier  
%
% glacier-put account[:password] local-file region-code vault/folder
%  ---------------------------------------------------------------------------
% 
%  Where:
% 
%   account - account name you specified when adding an account using gui wizard
%   password - optional password to decrypt account credentials (master password)
%   local-file - path to the file or directory on your disk (wildcards allowed)
%   region-code - amazon glacier region code, supported regions are: 
% 
%     [region name]                        [region code]
% 
%      US East (N. Virginia)                 us-east-1
%      US East (Ohio)                        us-east-2
%      US West (N. California)               us-west-1
%      US West (Oregon)                      us-west-2
%      Canada (Central)                   ca-central-1
%      EU (Ireland)                          eu-west-1
%      EU (London)                           eu-west-2
%      EU (Frankfurt)                     eu-central-1
%      Asia Pacific (Tokyo)             ap-northeast-1
%      Asia Pacific (Sydney)            ap-southeast-2
%      Asia Pacific (Seoul)             ap-northeast-2
%      Asia Pacific (Mumbai)                ap-south-1
% 
%   vault/folder - amazon glacier vault name and folder
% 
% 
%  Examples:
% 
%   glacier-put my-account c:\backup us-east-1 my-vault/backups
%   glacier-put my-account c:\backup\*.bkf eu-west-1 my-vault
%   glacier-put my-account "e:\my videos" eu-west-1 "vault-3/my videos"
%   glacier-put encrypted-account:85sd4df F:\Docs eu-west-1 Vault-4/Docs
%  
%  If spaces appear in the path, enclose it in quotation marks.
%  Do not use traling backslash.
%
% USAGE
%    success = transfer_2_glacier(site, compressed_data_fname)
%
% INPUTS
%    site: integer code or UNM_sites object; site to process
%    compressed_data_fname: the full *cygwin* path of the compressed data file
%
% OUTPUTS
%    success: 0 on successful transfer, non-zero otherwise
%
% author: Alex Moody, UNM, 2017

site = UNM_sites( site );

success = -1; %initialize    

% Path to FASTGLACIER upload executable

glacier_uploader_path = fullfile('C:','"Program Files"','FastGlacier','glacier-put.exe');

[fpath, fname, fext] = fileparts(compressed_data_fname);


 blk_fname = create_blocking_file( [ 'blocking file for %s zipped data ' ...
                     'transfer --> Glacier' ] );

% run the transfer in a dos window
cmd = sprintf('%s %s %s %s %s',...
glacier_uploader_path,... 
'LitvakLab',...% my-account
compressed_data_fname ,...% local compressed file
'us-east-1',...% region
char(site));% vault path on glacier


cmd = sprintf( '%s & del %s &', cmd, blk_fname );

[s, r] = dos(cmd);

% do not proceed until "blocking" file is removed; check every 5 seconds
pause on;
while( exist( blk_fname ) == 2 )
    pause( 5 );
end
pause off

% % need to implement some sort of blocking scheme here to make Matlab wait
% % until compression is done.  This will work, but requires a click when
% % compression is complete.
% h = warndlg('press OK when file transfer is complete', 'transfering file');
% waitfor(h);


success = 0;