%close all;
%clear all;
%
%  sitelist = {UNM_sites.MCon_SS,UNM_sites.MCon, UNM_sites.JSav, UNM_sites.PJ, UNM_sites.PJ_girdle, ...
%      UNM_sites.SLand, UNM_sites.GLand, UNM_sites.PPine, UNM_sites.New_GLand};
% 
% sitelist={UNM_sites.GLand};
% % Years to create files for
% yearlist = 2007;
% % Partitioned data source
% % eddyproc - This uses DatasetafterfluxpartMRGL_year.txt, which is the
% % output of the online tool as of ~ the beginning of 2017
% partmethod = 'old_eddyproc' ;%; %'Reddyproc' 'old_eddyproc'
% Make daily files? All AF files should be in $FLUXROOT$/Ameriflux_files
make_daily = false;
write_files = true;
process_soil = false;
version = 'NMEG'; %'aflx';  % 
showfig = true;

if ~showfig
    set(0,'DefaultFigureVisible','off');
end

flags = [];
count = 1;
for k =3
    switch k
        case 1
            sitelist = { UNM_sites.GLand, UNM_sites.SLand, UNM_sites.New_GLand ,...
                UNM_sites.JSav, UNM_sites.PJ, UNM_sites.PJ_girdle ,...
                UNM_sites.PPine, UNM_sites.MCon, UNM_sites.MCon_SS };
            yearlist = 2007:2013;
            partmethod = 'eddyproc';
        case 2
            sitelist = { UNM_sites.MCon};
            yearlist =[2013];
            partmethod ='old_eddyproc';
        case 3
            sitelist = {UNM_sites.New_GLand};
            yearlist = 2016;
            partmethod ='eddyproc';
        case 4
            sitelist = {UNM_sites.PJ_girdle};
            yearlist = [2009,2010,2012];
            partmethod ='eddyproc';
        case 5
            sitelist = {UNM_sites.PJ};
            yearlist = [2007,2011];
            partmethod ='eddyproc';
        case 6
            sitelist = {UNM_sites.JSav};
            yearlist = [2007];
            partmethod ='eddyproc';
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
           try
              UNM_Ameriflux_File_Maker( sitecode, year, ...   UNM_sites.SLand, UNM_sites.GLand, UNM_sites.PPine
                'write_files', write_files, ...
                'write_daily_file', make_daily, ...
                'process_soil_data', process_soil,...
                'version', version );
            catch err
                flags{count}=sprintf('~~~~ %s-%d failed!! ~~~~\n',sitecode,year);
                count = count+1;
                disp( getReport( err ) );
            end
                
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
   
   % close all;
    clear sitecode;
end

end

set(0,'DefaultFigureVisible','on')
