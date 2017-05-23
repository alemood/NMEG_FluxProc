function success = update_eddypro_proj_file( proj_file , ...
                                             raw_data_dir , ... 
                                             irga_type, ...
                                             ep_vers )
                                             
% UPDATE_EDDYPRO_PROJ_FILE - updates specific lines in an eddypro project
% file 
%
%
% USAGE:
%    update_eddypro_proj_file( ep_proj_path, raw_data_dir, irga_type )
%
% INPUTS
%    proj_file: string; the full path of the project file to be updated.
%    raw_data_dir: the full path to the directory containing the raw card
%        data
%    irga_type: open or closed path
%
% OUTPUTS
%    success: 1 on success, 0 on failure
%
%   Alex Moody, UNM , 2017

% Locations of variables in the project files change with software version
success = 0;

switch ep_vers
    case '6.1.0'
        raw_data_ln = 130;
        day_start_ln =    45;
        hr_start_ln =     46;
        day_end_ln =    47;
        hr_end_ln =     48;
    case '6.2.0'
        raw_data_ln = 129;
        day_start_ln =    46;
        hr_start_ln =     47;
        day_end_ln =    48;
        hr_end_ln =     49;
end

A = regexp( fileread( proj_file ), '\n', 'split');      %Read in proj file
A = A(1:numel(A)-1);                                    %Remove empty line
A = regexprep(A,'\r\n|\n|\r','');                       %Remove carriage returns
A{raw_data_ln} = sprintf('data_path=%s',raw_data_dir);  %Raw data directory
A = regexprep(A,'\\','\/');                             %Eddypro wants forward slashes


% Update project start and end dates with cdp date_start and date_end
A{ day_start_ln }  = sprintf('%s',['pr_start_date=',datestr(t_start,'yyyy-mm-dd')]);
A{ hr_start_ln }  = sprintf('%s',['pr_start_time=',datestr(t_start,'HH:00')]);
A{ day_end_ln }  = sprintf('%s',['pr_end_date=',datestr(t_end,'yyyy-mm-dd')]);
A{ hr_end_ln }  = sprintf('%s',['pr_end_time=',datestr(t_end,'HH:00')]);

% Write new proj file
fid = fopen(eddypro_proj, 'w');                        
fprintf(fid, '%s\n', A{:});
fclose(fid)

success = 1;
