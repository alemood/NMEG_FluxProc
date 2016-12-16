%close all;
%clear all;

%sitelist = {UNM_sites.SLand, UNM_sites.JSav, UNM_sites.PJ_girdle,...
%    UNM_sites.GLand,UNM_sites.New_GLand, UNM_sites.MCon, UNM_sites.PJ,...
%    UNM_sites.PPine};

 sitelist = {UNM_sites.GLand};
yearlist = 2016;

proc_10hz = true;
count = 1;

for i = 1:length(sitelist);   
        % Set site and year
        sitecode = sitelist{i};
        
        year = yearlist
        process_10hz = proc_10hz; %proc_10hz(count);
        
        % Fix the resolution file if needed
        % generate_header_resolution_file;
        
        if process_10hz
            % Start and end dates for making a new fluxall file
            date_start = datenum(year, 1, 1, 0, 0, 0);
            % end at 23:30 when processing tob data (not quite sure why)
            % half hour later other times
            date_end = datenum(year, 7, 31, 24, 0, 0);
        
            new = card_data_processor(sitecode, 'date_start', date_start,...
                'date_end', date_end); 
          
            % Fill in 30min and 10hz data
            fprintf('------------Processing in Eddypro------------')
            try
                new = new.process_10hz_eddypro(); % This takes a long time
            catch err
                warning('%s failed to process in Eddypro',char(sitecode{i}))
            end
        end    
        count = count + 1;
end

