function result = UNM_Ameriflux_file_maker_TWH( sitecode, year )
% UNM_AMERIFLUX_FILE_MAKER_TWH
%
% UNM_Ameriflux_file_maker_TWH( sitecode, year )
% This code reads in the QC file, the original annual flux all file for
% soil data and the gap filled and flux partitioned files and generates
% output in a format for submission to Ameriflux
%
% based on code created by Krista Anderson Teixeira in July 2007 and modified by
% John DeLong 2008 through 2009.  Extensively modified by Timothy W. Hilton 2011
% to 2012.
%
% Timothy W. Hilton, UNM, Dec 2011 - Jan 2012


    site = get_site_name( sitecode );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Specify some details about sites and years
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    % sitecode key
    afnames(1,:) = 'US-Seg'; % 1-GLand
    afnames(2,:) = 'US-Ses'; % 2-SLand
    afnames(3,:) = 'US-Wjs'; % 3-JSav
    afnames(4,:)='US-Mpj'; % 4-PJ
    afnames(5,:)='US-Vcp'; % 5-PPine
    afnames(6,:)='US-Vcm'; % 6-MCon
    afnames(7,:)='US-FR2'; % 7-TX_savanna
    afnames(8,:)='US-FR3'; % 8-TX_forest
    afnames(9,:)='US-FR1'; % 9-TX_grassland
    afnames(10,:)='US-Mpg'; % 4-PJ
    afnames(11,:)='US-Sen'; % 11-N4611 Montbel Place New_GLand

    year_s=num2str(year);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % parse Flux_All, Flux_All_qc, gapfilled fluxes, and partitioned fluxes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% parse the annual Flux_All file
    data = UNM_parse_fluxall_xls_file( sitecode, year );

    %% parse the QC file
    qc_num = UNM_parse_QC_xls_file( sitecode, year );
    ds_qc = fluxallqc_2_dataset( qc_num, sitecode, year );
    
    %% parse gapfilled and partitioned fluxes
    [ ds_gf, ds_pt ] = UNM_parse_gapfilled_partitioned_output( sitecode, year );
    
    % make sure that QC, FluxAll, gapfilled, and partitioned have identical,
    % complete 30 minute timeseries
    [ ds_qc, data ] = merge_datasets_by_datenum( ds_qc, data, ...
                                                 'timestamp', 'timestamp', 3 );
    [ ds_gf, data ] = merge_datasets_by_datenum( ds_gf, data, ...
                                                 'timestamp', 'timestamp', 3 );
    [ ds_pt, data ] = merge_datasets_by_datenum( ds_pt, data, ...
                                                 'timestamp', 'timestamp', 3 );
    %% parsing the excel files is slow -- this loads parsed data for testing
    %%load( '/media/OS/Users/Tim/DataSandbox/GLand_2010_fluxall.mat' );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % do some bookkeeping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % create a column of -9999s to place in the dataset where a site does not record
    % a particular variable
    dummy = repmat( -9999, size( ds_qc, 1 ), 1 );

    %% calculate fractional jday (i.e. 3 Jan at 12:00 would be 3.5)
    ds_qc.fjday = ( ds_qc.jday + ...
                    ( ds_qc.hour / 24.0 ) + ...
                    ( ds_qc.minute / ( 24.0 * 60.0) ) );
    
    %% fix incorrect precipitation values
    ds_qc.precip = fix_incorrect_precip_factors( sitecode, year, ...
                                                 ds_qc.fjday, ds_qc.precip );

    % create dataset of soil properties.
    ds_soil = UNM_Ameriflux_prepare_soil_met( sitecode, year, data, ds_qc );
    
    % create a dataset for Ameriflux output variables
    
        
        
    keyboard()
    
    % use new partitioning
    stop = length(dummy); 

    f_flag = repmat( 1, size( data, 1 ), 1 );

    VPD_f = gf_in.VPD ./ 10; % convert to kPa
    VPD_g( ~isnan( ds_qc.rH ) ) = VPD_f( ~isnan( ds_qc.rH ) );
    Tair_f = gf_in.Tair_f
    Rg_f = gf_in.Rg_f

    TA_flag = f_flag;
    TA_flag( ~isnan( ds_qc.air_temp_hmp ) ) = 0;
    Rg_flag=f_flag;
    Rg_flag( ~isnan( ds_qc.sw_incoming ) ) = 0;
    VPD_flag = f_flag;
    VPD_flag( ~isnan( ds_qc.rH ) ) = 0;

    NEE_obs = dummy;
    LE_obs = dummy;
    H_obs = dummy;
    % Take out some extra uptake values at Grassland premonsoon.
    if sitecode ==1
        to_remove = find( ds_qc.fc_raw_massman_wpl( 1:7000 ) <= 1.5 );
        fc_raw_massman_wpl( to_remove ) = NaN;
        to_remove = find( ds_qc.fc_raw_massman_wpl( 1:5000 ) <= 0.75 );
        fc_raw_massman_wpl( to_remove ) = NaN;
    end
    % Take out some extra uptake values at Ponderosa respiration.
    if sitecode == 5
        to_remove= find( ds_qc.fc_raw_massman_wpl > 8 );
        ds_qc.fc_raw_massman_wpl( to_remove ) = NaN;
    end


    NEE_obs(~isnan(fc_raw_massman_wpl)) = fc_raw_massman_wpl(~isnan(fc_raw_massman_wpl));
    LE_obs(~isnan(HL_wpl_massman))=HL_wpl_massman(~isnan(HL_wpl_massman));
    H_obs(~isnan(HSdry_massman))=HSdry_massman(~isnan(HSdry_massman));

    NEE_flag=f_flag;
    LE_flag=f_flag;
    H_flag=f_flag;

    NEE_flag(~isnan(fc_raw_massman_wpl))=0;
    LE_flag(~isnan(E_wpl_massman))=0;
    H_flag(~isnan(HSdry_massman))=0;

    NEE_f=pt_in(1:stop,9);
    RE_f =pt_in(1:stop,6);
    GPP_f=pt_in(1:stop,7);
    LE_f=gf_in(1:stop,28);
    H_f=gf_in(1:stop,35);

    % Make sure NEE contain observations where available
    NEE_2=NEE_f;
    NEE_2(~isnan(fc_raw_massman_wpl)) = NEE_obs(~isnan(fc_raw_massman_wpl));

    % To ensure carbon balance, calculate GPP as remainder when NEE is
    % subtracted from RE. This will give negative GPP when NEE exceeds
    % modelled RE. So set GPP to zero and add difference to RE.
    GPP_2=RE_f-NEE_2;
    found=find(GPP_2<0);
    RE_2=RE_f;
    RE_2(found)=RE_f(found)-GPP_2(found);
    GPP_2(found)=0;

    % Make sure LE and H contain observations where available
    LE_2=LE_f;
    LE_2(~isnan(HL_wpl_massman))=HL_wpl_massman(~isnan(HL_wpl_massman));

    H_2=H_f;
    H_2(~isnan(HSdry_massman))=HSdry_massman(~isnan(HSdry_massman));

    % Make GPP and RE "obs" for output to file with gaps using modeled RE
    % and GPP as remainder
    GPP_obs=dummy;
    GPP_obs(~isnan(fc_raw_massman_wpl)) = GPP_2(~isnan(fc_raw_massman_wpl));
    RE_obs=dummy;
    RE_obs(~isnan(fc_raw_massman_wpl)) = RE_2(~isnan(fc_raw_massman_wpl));

    HL_wpl_massman(isnan(E_wpl_massman))=NaN;

    % A little cleaning - very basic high/low filtering
    Tsoil_1(Tsoil_1>50)=nan; Tsoil_1(Tsoil_1<-10)=nan;
    SWC_1(SWC_1>1)=nan; SWC_1(SWC_1<0)=nan;
    ground(ground>150)=nan; ground(ground<-150)=nan;
    lw_incoming(lw_incoming>600)=nan; lw_incoming(lw_incoming<120)=nan;
    lw_outgoing(lw_outgoing>650)=nan; lw_outgoing(lw_outgoing<120)=nan;
    E_wpl_massman((E_wpl_massman.*18)<-5)=nan;
    CO2_mean(CO2_mean<350)=nan;
    wnd_spd(wnd_spd>25)=nan;
    atm_press(atm_press>150)=nan; atm_press(atm_press<20)=nan;
    Par_Avg(Par_Avg>2500)=nan; Par_Avg(Par_Avg<-100)=nan; Par_Avg(Par_Avg<0 & Par_Avg>-100)=0;

    NEE_f(NEE_f>50)=nan;  NEE_f(NEE_f<-50)=nan;
    RE_f(RE_f>50)=nan;  RE_f(RE_f<-50)=nan;
    GPP_f(GPP_f>50)=nan;  GPP_f(GPP_f<-50)=nan;
    NEE_obs(NEE_obs>50)=nan;  NEE_obs(NEE_obs<-50)=nan;
    RE_obs(RE_obs>50)=nan;  RE_obs(RE_obs<-50)=nan;
    GPP_obs(GPP_obs>50)=nan;  GPP_obs(GPP_obs<-50)=nan;
    NEE_2(NEE_2>50)=nan;  NEE_2(NEE_2<-50)=nan;
    RE_2(RE_2>50)=nan;  RE_2(RE_2<-50)=nan;
    GPP_2(GPP_2>50)=nan;  GPP_2(GPP_2<-50)=nan;

    if sitecode ==6 && year(1) == 2008
        lw_incoming(~isnan(lw_incoming))=nan;
        lw_outgoing(~isnan(lw_outgoing))=nan;
        NR_tot(~isnan(NR_tot))=nan;
    end


    %%

    close all

    NEE_obs(NEE_obs==-9999)=nan;
    GPP_obs(GPP_obs==-9999)=nan;
    RE_obs(RE_obs==-9999)=nan;
    H_obs(H_obs==-9999)=nan;
    LE_obs(LE_obs==-9999)=nan;
    VPD_f(VPD_f==-999.9000)=nan;

    month_divide=linspace(1,17520,13);
    md=cat(1,month_divide,month_divide);
    md2=[5 5 5 5 5 5 5 5 5 5 5 5 5];
    md3=md2.*-1;
    md4=cat(1,md2,md3);

    figure('Name','Fluxes','NumberTitle','off')
    subplot(3,1,1)
    plot(NEE_f,'r.'); hold on
    plot(NEE_obs,'.'); hold on
    plot(md,md4,'k'); hold on
    ylabel('NEE'); %ylim([-20 20])
    legend('Model','Obs')
    subplot(3,1,2)
    plot(GPP_f,'r.'); hold on
    plot(GPP_obs,'.'); hold on
    ylabel('GPP'); %ylim([0 50])
    subplot(3,1,3)
    plot(RE_f,'r.'); hold on
    plot(RE_obs,'.'); hold on
    ylabel('RE'); %ylim([0 50])

    %%

    figure('Name','Cumulative Fluxes','NumberTitle','off')
    subplot(3,1,1)
    plot(cumsum(NEE_f(~isnan(NEE_f))).*0.0216,'r'); hold on
    plot(cumsum(NEE_2(~isnan(NEE_2))).*0.0216,'b'); hold on;
    ylabel('NEE')
    legend('Model','Obs')
    subplot(3,1,2)
    plot(cumsum(GPP_f(~isnan(GPP_f))).*0.0216,'r'); hold on
    plot(cumsum(GPP_2(~isnan(GPP_2))).*0.0216,'b'); hold on;
    ylabel('GPP')
    subplot(3,1,3)
    plot(cumsum(RE_f(~isnan(RE_f))).*0.0216,'r'); hold on
    plot(cumsum(RE_2(~isnan(RE_2))).*0.0216,'b'); hold on;
    ylabel('RE')

    figure('Name','Energy Fluxes','NumberTitle','off')
    subplot(3,1,1)
    plot(H_f,'r.'); hold on
    plot(H_obs,'.'); hold on;
    ylabel('H'); %ylim([-200 1000])
    subplot(3,1,2)
    plot(LE_f,'r.'); hold on
    plot(LE_obs,'.'); hold on;
    ylabel('LE'); %ylim([-200 1000])
    subplot(3,1,3)
    plot(Rg_f,'.');
    ylabel('Rg'); %ylim([0 1500])

    figure('Name','Soil data','NumberTitle','off')
    subplot(3,1,1)
    plot(ground); hold on;
    ylabel('Ground')
    subplot(3,1,2)
    plot(Tsoil_1); hold on;
    ylabel('Soil T')
    subplot(3,1,3)
    plot(SWC_1); hold on;
    ylabel('SWC')

    figure('Name','Met data','NumberTitle','off')
    subplot(2,3,1)
    plot(air_temp_hmp,'.'); hold on;
    ylabel('Air temp')
    subplot(2,3,2)
    plot(wnd_spd,'.'); hold on;
    ylabel('Wnd Spd')
    subplot(2,3,3)
    plot(precip); hold on;
    ylabel('PPT')
    subplot(2,3,4)
    plot(VPD_f,'.'); hold on;
    ylabel('VPD'); %ylim([0 10])
    subplot(2,3,5)
    plot(NR_tot,'.'); hold on;
    ylabel('NR tot')
    subplot(2,3,6)
    plot(Par_Avg,'.'); hold on;
    %    plot(par_down_Avg,'r.');
    ylabel('Par Avg')

    figure('Name','Radiation components','NumberTitle','off')
    subplot(2,2,1)
    plot(sw_incoming,'.'); hold on;
    ylabel('sw incoming')
    subplot(2,2,2)
    plot(sw_outgoing,'.'); hold on;
    ylabel('sw outgoing')
    subplot(2,2,3)
    plot(lw_incoming,'.'); hold on;
    ylabel('lw incoming')
    subplot(2,2,4)
    plot(lw_outgoing,'.'); hold on;
    ylabel('lw outgoing')

    figure('Name','Concentrations','NumberTitle','off')
    subplot(2,2,1)
    plot(CO2_mean,'.'); hold on;
    ylabel('CO2 Mean')
    subplot(2,2,2)
    plot(H2O_mean,'.'); hold on;
    ylabel('H2O mean')
    subplot(2,2,3)
    plot(E_wpl_massman.*18,'.'); hold on;
    ylabel('Water flux')
    subplot(2,2,4)
    plot(atm_press,'.'); hold on;
    ylabel('atm press')

    %    'Is this looking OK?'
    %
    %     pause
    %%


    datamatrix1 = [year,intjday,(hour.*100)+minute, ds.fjdayday,u_star,air_temp_hmp, ...
                   wnd_dir_compass,wnd_spd, dummy,NEE_obs,dummy,H_obs,dummy, ...
                   LE_obs,dummy,ground, Tsoil_1,precip,rH.*100,atm_press, ...
                   CO2_mean,VPD_g,SWC_1,NR_tot,Par_Avg,dummy,dummy,sw_incoming, ...
                   dummy,sw_outgoing,lw_incoming,lw_outgoing,E_wpl_massman.*18, ...
                   H2O_mean,RE_obs,GPP_obs,dummy]; % E_wpl_massman.*18 = water
                                                   % flux in mg/m2/s

    %create a dataset from the non-gapfilled data
    vnames = genvarname(header1);
    ds_notfilled = dataset({datamatrix1, vnames{:}});

    datamatrix1(isnan(datamatrix1))=-9999;

    filename = strcat(outfolder,afnames(sitecode,:),'_',year_s,'_with_gaps.txt');

    time_out=fix(clock);
    time_out=datestr(time_out);
    sname={'Site name: ',afnames(sitecode,:)};
    email={'Email: mlitvak@unm.edu'};
    timeo={'Created: ',time_out};

    dlmwrite(filename,sname,'');
    dlmwrite(filename,email,'-append','delimiter','');
    dlmwrite(filename,timeo,'-append','delimiter','');

    txt=sprintf('%s\t',header1{:});
    txt(end)='';
    dlmwrite(filename,txt,'-append','delimiter','');

    txt=sprintf('%s\t',units1{:});
    txt(end)='';
    dlmwrite(filename,txt,'-append','delimiter','');
    dlmwrite(filename,datamatrix1,'-append','delimiter','\t');


    datamatrix2 = [year,intjday,(hour.*100)+minute, ds.fjday,u_star,Tair_f,TA_flag, ...
                   wnd_dir_compass,wnd_spd, dummy,NEE_2,NEE_flag,dummy,H_2, ...
                   H_flag,dummy,LE_2,LE_flag,dummy,ground, Tsoil_1,precip,rH.* ...
                   100,atm_press,CO2_mean,VPD_f,VPD_flag,SWC_1,NR_tot,Par_Avg, ...
                   dummy,dummy,Rg_f,Rg_flag, dummy,sw_outgoing,lw_incoming, ...
                   lw_outgoing,E_wpl_massman.*18,H2O_mean,RE_2,NEE_flag,GPP_2, ...
                   NEE_flag,dummy,SWC_2,SWC_3];


    vnames = genvarname(header2);
    ds_gapfilled = dataset({datamatrix2, vnames{:}});

    datamatrix2(isnan(datamatrix2))=-9999;

    filename = strcat(outfolder,afnames(sitecode,:),'_',year_s,'_gapfilled.txt');


    time_out=fix(clock);
    time_out=datestr(time_out);
    sname={'Site name: ',afnames(sitecode,:)};
    email={'Email: mlitvak@unm.edu'};
    timeo={'Created: ',time_out};

    dlmwrite(filename,sname,'');
    dlmwrite(filename,email,'-append','delimiter','');
    dlmwrite(filename,timeo,'-append','delimiter','');

    txt=sprintf('%s\t',header2{:});
    txt(end)='';
    dlmwrite(filename,txt,'-append','delimiter','');

    txt=sprintf('%s\t',units2{:});
    txt(end)='';
    dlmwrite(filename,txt,'-append','delimiter','');

    dlmwrite(filename,datamatrix2,'-append','delimiter','\t');

