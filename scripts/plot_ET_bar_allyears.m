% LE_2_ET - Convert 30min latent heat flux to ET ( W/m^2 to mm/s ) and sum (integrate)
%     for each 30min period. Note that this method uses the full day of ET,
%     rather than just daytime values

setenv('AFLX','C:\Code\NMEG_utils\processed_data\daily_aflx\FLUXNET2015_c');
% Ameriflux sitelist 
sitelist={'Seg', 'Ses', 'Wjs', 'Mpj' , 'Vcp' ,'Vcm'};
yearlist=( 2007:2016 );
convert2mm = false; % I believe the Keenan uncertainty files are in mm already.
if exist('all_data')
load_data = false;
else
    load_data = true;
end

if load_data 
% ------------- LOAD FILES------------------
all_data = struct('site',sitelist,'data',[]);
for i = 1:length(sitelist)    
    site = all_data(i).site;
    % Now ameriflux files
    fname= fullfile( getenv('AFLX'),strcat('US-',site,'_daily_aflx.csv') );
    data = parse_aflx_daily_file(fname);
    % Add Water year timestamp
    [data.wyear , data.wyDOY] = ts2wateryear(data.TIMESTAMP);
    % Put this in a structure of all data
    all_data(i).data = data;
end
end

% Get yearly site ET and PPT
yearlist = 2006:2016;
meanET_t = array2table(yearlist','VariableNames',{'wyear'});
meanP_t =  array2table(yearlist','VariableNames',{'wyear'});
meanETSE_t = array2table(yearlist','VariableNames',{'wyear'});
meanPSE_t = array2table(yearlist','VariableNames',{'wyear'});
%%
for i = 1:length(sitelist)
    
    site = all_data{i,1};
    data = all_data{i,2};
    
    % Calculate yearly means
    [uniqueYears,idxToUnique,idxFromUniqueBackToAll] = unique(data.hydroyear);
    yearlyMeanET = horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.ET_mm_dayint,[],@nanmean));
    yearlyMeanET = array2table(yearlyMeanET,'VariableNames',{'wyear',site});
    meanET_t = outerjoin(meanET_t,yearlyMeanET,'MergeKeys',true);
    

    yearlyMeanP =  horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.PRECIP,[],@nanmean) );
    yearlyMeanP =  array2table(yearlyMeanP,'VariableNames',{'wyear',site});
    meanP_t = outerjoin(meanP_t,yearlyMeanP,'MergeKeys',true)   ;
    
    % Calculate yearly mean SE
    yearlyMeanETSE = horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.ET_mm_dayint,[],@nanstd));
    yearlyMeanETSE = array2table(yearlyMeanETSE,'VariableNames',{'wyear',site});
    meanETSE_t = outerjoin(meanETSE_t,yearlyMeanETSE,'MergeKeys',true);
    
    yearlyMeanPSE =  horzcat(uniqueYears ,accumarray(idxFromUniqueBackToAll,data.PRECIP,[],@nanstd) );
    yearlyMeanPSE =  array2table(yearlyMeanPSE,'VariableNames',{'wyear',site});
    meanPSE_t = outerjoin(meanPSE_t,yearlyMeanPSE,'MergeKeys',true)   ;
end

