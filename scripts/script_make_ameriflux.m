%close all;
%clear all;
%
% sitelist = {UNM_sites.MCon, UNM_sites.JSav, UNM_sites.PJ, UNM_sites.PJ_girdle, ...
%     UNM_sites.SLand, UNM_sites.GLand, UNM_sites.PPine, UNM_sites.New_GLand};

%sitelist={UNM_sites.New_GLand};
% Years to create files for
%yearlist = 2008:2014;
% Partitioned data source
partmethod = 'eddyproc' ;%; %'eddyproc'
% Make daily files? All AF files should be in $FLUXROOT$/Ameriflux_files
make_daily = false;
write_files = true;
process_soil = false;
version = 'in_house';  %'in_house';  
showfig = true;

if ~showfig
    set(0,'DefaultFigureVisible','off');
end

%for k = 5
 for k = 5:5;
    switch k
        case 1
            sitelist = { UNM_sites.JSav, ...
                UNM_sites.SLand, UNM_sites.GLand, ...
                UNM_sites.PPine, UNM_sites.MCon};
            yearlist = 2007:2015;
        case 2
             sitelist = { UNM_sites.PJ }
            yearlist = 2008:2015;
        case 3
              sitelist = {  UNM_sites.PJ_girdle...
                UNM_sites.New_GLand }
            yearlist = 2010:2015;
        case 4
            sitelist =  {UNM_sites.JSav, UNM_sites.PJ, UNM_sites.PJ_girdle,...
                UNM_sites.SLand, UNM_sites.GLand, UNM_sites.New_GLand, ...
                UNM_sites.PPine, UNM_sites.MCon, UNM_sites.MCon_SS};
            yearlist = 2016;
            partmethod = 'Reddyproc';
        case 5
            sitelist = {UNM_sites.JSav, UNM_sites.PJ, UNM_sites.PJ_girdle,...
                UNM_sites.SLand, UNM_sites.GLand, UNM_sites.New_GLand};
            yearlist = 2016;
             
    end            

for i = 1:length(sitelist);
    %close all;
    for j = 1:length(yearlist);
        % Set site and year
        sitecode = sitelist{i};
        year = yearlist(j);
        
        if strcmp(partmethod, 'old_eddyproc');
        
            UNM_Ameriflux_File_Maker( sitecode, year, ...
                'write_files', write_files, ...
                'write_daily_file', make_daily, ...
                'process_soil_data', process_soil,...
                'version', version , ...
                'gf_part_source', partmethod);
            
        elseif strcmp( partmethod , 'eddyproc')
              UNM_Ameriflux_File_Maker( sitecode, year, ...
                'write_files', write_files, ...
                'write_daily_file', make_daily, ...
                'process_soil_data', process_soil,...
                'version', version );
                
        elseif strcmp(partmethod, 'Reddyproc');
            %error( ' not implemented yet ' );
            UNM_Ameriflux_File_Maker(sitecode, year,...
                'write_daily_file', make_daily, ...
                'write_files', write_files, ...
                'process_soil_data', process_soil, ...
                'gf_part_source', 'Reddyproc');
            
        end
        
        % New files go into FLUXROOT - look at the file you made
        %UNM_Ameriflux_Data_Viewer( sitecode, year, 'AFlux_dir',...
        %    fullfile(getenv('FLUXROOT'), 'FluxOut' ));
        %clear year;
    end
   
    close all;
    clear sitecode;
end

end

set(0,'DefaultFigureVisible','on')
