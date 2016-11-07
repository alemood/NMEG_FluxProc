sitelist = {UNM_sites.PJ};
yearlist = 2015;
rlist = {'SCO2_P330_AVG'	'SCO2_P230_AVG'	'SCO2_P430_AVG'...
           'SCO2_P530_AVG'	'SCO2_J130_AVG'	'SCO2_J230_AVG'};
       thetalist = {'SWC_P3_30_AVG'	'SWC_P2_30_AVG'	'SWC_P4_30_AVG'...
           'SWC_P5_30_AVG'	'SWC_J1_30_AVG'	'SWC_J2_30_AVG'};
       tlist = {'SOILT_P3_30_AVG'	'SOILT_P2_30_AVG'	'SOILT_P4_30_AVG'...
           'SOILT_P5_30_AVG'	'SOILT_J1_30_AVG'	'SOILT_J2_30_AVG'};

hystmat=table();
count = 1;
for i = 1:length(sitelist);
    for j = 1:length(yearlist)
        % Set site and year
        sitecode = sitelist{i};
        year = yearlist(j);
        for k = 1:length(rlist)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Read in fluxall for CO2 data. WARNING: NOT QCed!
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t=parse_fluxall_txt_file(sitecode,year);

        CO2 = t(:,rlist{k});
        %This code attempts to find columns with soil co2 variable names
%         %Both of these capture all variable names
%       
%         var_names=regexp(t.Properties.VariableNames,',','split')
%         var_names = cellfun( @char, var_names, 'UniformOutput',  false );
%         
%         aa=regexpi(t.Properties.VariableNames,'(\w+_?)','tokens');
%         aa=[aa{:}];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Read in QCed processed soil data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        t2= parse_soilmet_qc_file(sitecode,year);
        
        theta = t2(:,thetalist{k});
        temp = t2(:,tlist{k});
        daytime = t2.timestamp;
        
        subplot(2,3,k)
       
        [myRange{i,j,k},inertia{i,j,k},tempav{i,j,k},thav{i,j,k},cav{i,j,k}] = ...
            hysteresis(daytime,table2array(temp),table2array(theta),table2array(CO2));
         title(rlist{k})
               
        count = count + 1;
        
        end
    end
end

