function success = copy_uncompressed_TOB_files(site, tsdata_filenames)
% COPY_UNCOMPRESSED_TOB_FILES - Copies uncompressed 10-hz TOB1 files to
% MyBook or Redondito drive.
%
% Copies uncompressed 10-hz TOB1 files from arbitrary directory to
% "TOB1_TS_DATA_ARCHIVES\SITE" directory on MyBook drive (with SITE the
% abbreviated site name).
%
% My Book has TOB1 files before 2016. Redondito, another WD MY Book drive,
% will hold 2016 and on
%
% Returns true on success.  Issues error on failure.
%
% USAGE
%    success = copy_uncompressed_TOB_files(site, raw_data_dir);
%
% INPUTS
%    site: integer or UNM_sites object; the site whose data are to be copied,
%        used to choose the destination directory on MyBook.
%    tsdata_filenames: cell array of strings; full paths of TOB1 files to
%        copy.
%
% OUTPUTS
%    success: true if all files copied successfully.
%
% (c) Timothy W. Hilton, UNM, Oct 2011
% Updated in 2017 by Alex Moody

site = UNM_sites( site );

success = true;

mybook_letter = locate_drive( 'redondito' );
dest_dir = fullfile( sprintf('%c:', mybook_letter), ...
                     'raw_flux_data', ...
                     char( site ) ,'ts_data');

for i=1:length(tsdata_filenames)
    fprintf(1, '%s --> %s\n', tsdata_filenames{i}, dest_dir);
    [copy_success, msg, msgid] = copyfile(tsdata_filenames{i}, dest_dir);
    success = success & copy_success;
    if not(success)
        error(msgid, msg);
    end
end
    
            

    