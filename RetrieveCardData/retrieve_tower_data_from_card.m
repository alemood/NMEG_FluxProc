function [result, dest_dir, mod_date] = retrieve_tower_data_from_card(site)
% RETRIEVE_TOWER_DATA_FROM_CARD - retrieves tower data from card, processes to
%   TOA5 and TOB1 files, puts data into appropriate storage locations

    result = 1;
    
    site_dir = get_site_directory(get_site_code(site));
    compact_flash_drive = locate_drive( 'Removable Disk' );
    %% would like a more flexible way to 
    compact_flash_drive = 'g'; 
    tower_files = dir( fullfile( sprintf( '%c:', compact_flash_drive ), ...
                                 '*.dat'));
    
    fprintf(1, 'processing tower data files: ');
    fprintf(1, '%s ', tower_files.name);
    fprintf(1, '\n');

    for i = 1:length(tower_files)
        src = fullfile( sprintf( '%c:', compact_flash_drive ), ...
                       tower_files( i ).name );
        mod_date = datenum(tower_files(i).date); %modification date for the
                                                 %data file

        %create directory for files if it doesn't already exist
        dest_dir = get_local_raw_data_dir(site, mod_date);
        if exist(dest_dir) ~= 7
            %     % if directory already exists, throw an error
            %     %error('retrieve_tower_data_from_card:destination error', ...
            %     error(sprintf('%s already exists', dest_dir));
            [mkdir_success, msg, msgid] = mkdir(dest_dir);
            result = result & mkdir_success;
            if mkdir_success
                sprintf('created %s', dest_dir);
            else
                error(msgid, msg);
                result = mkdir_success;
            end
        end
        
        fprintf('%s --> %s...', src, dest_dir);
        [copy_success, msgid, msg] = copyfile(src, dest_dir);
        result = result & copy_success;
        if copy_success
            fprintf('done\n');
        else
            fprintf('\n');
            error(msgid, msg);
        end
    end
        
    
    
    
    