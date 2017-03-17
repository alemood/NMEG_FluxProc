%close all;
%clear all;

%sitelist = {UNM_sites.SLand, UNM_sites.JSav, UNM_sites.PJ_girdle,...
%    UNM_sites.GLand,UNM_sites.New_GLand, UNM_sites.MCon, UNM_sites.PJ,...
%    UNM_sites.PPine};
sitelist = {UNM_sites.MCon, UNM_sites.SLand, UNM_sites.JSav, ...
    UNM_sites.GLand, UNM_sites.PPine, UNM_sites.PJ_girdle, UNM_sites.PJ, ...
    UNM_sites.PJ_girdle};

yearlist = 2016; %2013:2014;% 2009:2013;

process_data = true;

count = 1;
for i = 1:length(sitelist);
    for j = 1:length(yearlist)
        % Set site and year
        sitecode = sitelist{i};
        year = yearlist(j);
               
        if process_data
            % Start and end dates for making a new fluxall file
            date_start = datenum(year, 1, 1, 0, 0, 0);
            % end at 23:30 when processing tob data (not quite sure why)
            % half hour later other times
            date_end = datenum(year, 8, 5, 0 , 00, 0);
            
            % Create a new cdp object.
            % Leave 'data_10hz_already_processed' false.
            new = kernel_regression_processor(sitecode, 'date_start', date_start,...
                'date_end', date_end);
            
        
            
            % Fill in 30min and 10hz data
            new = new.get_30min_data();
            new = new.process_10hz_data(); % This takes a long time
        end
        
        % Create a new cdp object using correct start dates and set
        % 'data_10hz_already_processed' to true.
        date_start = datenum(year, 1, 0, 0, 0, 0);
        date_end = datenum(year, 12,  31, 23, 30, 0);
        
        new = card_data_processor(sitecode, 'date_start', date_start,...
            'date_end', date_end, 'data_10hz_already_processed', true,...
            'data_eddypro_already_processed',true);
        
      
        count = count + 1;
    end
end
