function success = transfer_2_glacier(site, compressed_data_fname)
% TRANSFER_2_GLACIER- transfer compressed tower raw data to Amazon Glacier  
%
% Places data into
% edacdata1.unm.edu:/data/epscor/private/data/Upland_node/SITE/Raw/, with SITE
% the abbreviated name of the UNM site.  Requires user to enter the password for
% user jdelong on edacdata1.unm.edu.  
%
% Following UNIX convention nothing is echoed to the display while the password
% is typed (no ****, ....., etc.).
%
% NOTES
% (1) Requires Cygwin's sftp (secure file transfer protocol) to be available on
% the system.  See http://www.cygwin.com/.%
% (2) Spawns a Windows command prompt window.  This window will not close
% automatically when the transfer is complete.  It will display a message
% when the user may close the window.% 
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

glacier_uploader_path = fullfile('C:','Program Files','glacieruploader-0.1.0\glacieruploader-impl\target');


[fpath, fname, fext] = fileparts(compressed_data_fname);


%write an sftp script to a temporary file
calling_dir = pwd();
cd(glacier_uploader_path);
glacier_script_file = tempname(getenv('TMP'));
fid = fopen(glacier_script_file, 'w+');
fprintf(fid, ['\n\n#Transfering compressed raw data to edacdata1.unm.edu.  ' ...
              'This will likely take a few minutes.  sftp will likely say it ' ...
              'is stalled at least once -- please ignore these messages.\n\n']);
fprintf(fid, 'cd %s\n', glacier_uploader_path);
%fprintf(fid, 'progress\n');  %enable SFTP progress updates
%fprintf(fid, sprintf( 'put %s\n', unixpath ) );
fprintf(fid, ['\n\n#This DOS window will not close by itself -- you may ' ...
              'close it now by typing ''exit'' at the prompt.\n']);
fclose(fid);

 blk_fname = create_blocking_file( [ 'blocking file for %s zipped data ' ...
                     'transfer --> Glacier' ] );

% run the transfer in a dos window

cmd = sprintf(['java -jar glacieruploader-impl-0.1.0-jar-with-dependencies.jar ', ...
              '--vault %s ', ...
              '--multipartupload %s ',...
              '--partsize 16777216'],...
              char( site ), compressed_data_fname );
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

%remove the sftp script
 delete(glacier_script_file);

%change matlab back to the original directory
cd(calling_dir);

success = 0;