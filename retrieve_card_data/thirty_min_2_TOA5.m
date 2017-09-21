function [success, toa5_fname] = thirty_min_2_TOA5(site, raw_data_dir, varargin)
% THIRTY_MIN_2_TOA5 - convert a thirty minute datalogger file (*.flux.dat) to a
% TOA5 file in the appropriate directory.
%
% Places the TOA5 file in the toa5 subdirectory of the output of get_site_dir().
% The thirty-minute data file to be converted must be named in the format
% *.flux.dat.  Issues an error if there is not exactly one file in raw_data_dir
% matching *.flux.dat.
%
% USAGE
%    [success, toa5_fname] = thirty_min_2_TOA5(site, raw_data_dir);
%
% INPUTS
%    site: integer or UNM_sites object; the site whose data are to be
%        processed
%    raw_data_dir: string; full path to the directory containing the raw
%        datalogger data files.
%
% OUTPUTS
%    success: logical; true if conversion successful, false otherwise.
%    toa5_fname: string; full path of the new TOA5 file.
%
% (c) Timothy W. Hilton, UNM, Oct 2012
% Rewritten by Gregory E. Maurer, UNM, March 2015
args = inputParser
args.addRequired( 'site', @(x) ( isintval( x ) | isa( x, 'UNM_sites' ) ) );
args.addRequired( 'raw_data_dir' , @ischar )
args.addParameter( 'logger_name' , 'flux' , @ischar )
args.addParameter( 'data_location', 'card', @ischar )

args.parse( site , raw_data_dir, varargin{ : } );
site = args.Results.site;
raw_data_dir = args.Results.raw_data_dir;
logger_name = args.Results.logger_name;
data_location = args.Results.data_location;

site = UNM_sites( site );

success = true;

if strcmpi( logger_name, 'flux' )
    thirty_min_file = dir(fullfile(raw_data_dir, '*.flux.dat'));
    ts_data_file = dir(fullfile(raw_data_dir, '*.ts_data*'));
    % Directory to put new TOA5 files in
    toa5_data_dir = fullfile(get_site_directory( site ), 'toa5');
else
    conf = ...
        parse_yaml_config( site ,'Dataloggers',...
        'date_range',[datenum(2007,1,1);now]);
    idx = ...
        find( cellfun( @(x) ~isempty(x),regexp( ...
        {conf.dataloggers.name}, logger_name ) ) );
    logger_id = conf.dataloggers(idx).ID;
    
    thirty_min_file = dir( fullfile( raw_data_dir , sprintf('%d*.dat' , logger_id)));
    % Still need this to pass the 10hz data
    ts_data_file = dir(fullfile(raw_data_dir, '*.ts_data*'));
    % Directory to put new TOA5 files in
    toa5_data_dir = fullfile(get_site_directory( site ),...
        'secondary_loggers',...
        logger_name);
end



if isempty(thirty_min_file)
    error('There is no thirty-minute data file in the given directory');
elseif length(thirty_min_file) > 1
    error('There are multiple thirty-minute data files in the given directory');
else
    %create a temporary directory for the TOA5 output
    output_temp_dir = tempname();
    mkdir(output_temp_dir);
    
    %create the configuration file and command string for CardConvert
    toa5_ccf_file = tempname();
    ccf_success = build_TOA5_card_convert_ccf_file(toa5_ccf_file, ...
        raw_data_dir, ...
        output_temp_dir);
    card_convert_exe = fullfile('C:', 'Program Files (x86)', 'Campbellsci', ...
        'CardConvert', 'CardConvert.exe');
    card_convert_cmd = sprintf('"%s" "runfile=%s"', ...
        card_convert_exe, ...
        toa5_ccf_file);
    
    if not( isempty( ts_data_file ) ) & strcmpi( logger_name, 'flux')
        % card convert will try to apply the ccf file to every .dat file in
        % the directory.  We want to use a different ccf file for the TS
        % data, so temporarily change the .dat extension so CardConvert will
        % ignore it for now.
        ts_file_ignore = {};
        ts_file_fullpath = {};
        for i = 1:length( ts_data_file )
            ts_file_ignore{i} = fullfile(raw_data_dir, ...
                strrep(ts_data_file(i).name, '.dat', '.donotconvert'));
            sprintf('%s --> %s\n', ...
                fullfile( raw_data_dir, ts_data_file(i).name ), ...
                ts_file_ignore{i});
            ts_file_fullpath{i} = fullfile( raw_data_dir, ...
                ts_data_file(i).name );
            % matlab's movefile takes minutes to rename a 2 GB ts data
            % file. The java method does it instantly though
            move_success = ...
                java.io.File(ts_file_fullpath{i}).renameTo(...
                java.io.File(ts_file_ignore{i}));
            success = success & move_success;
            if not(move_success)
                error('thirty_min_2_TOA5:rename_fail', ...
                    'renaming TS data file failed');
            end
        end
    end
    
    % check to see if this is coming off a card. Wireless is already
    % converted
    if strcmpi(data_location,'card')
        % run CardConvert
        [convert_status, result] = system(card_convert_cmd);
        success = success & (convert_status == 0);
        if convert_status ~= 0
            error('thirty_min_2_TOA5:CardConvert', 'CardConvert failed');
        end
    end
    
    if not( isempty( ts_data_file ) )
        %restore the .dat extension on the TS data file
        for j = 1:length( ts_data_file )
            move_success = ...
                java.io.File(ts_file_ignore{j}).renameTo(...
                java.io.File(ts_file_fullpath{j}));
            success = success & move_success;
            if not(move_success)
                error('thirty_min_2_TOA5:rename_fail',...
                    'restoring TS data .dat extension failed');
            end
        end
    end
    % =====================================================================
    % RENAME TOA5 FILE
    % =====================================================================
    % rename the TOA5 file according to the site and place it in the
    % site's TOA5 directory. Use the secondary data logger ID to help with 
    % renaming secondary loggers into less convoluted names.
    default_root = sprintf('TOA5_%s',...
        char(regexp(thirty_min_file.name, ...
        '.*\.flux', 'match')));
    default_name = dir(fullfile(output_temp_dir, [default_root, '*']));
    % Check to see if the logger is a flux logger or secondary logger
    if strcmpi( logger_name, 'flux')
        newname = strrep(default_name.name, ...
            default_root, ...
            sprintf('TOA5_%s', char(site)));   
    elseif ~strcmpi( logger_name, 'flux')
        newname = ...
            sprintf('TOA5_%s_%s_%s.dat',site,logger_name,...
            char(regexp(default_name.name,'\d\d\d\d_\d\d_\d\d','match') ) );
    end
    
    default_fullpath = fullfile(output_temp_dir, default_name.name);
    newname_fullpath = fullfile(toa5_data_dir, newname);
    
    
    if exist(newname_fullpath) == 2
        % if file already exists, overwrite it
        delete(newname_fullpath);
    end
    
    
    fprintf( '%s --> %s\n', default_fullpath, newname_fullpath );
    
    move_success = ...
        java.io.File(default_fullpath).renameTo(java.io.File(newname_fullpath));
    success = move_success & success;
    if not(move_success)
        error('thirty_min_2_TOA5:rename_fail',...
            'moving TOA5 file to TOA5 directory failed');
    end
    
    %remove the temporary output directory & CardConvert ccf file
    [rm_success, msgid, msg] = rmdir(output_temp_dir);
    success = rm_success & success;
    %remove the ccf file
    delete(toa5_ccf_file);  %delete seems not to return an output status
end
toa5_fname = newname_fullpath;
