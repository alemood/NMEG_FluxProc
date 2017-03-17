%close all;
%clear all;

sitelist = {UNM_sites.GLand, UNM_sites.SLand, UNM_sites.New_GLand ...
    UNM_sites.JSav,  ...
    UNM_sites.PPine, UNM_sites.MCon, UNM_sites.MCon_SS };
%sitelist = { UNM_sites.GLand };%, ...
    %UNM_sites.SLand};J
    sitelist = { UNM_sites.PJ_girdle };
yearlist = 2015:2015;%:2015;%2007:2015;%2013:2014;% 2009:2013;
write_qc = false;
write_rbd = false;
showfig = true;

if ~showfig
    set(0,'DefaultFigureVisible','off'); 
end
count = 1;
for i = 1:length(sitelist);
    for j = 1:length(yearlist)
        % Set site and year
        sitecode = sitelist{i};
        year = yearlist(j);
        soil_corr = soil_met_correct( sitecode, year, write_qc, write_rbd );
    
        count = count + 1;
        close all;
    end
end
 set(0,'DefaultFigureVisible','on');