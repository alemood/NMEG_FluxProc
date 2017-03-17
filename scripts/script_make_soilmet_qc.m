%close all;
%clear all;

sitelist = {UNM_sites.GLand, UNM_sites.SLand, ...
    UNM_sites.JSav, UNM_sites.PPine, ...
    UNM_sites.MCon};
sitelist = { UNM_sites.PJ_girdle , UNM_sites.PJ };%, ...
    %UNM_sites.SLand};
yearlist = 2009:2016;%2007:2015;%2013:2014;% 2009:2013;
write_qc = true;
write_rbd = true;
showfig = false;

if ~showfig
    set(0,'DefaultFigureVisible','off'); 
end
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
        catch
        end
    
        count = count + 1;
        close all;
    end
end
 set(0,'DefaultFigureVisible','on');