ETPratio = [  meanET_t{:,2:end}./meanP_t{:,2:end}];
ETPratio = array2table(ETPratio,'VariableNames',sitelist,'RowNames',cellstr(num2str(yearlist'))) 

%%
% We only have a partial (272/365 days)  water year for 2006. Scale by
% portion of the year?


c = categorical(meanP_t.Properties.VariableNames(2:end));
for i = 2: length(yearlist - 1) % To exlude 2006 and 2016, incomplete wate years
   
    year = meanP_t{i,1};
   
    P = meanP_t{ i , 2: end }';
    Perr = meanPSE_t{ i , 2: end }';
    ET = meanET_t{ i , 2: end }';
    ETerr = meanETSE_t{ i , 2: end }';
    
    y = [ET, P ]; 
    errY = [ETerr,Perr];          
    
    %figure; hold on
    %[bar1 barerr] = barwitherr(errY, y);% Plot with errorbars 
    bar1 = bar( y );
    set(gca,'XTickLabel',sitelist)
    set(gca,'YLim',[0 2.5])
    set(bar1(1),'FaceColor',[224/255 194/255 85/255],'DisplayName','ET')
    set(bar1(2),'FaceColor',[23/255 162/255 209/255],'DisplayName','P');
   
    title(sprintf('WY %d', year))
    ylabel('Mean Annual ET or P (mm d^{-1})')
    legend('ET','P','Location','northwest') 
    
    destfile = fullfile(getenv('FLUXROOT'),'Plots',...
        'NMWRRI_ET',sprintf('MeanAnnualETP_%d',year));
  %  saveas( gcf , destfile, 'png')
    %hold off
end

% ----------- Mean annual ET/P ratio
ETPratio = [  meanET_t{2:9,2:end}./meanP_t{2:9,2:end}];

gcolour=[0.9,0.5,0.0];
ngcolour= [0.9, 0.8, 0.0];
scolour=[0.6, 0.2, 0];
jcolour=[0.25, 1.0, 0.0];
pjcolour=[0.0, 0.5, 0.0];
pjgcolour=[0.0, 0.85, 0.0];
pcolour=[0.5, 0.5, 1.0];
mcolour=[0.0, 0.0, 0.6];
nmcolour=[0.3, 0.0, 0.5];

figure2 = figure('Position',[1 550 1906 525]);
bar2 = bar(ETPratio);
set(gca,'XTickLabel',yearlist(2:9),'YGrid','on');
%set(gca,'YLim',[0 2.5])
set(bar2(1),'FaceColor',gcolour,'DisplayName','Seg')
set(bar2(2),'FaceColor',scolour,'DisplayName','Ses');
set(bar2(3),'FaceColor',jcolour,'DisplayName','Wjs')
set(bar2(4),'FaceColor',pjcolour,'DisplayName','Mpj')
set(bar2(5),'FaceColor',pcolour,'DisplayName','Vcp')
set(bar2(6),'FaceColor',mcolour,'DisplayName','Vcm')

%title(sprintf('WY %d', year))
ylabel(' ET/P ')
legend(gca,'show','Location','best');

destfile = fullfile(getenv('FLUXROOT'),'Plots',...
        'NMWRRI_ET',sprintf('ETP_ratio',year));
    saveas( gcf , destfile, 'png')


% 
% 
% meanLE = array2table( all_accum_le , ...
%     'VariableNames',{'WaterYear' 'LEf_Mpj', 'LEun_Mpj','LEf_Mpg','LEun_Mpg',...
%     'LEf_daytime_Mpj', 'LEunsd_Mpj','LEf_daytime_Mpg','LEunsd_Mpg' } );
% 
% fname = fullfile(getenv('FLUXROOT'),'LE_mean_allsites.txt');
% writetable( meanLE, fname, 'delimiter',',');
%         
%[uniqueYears,idxToUnique,idxFromUniqueBackToAll] = unique(Mpg.Year);
% cumulativeLE = accumarray(idxFromUniqueBackToAll,Mpg.LEf,[],@nanmean);
%cumulativeLE = accumarray(idxFromUniqueBackToAll,Mpg.LEf,[],@cumsum);




% if convert2mm
% % -------------
% % GIRDLE CALCS
% % ------------
% % Calculate latent heat of vaporization 
% Mpg.Lv = ( 2.501 - 0.00237 * ( Mpg.TA_f ) ) .* 10^3;
% et_mms = ( 1 \ ( Mpg.Lv .* 1000 )) .* Mpg.LEf;
% % Integrate over full day
% Mpg.ET_mm_int = et_mms;
% 
% % Calculate for uncertainties
% etu_mms = ( 1 \( Mpg.Lv * 1000 )) .* Mpg.LEu;
% % Integrate over full day
% Mpg.ETu_mm_int = etu_mms;
% 
% 
% % -------------
% % CONTROL CALCS
% % ------------
% % Calculate latent heat of vaporization 
% Mpj.Lv = ( 2.501 - 0.00237 * ( Mpj.TA_f ) ) .* 10^3;
% et_mms = ( 1 / ( Mpj.Lv * 1000 )) .* Mpg.LEf;
% % Integrate over full day
% Mpj.ET_mm_int = et_mms.*86400;
% 
% % Calculate for uncertainties
% etu_mms = ( 1 / ( Mpj.Lv * 1000 )) .* Mpj.LEu;
% % Integrate over full day
% Mpj.ETu_mm_int = etu_mms;
% end