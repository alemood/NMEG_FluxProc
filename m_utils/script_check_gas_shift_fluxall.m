% Script to investigate time shift in 2016 PJ Fluxall file noticed by
% Stephen Chan (Ameriflux) when analyzing site visit data. Contents of
% email: 
%     I found a very unusual observation in the PJ dataset that Greg
%     provided. He shared a number of files via Dropbox. The file in question
%     is titled 'PJ_2016_fluxall.txt'. I can provide a copy if needed but it's 
%     a bit large (20MB). This is the main file that I've used in the comparison 
%     dataset b/c it has more of the metrics that I need. I'm fairly confident 
%     that columns 83 and 84 (CO2/H2O) mass densities from the open-path LI-7500 
%     are shifted in time by 1 timestep (30 minutes). I'm at loss as to why which 
%     is why I'm contacting you. Column 82 (sonic temperature) and column 88 
%     (pressure) both appear correctly aligned in time. I've looked at the data
%     from a number of angles and I want to check with you to see if you agree. 
%     The other file 'US-Mpj_2016_with_gaps.txt' also has CO2/H2O data but those 
%     appear properly aligned in time. The shift is only seen in that one file 
%     for 2 variables (as far as I can tell).
sitelist = {UNM_sites.PJ};
yearlist = 2016;


count = 1;
for i = 1:length(sitelist);
    for j = 1:length(yearlist)
        % Set site and year
        sitecode = sitelist{i};
        year = yearlist(j);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Read in fluxall for CO2 data. WARNING: NOT QCed!
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t = parse_fluxall_txt_file(sitecode,year,'file',...
            'C:\Research_Flux_Towers\SiteData\PJ\PJ_2016_fluxall_chan.txt');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Compare 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
% PLOT DATA 
h2o = table2array(t(:,84));
p = table2array(t(:,88));
Ts = table2array(t(:,82));
T_hmp = t.AirTC_10_Avg;
h2o_vapor = table2array(t(:,37));
ts = table2array(t(:,8));
figure;
ax(1)=subplot(2,1,1)
plot(ts,[moleden2MR(h2o/0.018 , p, Ts)/1000  h2o_vapor], ...
    ts - 0.0208 , moleden2MR(h2o/0.018 , p, Ts)/1000,':k')
set(gca,'XLim',[131 133])
title('with T_s_o_n_i_c')
ylabel('H2O mixing ratio (ppt)')
legend('col 84 (converted)','col 37', 'col 142 shifted','location','SE')

ax(2)=subplot(2,1,2)
plot(ts,[moleden2MR(h2o/0.018 , p, T_hmp)/1000  h2o_vapor],...
     ts - 0.0208 , moleden2MR(h2o/0.018 , p, Thmp)/1000,':k')
set(gca,'XLim',[131 133])
title('with T_H_M_P')
xlabel('DOY')
ylabel('H2O mixing ratio (ppt)')
legend('col 142 (converted)','col 37', 'col 142 shifted','location','SE')

linkaxes(ax,'x');


% PLOT DATA WITH SHIFTED T AND P FOR CONVERSION
h2o = table2array(t(2:end,84));
p = table2array(t(1:end-1,88));
Ts = table2array(t(1:end-1,82));
h2o_vapor = table2array(t(:,37));
ts = table2array(t(:,8));
figure;subplot(2,1,1)
plot(ts(2:end),moleden2MR(h2o/0.018 , p, Ts)/1000,...
    ts , h2o_vapor)
set(gca,'XLim',[131 133])
title('P + T shifted one timestamp earlier')
ylabel('H2O mixing ratio (ppt)')
legend('col 84 (converted)','col 37', 'col 142 shifted','location','SE')
aa=moleden2MR(h2o/0.018 , p, Ts)/1000;

h2o = table2array(t(1:end-1,84));
p = table2array(t(2:end,88));
Ts = table2array(t(2:end,82));
h2o_vapor = table2array(t(:,37));
ts = table2array(t(:,8));
subplot(2,1,2)
plot(ts(1:end-1),moleden2MR(h2o/0.018 , p, Ts)/1000,...
    ts , h2o_vapor)
set(gca,'XLim',[131 133])
title('P + T shifted one timestamp later')
ylabel('H2O mixing ratio (ppt)')
legend('col 84 (converted)','col 37', 'col 142 shifted','location','SE')
bb=moleden2MR(h2o/0.018 , p, Ts)/1000;
       
figure;plot(1:17566,[aa bb])
set(gca,'YLim',[-10 10])
    end
end