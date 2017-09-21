%close all;
%clear all;

sitelist = {UNM_sites.GLand, UNM_sites.SLand, UNM_sites.New_GLand...
    UNM_sites.JSav, UNM_sites.PJ , UNM_sites.PJ_girdle, ...
    UNM_sites.PPine, UNM_sites.MCon , UNM_sites.MCon_SS};
sitelist = { UNM_sites.SLand};%, ...
    %UNM_sites.SLand};
yearlist = 2017;%2007:2015;%2013:2014;% 2009:2013;
write_qc = false;
write_rbd = false;
showfig = true;


count = 1;
for i = 1:length(sitelist);
    for j = 1:length(yearlist)
        % Set site and year
        sitecode = sitelist{i};
        year = yearlist(j);
        try
        soil_corr = soil_met_correct( sitecode, ...
            year,...
            write_qc,...
            write_rbd,...
            showfig);
        catch err
            rethrow( err );
        end
    
        count = count + 1;
        %close all;
    end
end
 set(0,'DefaultFigureVisible','on');
