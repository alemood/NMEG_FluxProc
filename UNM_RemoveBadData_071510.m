% This program was created by Krista Anderson Teixeira in July 2007
% Modified by John DeLong 2008 through 2009

% The program reads site_fluxall_year excel files and pulls in a
% combination of matlab processed ts data and data logged average 30-min
% flux data.  It then flags values based on a variety of criteria and
% writes out new files that do not have the identified bad values.  It
% writes out a site_flux_all_qc file and a site_flux_all_for_gap_filling
% file to send to the Reichstein online gap-filling program.  It can be
% adjusted to make other subsetted files too.

% This program is set up to run as a function where you enter the command
% along with the sitecode (1-7 see below) and the year.  This means that it
% only runs on files that are broken out by year.

%function [] = UNM_RemoveBadData(sitecode,year,iteration)
clear all
close all

sitecode = 7;
year = 2007;
iteration = 6;

% sitecode key
% 1-GLand
% 2-SLand
% 3-JSav
% 4-PJ
% 5-PPine
% 6-MCon
% 7-TX_savanna
% 8-TX_forest
% 9-TX_grassland

write_complete_out_file = 0; %1 to write "[sitename].._qc", -- file with all variables & bad data removed
data_for_analyses = 0; %1 to output file with data sorted for specific analyses
ET_gap_filler = 0; %run ET gap-filler program
write_gap_filling_out_file = 0; %1 to write file for Reichstein's online gap-filling. SET U* LIM (including site- specific ones--comment out) TO 0!!!!!!!!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify some details about sites and years
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sitecode==1; % grassland
    site='GLand';
    if year == 2006
        filelength_n = 11594;
    elseif year == 2007
        filelength_n = 17523;
        lastcolumn='HC';
        ustar_lim = 0.06;
        co2_min = -7; co2_max = 6;
    elseif year == 2008;
        filelength_n = 17572;
        lastcolumn='HD';
        ustar_lim = 0.06;
        co2_min = -10; co2_max = 6;
    elseif year == 2009;
        filelength_n = 13371;
        lastcolumn='HO';
        ustar_lim = 0.06;
        co2_min = -10; co2_max = 6;
    end
    wind_min = 330; wind_max = 30; % these are given a sonic_orient = 180;
    Tdry_min = 240; Tdry_max = 320;
    HS_min = -100; HS_max = 450;
    HSmass_min = -100; HSmass_max = 450;
    LH_min = -150; LH_max = 450;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;

elseif sitecode==2; % shrubland
    site='SLand'    
    if year == 2006
    elseif year == 2007
        filelength_n = 17523;
        lastcolumn='GX';
        ustar_lim = 0.08;
        co2_min = -10; co2_max = 6;        
    elseif year == 2008
        filelength_n = 17572;
        lastcolumn='GZ';
        ustar_lim = 0.08;
        co2_min = -10; co2_max = 6;
    elseif year == 2009
        filelength_n = 13376;
        lastcolumn='IL';
        ustar_lim = 0.08;
        co2_min = -10; co2_max = 6;
    end
    wind_min = 330; wind_max = 30; % these are given a sonic_orient = 180;
    Tdry_min = 240; Tdry_max = 320;
    HS_min = -100; HS_max = 450;
    HSmass_min = -100; HSmass_max = 450;
    LH_min = -150; LH_max = 450;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
     
elseif sitecode==3; % Juniper savanna
    site = 'JSav'   
    if year == 2007
        filelength_n = 11596;
        lastcolumn='HR';
        ustar_lim = 0.09;
        co2_min = -11; co2_max = 7;        
    elseif year == 2008
        filelength_n = 17572;
        lastcolumn='HJ';
        ustar_lim = 0.08;
        co2_min = -10; co2_max = 10;
    elseif year == 2009
        filelength_n = 4639;
        lastcolumn='HN';
        ustar_lim = 0.08;
        co2_min = -10; co2_max = 10;
    end
    wind_min = 15; wind_max = 75; % these are given a sonic_orient = 225;
    Tdry_min = 240; Tdry_max = 320;
    HS_min = -100; HS_max = 450;
    HSmass_min = -100; HSmass_max = 450;
    LH_min = -150; LH_max = 450;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    press_min = 70; press_max = 130;
    
elseif sitecode == 4; % Pinyon Juniper
    site = 'PJ'
    if year == 2007
        lastcolumn = 'HO';
        filelength_n = 2514;
        ustar_lim = 0.16;
    elseif year == 2008
        lastcolumn = 'HO'; 
        filelength_n = 17572;
        ustar_lim = 0.16;
    elseif year == 2009
        lastcolumn = 'HJ';
        filelength_n = 17524;
        ustar_lim = 0.16;
    elseif year == 2010
        lastcolumn = 'HJ';
        filelength_n = 9681;
        ustar_lim = 0.16; 
    end    
    wind_min = 15; wind_max = 75; % these are given a sonic_orient = 225;
    co2_min = -10; co2_max = 6;
    Tdry_min = 240; Tdry_max = 310;
    HS_min = -100; HS_max = 640;
    HSmass_min = -100; HSmass_max = 640;
    LH_min = -150; LH_max = 450;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    press_min = 70; press_max = 130;
    
elseif sitecode==5; % Ponderosa Pine
    site = 'PPine'
    if year == 2006
        filelength_n = 11594;
    elseif year == 2007
        filelength_n = 17524;
        lastcolumn='FV';
        ustar_lim = 0.08;
        co2_min = -15; co2_max = 15;
%        co2_min = -30; co2_max = 30;
    elseif year == 2008;
        filelength_n = 17572;
        lastcolumn='FU';
        ustar_lim = 0.08;
        co2_min = -15; co2_max = 15;
%        co2_min = -30; co2_max = 30;
    elseif year == 2009;
        filelength_n = 12029;
        lastcolumn='FX';
        ustar_lim = 0.08;
        co2_min = -15; co2_max = 15;
%        co2_min = -30; co2_max = 30;
    end
%    co2_max_by_month = [4 4 4 4 5 12 12 12 12 12 4 4];
    co2_max_by_month = [4 4 4 5 8 12 12 12 12 10 5 4];    
    wind_min = 119; wind_max = 179; % these are given a sonic_orient = 329;
    Tdry_min = 240; Tdry_max = 300;
    HS_min = -200; HS_max = 800;
    HSmass_min = -200; HSmass_max = 800;
    LH_min = -150; LH_max = 550;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    
elseif sitecode==6; % Mixed conifer
    site = 'MCon'
    if year == 2006
        filelength_n = 4420; 
        lastcolumn='GA';
        ustar_lim = 0.12;
        co2_min = -12; co2_max = 6;
    elseif year == 2007
        filelength_n = 17524;
        lastcolumn='GB';
        ustar_lim = 0.12;
        co2_min = -12; co2_max = 6;
    elseif year == 2008;
        filelength_n = 17420;
        lastcolumn='GB';
        ustar_lim = 0.11;
        co2_min = -12; co2_max = 6;
    elseif year == 2009;
        filelength_n = 16780;
        lastcolumn='GF';
        ustar_lim = 0.11;
        co2_min = -12; co2_max = 6;
    end
    
    wind_min = 153; wind_max = 213; % these are given a sonic_orient = 333;
    Tdry_min = 250; Tdry_max = 300;
    HS_min = -200; HS_max = 800;
    HSmass_min = -200; HSmass_max = 800;
    LH_min = -150; LH_max = 550;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    
elseif sitecode == 7;
    site = 'TX'
    if year == 2005
        filelength_n = 17524;  
        lastcolumn='GF';
        ustar_lim = 0.11;
        co2_min = -26; co2_max = 12;
    elseif year == 2006
        filelength_n = 17524;  
        lastcolumn='GF';
        ustar_lim = 0.11;
        co2_min = -26; co2_max = 12;
    elseif year == 2007
        filelength_n = 17524;
        lastcolumn='FZ';
        ustar_lim = 0.11;
        co2_min = -26; co2_max = 12;
    elseif year == 2008;
        filelength_n = 17452;
        lastcolumn='GP';
        ustar_lim = 0.11;
        co2_min = -11; co2_max = 6;
    end
    wind_min = 296; wind_max = 356; % these are given a sonic_orient = 146;
    Tdry_min = 265; Tdry_max = 315;
    HS_min = -200; HS_max = 800;
    HSmass_min = -200; HSmass_max = 800;
    LH_min = -150; LH_max = 550;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    press_min = 70; press_max = 130;

elseif sitecode == 8;
    site = 'TX_forest'
    if year == 2005
        filelength_n = 17524;  
        lastcolumn='DO';
        ustar_lim = 0.12;
    elseif year == 2006
        filelength_n = 17524;  
        lastcolumn='DO';
        ustar_lim = 0.12;
    elseif year == 2007
        filelength_n = 17524;
        lastcolumn='DO';
        ustar_lim = 0.12;
    elseif year == 2008;
        filelength_n = 16253;
        lastcolumn='GP';
        ustar_lim = 0.11;
    end
    co2_min = -26; co2_max = 12;
    wind_min = 300; wind_max = 360; % these are given a sonic_orient = ;
    Tdry_min = 265; Tdry_max = 315;
    HS_min = -200; HS_max = 800;
    HSmass_min = -200; HSmass_max = 800;
    LH_min = -150; LH_max = 550;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    press_min = 70; press_max = 130;
    
elseif sitecode == 9;
    site = 'TX_grassland'
    if year == 2005
        filelength_n = 17524;  
        lastcolumn='DT';
        ustar_lim = 0.06;
    elseif year == 2006
        filelength_n = 17523;  
        lastcolumn='DO';
        ustar_lim = 0.06;
    elseif year == 2007
        filelength_n = 17524;
        lastcolumn='DO';
        ustar_lim = 0.07;
    elseif year == 2008;
        filelength_n = 16253;
        lastcolumn='GP';
        ustar_lim = 0.11;
    end
    co2_min = -26; co2_max = 12;
    wind_min = 300; wind_max = 360; % these are given a sonic_orient = ;
    Tdry_min = 265; Tdry_max = 315;
    HS_min = -200; HS_max = 800;
    HSmass_min = -200; HSmass_max = 800;
    LH_min = -150; LH_max = 550;
    rH_min = 0; rH_max = 1;
    h2o_max = 35; h2o_min = 0;
    press_min = 70; press_max = 130;

elseif sitecode == 10; % Pinyon Juniper girdle
    site = 'PJ_girdle'
    lastcolumn = 'FE';
    if year == 2009
        filelength_n = 17523;
        ustar_lim = 0.16;    
    elseif year == 2010
        filelength_n = 9678;
        ustar_lim = 0.16;    
    end      
    wind_min = 15; wind_max = 75; % these are given a sonic_orient = 225;
    co2_min = -10; co2_max = 6;
    Tdry_min = 240; Tdry_max = 310;
    HS_min = -100; HS_max = 640;
    HSmass_min = -100; HSmass_max = 640;
    LH_min = -150; LH_max = 450;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    press_min = 70; press_max = 130;
    
elseif sitecode == 11; % Pinyon Juniper girdle test
    site = 'PJG_test'
    lastcolumn = 'FE';
    if year == 2009
        filelength_n = 16826;
        ustar_lim = 0.16;    
    end    
    wind_min = 15; wind_max = 75; % these are given a sonic_orient = 225;
    co2_min = -10; co2_max = 6;
    Tdry_min = 240; Tdry_max = 310;
    HS_min = -100; HS_max = 640;
    HSmass_min = -100; HSmass_max = 640;
    LH_min = -150; LH_max = 450;
    rH_min = 0; rH_max = 1;
    h2o_max = 30; h2o_min = 0;
    press_min = 70; press_max = 130;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up file name and file path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

drive='c:';
row1=5;  %first row of data to process - rows 1 - 4 are header
filename = strcat(site,'_flux_all_',num2str(year))
%filename = strcat(site,'_new_radiation_flux_all_',num2str(year))
filelength = num2str(filelength_n);
%datalength = filelength_n - row1 + 1; 
filein = strcat(drive,'\Research - Flux Towers\Flux Tower Data by Site\',site,'\',filename)
outfolder = strcat(drive,'\Research - Flux Towers\Flux Tower Data by Site\',site,'\processed flux\');
range = strcat('B',num2str(row1),':',lastcolumn,filelength);
headerrange = strcat('B2:',lastcolumn,'2');
time_stamp_range = strcat('A5:A',filelength);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open file and parse out dates and times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('reading data...')
[num text] = xlsread(filein,headerrange);
headertext = text;
[num text] = xlsread(filein,range);  %does not read in first column because it's text!!!!!!!!
data = num;
ncol = size(data,2)+1;
datalength = size(data,1);
[num text] = xlsread(filein,time_stamp_range);
timestamp = text;
[year month day hour minute second] = datevec(timestamp);
datenumber = datenum(timestamp);
disp('file read');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in Matlab processed ts data (these are in the same columns for all
% sites, so they can be just hard-wired in by column number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if year(2) < 2009 && sitecode ~= 3 
    if sitecode == 7 && year(2) == 2008 % This is set up for 2009 output
        disp('TX 2008 is set up as 2009 output');
        stop
    end
    
jday=data(:,8);
iok=data(:,9);
Tdry=data(:,14);
wnd_dir_compass=data(:,15);
wnd_spd=data(:,16);
u_star=data(:,27);
CO2_mean=data(:,31);
CO2_std=data(:,32);
H2O_mean=data(:,36);
H2O_std=data(:,37);

fc_raw = data(:,38);
fc_raw_massman = data(:,39);
fc_water_term = data(:,42);
fc_heat_term_massman = data(:,45);
fc_raw_massman_wpl = data(:,46); % = flux_co2_massman + flux_co2_wpl_water + flux_co2_massman_wpl_heat

E_raw = data(:,47);
E_raw_massman = data(:,44);
E_water_term = data(:,51);
E_heat_term_massman = data(:,50);
E_wpl_massman = data(:,55); % = flux_h20_wpl_water + flux_h20_massman_wpl_heat

HSdry = data(:,56);
HSdry_massman = data(:,59);

HL_raw = data(:,60);
HL_wpl_massman = data(:,64);
HL_wpl_massman_un = data(:,63);
% Half hourly data filler only produces uncorrected HL_wpl_massman, but use
% these where available
HL_wpl_massman(isnan(HL_wpl_massman)&~isnan(HL_wpl_massman_un))=HL_wpl_massman_un(isnan(HL_wpl_massman)&~isnan(HL_wpl_massman_un));

decimal_day = jday + hour./24 + (minute + 1)./1440;
year2 = year(2);

for i=1:ncol;
    if strcmp('RH',headertext(i)) == 1 || strcmp('rh_hmp', headertext(i)) == 1 || strcmp('rh_hmp_4_Avg', headertext(i)) == 1
        rH = data(:,i-1);
    end
end

rH=rH./100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    
jday=data(:,8);
iok=data(:,9);
Tdry=data(:,14);
wnd_dir_compass=data(:,15);
wnd_spd=data(:,16);
rH = data(:,17);
u_star=data(:,28);
CO2_mean=data(:,32);
CO2_std=data(:,33);
H2O_mean=data(:,37);
H2O_std=data(:,38);

fc_raw = data(:,39);
fc_raw_massman = data(:,40);
fc_water_term = data(:,41);
fc_heat_term_massman = data(:,42);
fc_raw_massman_wpl = data(:,43); % = flux_co2_massman + flux_co2_wpl_water + flux_co2_massman_wpl_heat

E_raw = data(:,44);
E_raw_massman = data(:,45);
E_water_term = data(:,46);
E_heat_term_massman = data(:,47);
E_wpl_massman = data(:,48);

HSdry = data(:,50);
HSdry_massman = data(:,53);

HL_raw = data(:,54);
HL_wpl_massman = data(:,56);
HL_wpl_massman_un = data(:,55);
% Half hourly data filler only produces uncorrected HL_wpl_massman, but use
% these where available as very similar values
HL_wpl_massman(isnan(HL_wpl_massman)&~isnan(HL_wpl_massman_un))=HL_wpl_massman_un(isnan(HL_wpl_massman)&~isnan(HL_wpl_massman_un));


decimal_day = jday + hour./24 + (minute + 1)./1440;
year2 = year(2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in 30-min data, variable order and names in flux_all files are not  
% consistent so match headertext
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:ncol;
    if strcmp('agc_Avg',headertext(i)) == 1
        agc_Avg = data(:,i-1);
    elseif strcmp('rain_Tot', headertext(i)) == 1 || strcmp('precip', headertext(i)) == 1 || ...
            strcmp('precip(in)', headertext(i)) == 1 || strcmp('ppt', headertext(i)) == 1 || ...
            strcmp('Precipitation', headertext(i)) == 1
        precip = data(:,i-1);
    elseif strcmp('press_mean', headertext(i)) == 1 || strcmp('BP_mbar', headertext(i)) == 1 || strcmp('press_Avg', headertext(i)) == 1 || strcmp('press_a', headertext(i)) == 1 || strcmp('press_mean', headertext(i)) == 1
        atm_press = data(:,i-1);
    elseif strcmp('par_correct_Avg', headertext(i)) == 1  || strcmp('par_Avg(1)', headertext(i)) == 1 || ...
            strcmp('par_Avg', headertext(i)) == 1 || strcmp('par_up_Avg', headertext(i)) == 1
        Par_Avg = data(:,i-1);
    elseif strcmp('t_hmp_mean', headertext(i))==1 || strcmp('AirTC_Avg', headertext(i))==1 || ...
            strcmp('t_hmp_3_Avg', headertext(i))==1 || strcmp('pnl_tmp_a', headertext(i))==1 || strcmp('t_hmp_Avg', headertext(i))==1 ...
            || strcmp('t_hmp_4_Avg', headertext(i))==1
        air_temp_hmp = data(:,i-1);
    elseif strcmp('Tsoil',headertext(i)) == 1 || strcmp('Tsoil_avg',headertext(i)) == 1 || ...
            strcmp('soilT_Avg(1)',headertext(i)) == 1
        Tsoil = data(:,i-1);
    elseif strcmp('Rn_correct_Avg',headertext(i))==1 || strcmp('NR_surf_AVG', headertext(i))==1 || ...
            strcmp('NetTot_Avg_corrected', headertext(i))==1 || strcmp('NetTot_Avg', headertext(i))==1 || ...
            strcmp('Rn_Avg',headertext(i))==1 || strcmp('Rn_total_Avg',headertext(i))==1
        NR_tot = data(:,i-1);
    elseif strcmp('Rad_short_Up_Avg', headertext(i))==1 || strcmp('pyrr_incoming_Avg', headertext(i))==1
        sw_incoming = data(:,i-1);
    elseif strcmp('Rad_short_Dn_Avg', headertext(i))==1 || strcmp('pyrr_outgoing_Avg', headertext(i))==1  
        sw_outgoing = data(:,i-1);
    elseif strcmp('Rad_long_Up_Avg', headertext(i))==1 
        lw_incoming = data(:,i-1);
    elseif strcmp('Rad_long_Dn_Avg', headertext(i))==1
        lw_outgoing = data(:,i-1);
    elseif strcmp('VW_Avg', headertext(i))==1
        VWC = data(:,i-1);
    elseif strcmp('shf_Avg(1)', headertext(i))==1 || strcmp('shf_pinon_1_Avg', headertext(i))==1 
        soil_heat_flux_1 = data(:,i-1);
    elseif strcmp('shf_Avg(2)', headertext(i))==1 || strcmp('shf_jun_1_Avg', headertext(i))==1
        soil_heat_flux_2 = data(:,i-1);
    elseif strcmp('hfpopen_1_Avg', headertext(i))==1 % only for TX
        soil_heat_flux_open = data(:,i-1);
    elseif strcmp('hfpmescan_1_Avg', headertext(i))==1 % only for TX
        soil_heat_flux_mescan = data(:,i-1);
    elseif strcmp('hfpjuncan_1_Avg', headertext(i))==1 % only for TX
        soil_heat_flux_juncan = data(:,i-1);
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Site-specific steps for soil temperature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sitecode == 4
    for i=1:ncol;
        if strcmp('tcav_pinon_1_Avg',headertext(i)) == 1
            Tsoil1 = data(:,i-1);
        elseif strcmp('tcav_jun_1_Avg',headertext(i)) == 1
            Tsoil2 = data(:,i-1);
        end
    end
%    Tsoil = (Tsoil1 + Tsoil2)/2;
Tsoil=sw_incoming.*NaN;
    
elseif sitecode == 5 || sitecode == 6 % Ponderosa pine or Mixed conifer
    for i=1:ncol;
        if strcmp('T107_C_Avg(1)',headertext(i)) == 1
            Tsoil_2cm_1 = data(:,i-1);
        elseif strcmp('T107_C_Avg(2)',headertext(i)) == 1
            Tsoil_2cm_2 = data(:,i-1);
        elseif strcmp('T107_C_Avg(3)',headertext(i)) == 1
            Tsoil_6cm_1 = data(:,i-1);
        elseif strcmp('T107_C_Avg(4)',headertext(i)) == 1
            Tsoil_6cm_2 = data(:,i-1);
        end
    end
    Tsoil_2cm = (Tsoil_2cm_1 + Tsoil_2cm_2)/2;
    Tsoil_6cm = (Tsoil_6cm_1 + Tsoil_6cm_2)/2;
    Tsoil = Tsoil_2cm;
    
elseif sitecode == 7 % Texas Freeman
    for i=1:ncol;
        if strcmp('Tsoil_Avg(2)',headertext(i)) == 1
            open_5cm = data(:,i-1);
        elseif strcmp('Tsoil_Avg(3)',headertext(i)) == 1
            open_10cm = data(:,i-1);
        elseif strcmp('Tsoil_Avg(5)',headertext(i)) == 1
            Mesquite_5cm = data(:,i-1);
        elseif strcmp('Tsoil_Avg(6)',headertext(i)) == 1
            Mesquite_10cm = data(:,i-1);
        elseif strcmp('Tsoil_Avg(8)',headertext(i)) == 1
            Juniper_5cm = data(:,i-1);
        elseif strcmp('Tsoil_Avg(9)',headertext(i)) == 1
            Juniper_10cm = data(:,i-1);
        end
    end
    if year2 == 2005 % juniper probes on-line after 5/19/05
        % before 5/19
        canopy_5cm = Mesquite_5cm(find(decimal_day < 139.61));
        canopy_10cm = Mesquite_10cm(find(decimal_day < 139.61));
        % after 5/19
        canopy_5cm(find(decimal_day >= 139.61)) = (Mesquite_5cm(find(decimal_day >= 139.61)) + Juniper_5cm(find(decimal_day >= 139.61)))/2;
        canopy_10cm(find(decimal_day >= 139.61)) = (Mesquite_10cm(find(decimal_day >= 139.61)) + Juniper_10cm(find(decimal_day >= 139.61)))/2;
        % clean strange 0 values
        canopy_5cm(find(canopy_5cm == 0)) = NaN;
        canopy_10cm(find(canopy_10cm == 0)) = NaN;
        Tsoil = (open_5cm + canopy_5cm)./2;
    else
        canopy_5cm = (Mesquite_5cm + Juniper_5cm)/2;
        canopy_10cm = (Mesquite_10cm + Juniper_10cm)/2;
        Tsoil = (open_5cm + canopy_5cm)/2;
    end
    
    elseif sitecode == 10 || sitecode == 11
       Tsoil=sw_incoming.*NaN;
       soil_heat_flux_1 =sw_incoming.*NaN;
       soil_heat_flux_2 =sw_incoming.*NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Radiation corrections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% grassland
if sitecode == 1
    if year2 == 2007
        % this is the wind correction factor for the Q*7 used before ??/??      
        for i = 1:5766
            if NR_tot(1) < 0
                NR_tot(i) = NR_tot(i)*11.42*((0.00174*wnd_spd(i)) + 0.99755);
            elseif NR_tot(1) > 0
                NR_tot(i) = NR_tot(i)*8.99*(1 + (0.066*0.2*wnd_spd(i))/(0.066 + (0.2*wnd_spd(i))));
            end
        end
        
        % calibration and unit conversion into W per m^2 for CNR1 variables
        % >> for first couple of weeks the program had one incorrect
        % conversion factor (163.66)
        sw_incoming(find(decimal_day > 156.71 & decimal_day < 162.52)) = sw_incoming(find(decimal_day > 156.71 & decimal_day < 162.52))./163.66.*(1000./8.49);
        sw_outgoing(find(decimal_day > 156.71 & decimal_day < 162.52)) = sw_outgoing(find(decimal_day > 156.71 & decimal_day < 162.52))./163.66.*(1000./8.49);
        lw_incoming(find(decimal_day > 156.71 & decimal_day < 162.52)) = lw_incoming(find(decimal_day > 156.71 & decimal_day < 162.52))./163.66.*(1000./8.49); 
        lw_outgoing(find(decimal_day > 156.71 & decimal_day < 162.52)) = lw_outgoing(find(decimal_day > 156.71 & decimal_day < 162.52))./163.66.*(1000./8.49);
        % then afterward it had a different one (136.99)
        sw_incoming(find(decimal_day > 162.67)) = sw_incoming(find(decimal_day > 162.67)).*(1000./8.49)./136.99; 
        sw_outgoing = sw_outgoing.*(1000./8.49)./136.99;
        lw_incoming = lw_incoming.*(1000./8.49)./136.99;
        lw_outgoing = lw_outgoing.*(1000./8.49)./136.99;
        % temperature correction just for long-wave
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; 
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4;
        % calculate new net radiation values
        NR_lw = lw_incoming - lw_outgoing; 
        NR_sw = sw_incoming - sw_outgoing;
        NR_tot = NR_lw + NR_sw;
        % calibration correction for the li190
        Par_Avg(find(decimal_day > 162.14)) = Par_Avg(find(decimal_day > 162.14)).*1000./(5.7*0.604);
        % estimate par from sw_incoming
        Par_Avg(find(decimal_day < 162.15)) = sw_incoming(find(decimal_day < 162.15)).*2.025 + 4.715;        
        
    elseif year2 == 2008 || year2 == 2009
        % calibration correction for the li190
        Par_Avg = Par_Avg.*1000./(5.7*0.604);
        % calibration and unit conversion into W per m^2 for CNR1 variables
        % and adjust for program error
        sw_incoming = sw_incoming./136.99.*(1000./8.49);
        sw_outgoing = sw_outgoing./136.99.*(1000./8.49);
        lw_incoming = lw_incoming./136.99.*(1000./8.49); 
        lw_outgoing = lw_outgoing./136.99.*(1000./8.49);
        % temperature correction just for long-wave
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4;
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4;
        % calculate new net radiation values
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;        
    end
    
%%%%%%%%%%%%%%%%% shrubland 
elseif sitecode == 2    
    if year2 == 2007
        % was this a Q*7 through the big change on 5/30/07? need updated
        % calibration
        for i = 1:6816
            if NR_tot(1) < 0
                NR_tot(i) = NR_tot(i)*10.74*((0.00174*wnd_spd(i)) + 0.99755);
            elseif NR_tot(1) > 0
                NR_tot(i) = NR_tot(i)*8.65*(1 + (0.066*0.2*wnd_spd(i))/(0.066 + (0.2*wnd_spd(i))));
            end
        end
      
        % calibration and unit conversion into W per m^2 for CNR1 variables
        % >> for first couple of weeks the program had one incorrect
        % conversion factor (163.66)
        sw_incoming(find(decimal_day >= 150.75 & decimal_day < 162.44)) = sw_incoming(find(decimal_day >= 150.75 & decimal_day < 162.44))./163.66.*(1000./12.34);
        sw_outgoing(find(decimal_day >= 150.75 & decimal_day < 162.44)) = sw_outgoing(find(decimal_day >= 150.75 & decimal_day < 162.44))./163.66.*(1000./12.34);
        lw_incoming(find(decimal_day >= 150.75 & decimal_day < 162.44)) = lw_incoming(find(decimal_day >= 150.75 & decimal_day < 162.44))./163.66.*(1000./12.34); 
        lw_outgoing(find(decimal_day >= 150.75 & decimal_day < 162.44)) = lw_outgoing(find(decimal_day >= 150.75 & decimal_day < 162.44))./163.66.*(1000./12.34);
        % >> then afterward it had a different one (136.99)
        sw_incoming(find(decimal_day > 162.44)) = sw_incoming(find(decimal_day > 162.44))./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2
        sw_outgoing = sw_outgoing./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2
        lw_incoming = lw_incoming./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2
        lw_outgoing = lw_outgoing./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2        
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave        
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave 
        
        % calculate new net radiation values
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot(find(decimal_day >= 150.75)) = NR_lw(find(decimal_day >= 150.75)) + NR_sw(find(decimal_day >= 150.75)); 
        NR_tpt(find(decimal_day >= 150.75 & isnan(NR_sw)==1)) = NaN;
        
        % calibration correction for the li190
        Par_Avg(find(decimal_day > 150.729)) = Par_Avg(find(decimal_day > 150.729)).*1000./(6.94*0.604);
        % estimate par from sw_incoming
        Par_Avg(find(decimal_day < 150.729)) = sw_incoming(find(decimal_day < 150.729)).*2.0292 + 3.6744;
        
    elseif year2 == 2008
        % calibration and unit conversion into W per m^2 for CNR1 variables
        sw_incoming = sw_incoming./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2
        sw_outgoing = sw_outgoing./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2
        lw_incoming = lw_incoming./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2
        lw_outgoing = lw_outgoing./136.99.*(1000./12.34); % adjust for program error and convert into W per m^2        
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave        
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;
        % calibration correction for the li190
        Par_Avg = Par_Avg.*1000./(6.94*0.604);        
    end

%%%%%%%%%%%%%%%%% juniper savanna
elseif sitecode == 3 
    if year2 == 2007
        % calibration and unit conversion into W per m^2 for CNR1 variables
        sw_incoming = sw_incoming./163.666.*(1000./6.9); % convert into W per m^2
        sw_outgoing = sw_outgoing./163.666.*(1000./6.9); % convert into W per m^2
        lw_incoming = lw_incoming./163.666.*(1000./6.9); % convert into W per m^2
        lw_outgoing = lw_outgoing./163.666.*(1000./6.9); % convert into W per m^2        
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;
        % calibration for par-lite
        Par_Avg = Par_Avg.*1000./5.48;
    elseif year2 == 2008
        % calibration and unit conversion into W per m^2 for CNR1 variables
        sw_incoming = sw_incoming./163.666.*(1000./6.9); % convert into W per m^2
        sw_outgoing = sw_outgoing./163.666.*(1000./6.9); % convert into W per m^2
        lw_incoming = lw_incoming./163.666.*(1000./6.9); % convert into W per m^2
        lw_outgoing = lw_outgoing./163.666.*(1000./6.9); % convert into W per m^2        
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;
        % calibration for par-lite
        Par_Avg = Par_Avg.*1000./5.48;
    end
    
% all cnr1 variables for jsav need to be (value/163.666)*144.928

%%%%%%%%%%%%%%%%% pinyon juniper
elseif sitecode == 4
    if year2 == 2007
        % this is the wind correction factor for the Q*7
        NR_tot(find(NR_tot < 0)) = NR_tot(find(NR_tot < 0)).*10.74.*((0.00174.*wnd_spd(find(NR_tot < 0))) + 0.99755);
        NR_tot(find(NR_tot > 0)) = NR_tot(find(NR_tot > 0)).*8.65.*(1 + (0.066.*0.2.*wnd_spd(find(NR_tot > 0)))./(0.066 + (0.2.*wnd_spd(find(NR_tot > 0)))));
        % now correct pars
        Par_Avg = NR_tot.*2.7828 + 170.93; % see notes on methodology (PJ) for this relationship
        sw_incoming = Par_Avg.*0.4577 - 1.8691; % see notes on methodology (PJ) for this relationship
        NR_lw = lw_incoming - lw_outgoing; 
        NR_sw = sw_incoming - sw_outgoing;

    elseif year2 == 2008
        % this is the wind correction factor for the Q*7
        NR_tot(find(decimal_day < 172 & NR_tot < 0)) = NR_tot(find(decimal_day < 172 & NR_tot < 0)).*10.74.*((0.00174.*wnd_spd(find(decimal_day < 172 & NR_tot < 0))) + 0.99755);
        NR_tot(find(decimal_day < 172 & NR_tot > 0)) = NR_tot(find(decimal_day < 172 & NR_tot > 0)).*8.65.*(1 + (0.066.*0.2.*wnd_spd(find(decimal_day < 172 & NR_tot > 0)))./(0.066 + (0.2.*wnd_spd(find(decimal_day < 172 & NR_tot > 0)))));
        % now correct pars
        Par_Avg(find(decimal_day < 42.6)) = NR_tot(find(decimal_day < 42.6)).*2.7828 + 170.93;
        % calibration for par-lite installed on 2/11/08
        Par_Avg(find(decimal_day > 42.6)) = Par_Avg(find(decimal_day > 42.6)).*1000./5.51;
        sw_incoming(find(decimal_day < 172)) = Par_Avg(find(decimal_day < 172)).*0.4577 - 1.8691;
        % calculate new net radiation values
        NR_lw = lw_incoming - lw_outgoing; 
        NR_sw = sw_incoming - sw_outgoing;
        NR_tot(find(decimal_day > 171.5)) = NR_lw(find(decimal_day > 171.5)) + NR_sw(find(decimal_day > 171.5));  
    elseif year2 == 2009 || year2 == 2010
        % calibration for par-lite installed on 2/11/08
        Par_Avg = Par_Avg.*1000./5.51;
        % calculate new net radiation values
        NR_lw = lw_incoming - lw_outgoing; 
        NR_sw = sw_incoming - sw_outgoing;
        NR_tot = NR_lw + NR_sw;
    end

%%%%%%%%%%%%%%%%% ponderosa pine
elseif sitecode == 5
    if year2 == 2007
        % radiation values apparently already calibrated and unit-converted
        % in progarm for valles sites
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave        
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;
        % calibration for par-lite sensor
        Par_Avg = Par_Avg.*1000./5.25;
    elseif year2 == 2008 || year2 == 2009
        % radiation values apparently already calibrated and unit-converted
        % in progarm for valles sites
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave        
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;
        % calibration for par-lite sensor
        Par_Avg = Par_Avg.*1000./5.25;
    end
    
%%%%%%%%%%%%%%%%% mixed conifer
elseif sitecode == 6
    if year2 == 2006 || year2 == 2007
        % calibration and unit conversion into W per m^2 for CNR1 variables
        % cnr1 installed and working on 8/1/08
%         sw_incoming(find(decimal_day > 214.75)) = sw_incoming(find(decimal_day > 214.75)).*(1000./9.96); % convert into W per m^2
%         sw_outgoing(find(decimal_day > 214.75)) = sw_outgoing(find(decimal_day > 214.75)).*(1000./9.96); % convert into W per m^2
%         lw_incoming(find(decimal_day > 214.75)) = lw_incoming(find(decimal_day > 214.75)).*(1000./9.96); % convert into W per m^2
%         lw_outgoing(find(decimal_day > 214.75)) = lw_outgoing(find(decimal_day > 214.75)).*(1000./9.96); % convert into W per m^2        
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave        
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;        
        
    elseif year2 == 2008 || year2 == 2009
        % radiation values apparently already calibrated and unit-converted
        % in progarm for valles sites   
        lw_incoming = lw_incoming + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave
        lw_outgoing = lw_outgoing + 0.0000000567.*(Tdry).^4; % temperature correction just for long-wave        
        NR_lw = lw_incoming - lw_outgoing; % calculate new net long wave
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        NR_tot = NR_lw + NR_sw;
        % calibration for par-lite sensor
        Par_Avg = Par_Avg.*1000./5.65;
        
    end
    
%%%%%%%%%%%%%%%%% texas
elseif sitecode == 7
    if year2 == 2007 || year2 == 2006
        % wind corrections for the Q*7
        NR_tot(find(NR_tot < 0)) = NR_tot(find(NR_tot < 0)).*10.91.*((0.00174.*wnd_spd(find(NR_tot < 0))) + 0.99755);
        NR_tot(find(NR_tot > 0)) = NR_tot(find(NR_tot > 0)).*8.83.*(1 + (0.066.*0.2.*wnd_spd(find(NR_tot > 0)))./(0.066 + (0.2.*wnd_spd(find(NR_tot > 0)))));

        % no long-wave data for TX
        lw_incoming(1:datalength,1) = NaN;
        lw_outgoing(1:datalength,1) = NaN;
        % pyrronometer corrections
        sw_incoming = sw_incoming.*1000./27.34;
        sw_outgoing = sw_outgoing.*1000./19.39;
        NR_sw = sw_incoming - sw_outgoing; % calculate new net short wave
        % calculate new net long wave from total net minus sw net
        NR_lw = NR_tot - NR_sw;
        % calibration for the li-190 par sensor - sensor had many high
        % values, so delete all values above 6.5 first
        Par_Avg(find(Par_Avg > 6.5)) = NaN;
        Par_Avg = Par_Avg.*1000./(6.16.*0.604);
    elseif year2 == 2008
        % par switch to par-lite on ??
        NR_lw = lw_incoming - lw_outgoing; 
        NR_sw = sw_incoming - sw_outgoing;
        NR_tot = NR_lw + NR_sw;
    end
    

%%%%%%%%%%%%%%%%% PJ girdle Most calibrations etc in logger program
elseif sitecode == 10
        % calculate new net radiation values
        NR_lw = lw_incoming - lw_outgoing; 
        NR_sw = sw_incoming - sw_outgoing;
        NR_tot = NR_lw + NR_sw;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up filters for co2 and make a master flag variable (decimal_day_nan)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

decimal_day_nan = decimal_day;
record = 1:1:length(fc_raw_massman_wpl);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iteration 1 - run and plot fluxes with the following four filters with
% all other filters commented out, then evaluate the ustar cutoff with
% figure (1).  Use the plot to decide which ustar bin on the x-axis is the
% cutoff, and then use the printed out vector on the main screen to decide
% what the ustar value is for that bin.  That's the number you enter into
% the site-specific info above.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Number of co2 flux periods removed due to:');
% Original number of NaNs
nanflag = find(isnan(fc_raw_massman_wpl));
removednans = length(nanflag);
decimal_day_nan(nanflag) = NaN;
record(nanflag) = NaN;
disp(sprintf('    original empties = %d',removednans));

% % Remove values during precipitation
precipflag = find(precip > 0);
removed_precip = length(precipflag);
decimal_day_nan(precipflag) = NaN;
record(precipflag) = NaN;
disp(sprintf('    precip = %d',removed_precip));

% Remove for behind tower wind direction
windflag = find(wnd_dir_compass > wind_min & wnd_dir_compass < wind_max);
removed_wind = length(windflag);
decimal_day_nan(windflag) = NaN;
record(windflag) = NaN;
disp(sprintf('    wind direction = %d',removed_wind));

% Remove night-time negative fluxes
nightnegflag = find((hour >= 22 | hour <= 5) & fc_raw_massman_wpl < 0);
removed_nightneg = length(nightnegflag);
decimal_day_nan(nightnegflag) = NaN;
record(nightnegflag) = NaN;
disp(sprintf('    night-time negs = %d',removed_nightneg));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PPINE EXTRA WIND DIRECTION REMOVAL
% ppine has super high night respiration when winds come from ~ 50 degrees, so these must be excluded also:
if sitecode == 5
    ppine_night_wind = find((wnd_dir_compass > 30 & wnd_dir_compass < 65) & (hour <= 9 | hour > 18));
    removed_ppine_night_wind = length(ppine_night_wind);
    decimal_day_nan(ppine_night_wind) = NaN;
    record(ppine_night_wind) = NaN;
    disp(sprintf('    ppine night winds = %d',removed_ppine_night_wind));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gland 2007 had large fluxes for very cold temperatures early in the year.
if sitecode == 1 && year2 == 2007
    gland_cold = find(Tdry < 271);
    removed_gland_cold = length(gland_cold);
    decimal_day_nan(gland_cold) = NaN;
    record(gland_cold) = NaN;
    disp(sprintf('    gland cold = %d',removed_gland_cold));
end

% Plot out to see and determine ustar cutoff
if iteration == 1    
    u_star_2 = u_star(find(~isnan(decimal_day_nan)));
    fc_raw_massman_wpl_2 = fc_raw_massman_wpl(find(~isnan(decimal_day_nan)));
    hour_2 = hour(find(~isnan(decimal_day_nan)));

    ustar_bin = 1:1:30; % you can change this to have more or less categories
    for i = 1:30 % you can change this to have more or less categories
        if i == 1
            startbin(i) = 0;
        elseif i >= 2
            startbin(i) = (i - 1)*0.01;
        end
        endbin(i) = 0.01 + startbin(i);    
        elementstouse = find((u_star_2 > startbin(i) & u_star_2 < endbin(i)) & (hour_2 > 22 | hour_2 < 5));
        co2mean(i) = mean(fc_raw_massman_wpl_2(elementstouse));
    end

    startbin

    figure(1); clf;
    plot(ustar_bin,co2mean,'.r');
    shg;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iteration 2 - Now that you have entered a ustar cutoff in the site
% options above, run with iteration 2 to see the effect of removing those
% values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iteration > 1
    
    % Remove values with low U*
    ustarflag = find(u_star < ustar_lim);
    removed_ustar = length(ustarflag);
    decimal_day_nan(ustarflag) = NaN;
    record(ustarflag) = NaN;
    
    % display pulled ustar
    disp(sprintf('    u_star = %d',removed_ustar));
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iteration 3 - now that values have been filtered for ustar, decide what
% the min and max co2 flux values should be by examining figure 2 and then
% entering them in the site options above, then run program with iteration
% 3 and see the effect of removing them in figure 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
if iteration > 2
    
    if sitecode == 5
        removed_maxs_mins=0;
        for i = 1:12
                maxminflag = find((month==i & fc_raw_massman_wpl> co2_max_by_month(i)) | (month ==i & fc_raw_massman_wpl < co2_min) | fc_raw_massman_wpl == 0); 
                removed_maxs_mins = removed_maxs_mins+length(maxminflag);
                decimal_day_nan(maxminflag) = NaN;
                record(maxminflag) = NaN;
        end
    else
    % Pull out maxs and mins
    maxminflag = find(fc_raw_massman_wpl > co2_max | fc_raw_massman_wpl < co2_min); 
    removed_maxs_mins = length(maxminflag);
    decimal_day_nan(maxminflag) = NaN;
    record(maxminflag) = NaN;
    end
    
    % display what is pulled for maxs and mins
    disp(sprintf('    above max or below min = %d',removed_maxs_mins));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Iteration 4 - Now examine the effect of high and low co2 filters by
% running program with iteration 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
if iteration > 3
    
    figure; plot(CO2_mean,'.'); ylim([300 450])
    
    
    % Remove high CO2 concentration points
    highco2flag = find(CO2_mean > 410);
    removed_highco2 = length(highco2flag);
    decimal_day_nan(highco2flag) = NaN;
    record(highco2flag) = NaN;

    % Remove low CO2 concentration points
    lowco2flag = find(CO2_mean <300);
    removed_lowco2 = length(lowco2flag);
    decimal_day_nan(lowco2flag) = NaN;
    record(lowco2flag) = NaN;
    
    % display what's pulled for too high or too low co2
    disp(sprintf('    low co2 = %d',removed_lowco2));
    disp(sprintf('    high co2 = %d',removed_highco2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Iteration 5 - Now clear out the last of the outliers by running iteration
% 5, which removes values outside a running standard deviation window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if iteration > 4
    % Remove values outside of a running standard deviation
    std_bin = zeros(1,24);
    bin_length = round(length(fc_raw_massman_wpl)/24);
    for i = 1:24
        if i == 1
            startbin = 1;
        elseif i >= 2
            startbin = (i * bin_length);
        end    
        endbin = bin_length + startbin;
        elementstouse = find(record > startbin & record <= endbin & isnan(record) == 0);
        std_bin(i) = std(fc_raw_massman_wpl(elementstouse));
        mean_flux(i) = mean(fc_raw_massman_wpl(elementstouse));
        bin_index = find(abs(fc_raw_massman_wpl(elementstouse)) > ...
            (5*std_bin(i) + mean_flux(i)));
        outofstdnan = elementstouse(bin_index);
        decimal_day_nan(outofstdnan) = NaN;
        record(outofstdnan) = NaN;
        running_nans(i) = length(outofstdnan);
        removed_outofstdnan = sum(running_nans);
    end   
    
    disp(sprintf('    above or below 3X running standard deviation = %d',removed_outofstdnan));

end % close if statement for iterations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the co2 flux for the whole series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2); clf;
hold on; box on;
plot(decimal_day,fc_raw_massman_wpl,'or');
plot(decimal_day(find(~isnan(decimal_day_nan))),fc_raw_massman_wpl(find(~isnan(decimal_day_nan))),'.b');
xlabel('decimal day'); ylabel('co2 flux');
hold off; shg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter for sensible heat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% max and mins for HSdry
HS_flag = find(HSdry > HS_max | HSdry < HS_min);
HSdry(HS_flag) = NaN;
% remove HS data when raining, use existing precipflag variable
HSdry(precipflag) = NaN;
% remove HS data with low ustar, use existing ustarflag variable
if iteration > 1
    HSdry(ustarflag) = NaN;
    removed_HS = length(find(isnan(HSdry)));
end

% max and mins for HSdry_massman
HSmass_flag = find(HSdry_massman > HSmass_max | HSdry_massman < HSmass_min);
HSdry_massman(HSmass_flag) = NaN;
% remove HS data when raining, use existing precipflag variable
HSdry_massman(precipflag) = NaN;
% remove HS data with low ustar, use existing ustarflag variable
HSdry_massman(ustarflag) = NaN;
removed_HSmass = length(find(isnan(HSdry_massman)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter for max's and min's for other variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% QC for HL_raw
LH_flag = find(HL_raw > LH_max | HL_raw < LH_min);
removed_LH = length(LH_flag);
HL_raw(LH_flag) = NaN;

% QC for HL_wpl_massman
LH_flag = find(HL_wpl_massman > LH_max | HL_wpl_massman < LH_min);
removed_LH_wpl_mass = length(LH_flag);
HL_wpl_massman(LH_flag) = NaN;

% QC for sw_incoming

% QC for Tdry
Tdry_flag = find(Tdry > Tdry_max | Tdry < Tdry_min);
removed_Tdry = length(Tdry_flag);
Tdry(Tdry_flag) = NaN;

% QC for Tsoil

% QC for rH
rH_flag = find(rH > rH_max | rH < rH_min);
removed_rH = length(rH_flag);
rH(rH_flag) = NaN;

% QC for h2o mean values
h2o_flag = find(H2O_mean > h2o_max | H2O_mean < h2o_min);
removed_h2o = length(h2o_flag);
H2O_mean(h2o_flag) = NaN;

% QC for atmospheric pressure
press_flag = [] %find(atm_press > press_max | atm_press < press_min);
removed_press = length(press_flag);
atm_press(press_flag) = NaN;

% min/max QC for TX soil heat fluxes
if sitecode == 7
    if year2 == 2005
        soil_heat_flux_open(find(soil_heat_flux_open > 100 | soil_heat_flux_open < -50)) = NaN;
        soil_heat_flux_mescan(find(soil_heat_flux_mescan > 50 | soil_heat_flux_mescan < -40)) = NaN;
        soil_heat_flux_juncan(find(soil_heat_flux_juncan > 50 | soil_heat_flux_juncan < -60)) = NaN;
    elseif year2 == 2006
        soil_heat_flux_open(find(soil_heat_flux_open > 90 | soil_heat_flux_open < -60)) = NaN;
        soil_heat_flux_mescan(find(soil_heat_flux_mescan > 50 | soil_heat_flux_mescan < -50)) = NaN;
        soil_heat_flux_juncan(find(soil_heat_flux_juncan > 50 | soil_heat_flux_juncan < -60)) = NaN;        
    elseif year2 == 2007 
        soil_heat_flux_open(find(soil_heat_flux_open > 110 | soil_heat_flux_open < -50)) = NaN;
        soil_heat_flux_mescan(find(soil_heat_flux_mescan > 40 | soil_heat_flux_mescan < -40)) = NaN;
        soil_heat_flux_juncan(find(soil_heat_flux_juncan > 20 | soil_heat_flux_juncan < -40)) = NaN;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print to screen the number of removals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp(sprintf('number of co2 flux values pulled in post-process = %d',(filelength_n-sum(~isnan(record)))));
disp(sprintf('number of co2 flux values used = %d',sum(~isnan(record))));
disp(' ');
disp('Values removed for other qcd variables');
disp(sprintf('    number of latent heat values removed = %d',removed_LH));
disp(sprintf('    number of massman&wpl-corrected latent heat values removed = %d',removed_LH_wpl_mass));
disp(sprintf('    number of sensible heat values removed = %d',removed_HS));
disp(sprintf('    number of massman-corrected sensible heat values removed = %d',removed_HSmass));
disp(sprintf('    number of temperature values removed = %d',removed_Tdry));
disp(sprintf('    number of relative humidity values removed = %d',removed_rH));
disp(sprintf('    number of mean water vapor values removed = %d',removed_h2o));
disp(sprintf('    number of atm press values removed = %d',removed_press));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%WRITE FILE FOR ONLINE GAP-FILLING PROGRAM (REICHSTEIN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qc = ones(datalength,1);
qc(find(isnan(decimal_day_nan))) = 2;
NEE = fc_raw_massman_wpl; NEE(find(isnan(decimal_day_nan))) = -9999;
LE = HL_wpl_massman; LE(find(isnan(decimal_day_nan))) = -9999;
H_dry = HSdry_massman; H_dry(find(isnan(decimal_day_nan))) = -9999;
Tair = Tdry - 273.15;


if write_gap_filling_out_file == 1;
    if (sitecode>7 && sitecode<10) % || 9);
    disp('writing gap-filling file...')
    header = {'day' 'month' 'year' 'hour' 'minute' 'qcNEE' 'NEE' 'LE' 'H' 'Rg' 'Tair' 'Tsoil' 'rH' 'precip' 'Ustar'};
    sw_incoming=ones(size(qc)).*-999;
    Tsoil=ones(size(qc)).*-999;
    datamatrix = [day month year hour minute qc NEE LE H_dry sw_incoming Tair Tsoil rH precip u_star];
    for n = 1:datalength
        for k = 1:15;
            if isnan(datamatrix(n,k)) == 1;
                datamatrix(n,k) = -9999;
            else
            end
        end
    end
    outfilename = strcat(outfolder,filename,'_for_gap_filling')
    xlswrite(outfilename, header, 'data', 'A1');
    xlswrite(outfilename, datamatrix, 'data', 'A2');
    else    
    disp('writing gap-filling file...')
    header = {'day' 'month' 'year' 'hour' 'minute' 'qcNEE' 'NEE' 'LE' 'H_dry' 'Rg' 'Tair' 'Tsoil' 'rH' 'precip' 'Ustar'};
    datamatrix = [day month year hour minute qc NEE LE H_dry sw_incoming Tair Tsoil rH precip u_star];
    for n = 1:datalength
        for k = 1:15;
            if isnan(datamatrix(n,k)) == 1;
                datamatrix(n,k) = -9999;
            else
            end
        end
    end
    outfilename = strcat(outfolder,filename,'_for_gap_filling')
    xlswrite(outfilename, header, 'data', 'A1');
    xlswrite(outfilename, datamatrix, 'data', 'A2');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%WRITE COMPLETE OUT-FILE  (FLUX_all matrix with bad values removed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clean the co2 flux variables
fc_raw(find(isnan(decimal_day_nan))) = NaN;
fc_raw_massman(find(isnan(decimal_day_nan))) = NaN;
fc_water_term(find(isnan(decimal_day_nan))) = NaN;
fc_heat_term_massman(find(isnan(decimal_day_nan))) = NaN;
fc_raw_massman_wpl(find(isnan(decimal_day_nan))) = NaN;

% clean the h2o flux variables
E_raw(find(isnan(decimal_day_nan))) = NaN;
E_raw_massman(find(isnan(decimal_day_nan))) = NaN;
E_water_term(find(isnan(decimal_day_nan))) = NaN;
E_heat_term_massman(find(isnan(decimal_day_nan))) = NaN;
E_wpl_massman(find(isnan(decimal_day_nan))) = NaN;

% clean the co2 concentration
CO2_mean(find(isnan(decimal_day_nan))) = NaN;

if write_complete_out_file == 1;
    disp('writing qc file...')
    
    if sitecode == 5 || sitecode == 6 
%         header2 = {'timestamp','year','month','day','hour','minute','second','jday','iok','agc_Avg',...
%             'wnd_dir_compass','wnd_spd','CO2_mean','CO2_std','H2O_mean','H2O_std',...
%             'fc_raw','fc_raw_massman','fc_water_term','fc_heat_term_massman','fc_raw_massman_wpl',...
%             'E_raw','E_raw_massman','E_water_term','E_heat_term_massman','E_wpl_massman',...
%             'HSdry','HSdry_massman','HL_raw','HL_wpl_massman',...
%             'Tdry','air_temp_hmp','Tsoil_2cm','Tsoil_6cm','precip','atm_press','rH'...
%             'Par_Avg','sw_incoming','sw_outgoing','lw_incoming','lw_outgoing','NR_sw','NR_lw','NR_tot'};
%         datamatrix2 = [year,month,day,hour,minute,second,jday,iok,agc_Avg,...
%             wnd_dir_compass,wnd_spd,CO2_mean,CO2_std,H2O_mean,H2O_std,...        
%             fc_raw,fc_raw_massman,fc_water_term,fc_heat_term_massman,fc_raw_massman_wpl,...
%             E_raw,E_raw_massman,E_water_term,E_heat_term_massman,E_wpl_massman,...
%             HSdry,HSdry_massman,HL_raw,HL_wpl_massman,...
%             Tdry,air_temp_hmp,Tsoil_2cm,Tsoil_6cm,precip,atm_press,rH...
%             Par_Avg,sw_incoming,sw_outgoing,lw_incoming,lw_outgoing,NR_sw,NR_lw,NR_tot];
        header2 = {'timestamp','year','month','day','hour','minute','second','jday','iok','agc_Avg','u_star',...
            'wnd_dir_compass','wnd_spd','CO2_mean','CO2_std','H2O_mean','H2O_std',...
            'fc_raw','fc_raw_massman','fc_water_term','fc_heat_term_massman','fc_raw_massman_wpl',...
            'E_raw','E_raw_massman','E_water_term','E_heat_term_massman','E_wpl_massman',...
            'HSdry','HSdry_massman','HL_raw','HL_wpl_massman',...
            'Tdry','air_temp_hmp','Tsoil_2cm','Tsoil_6cm','VWC_2cm','precip','atm_press','rH'...
            'Par_Avg','sw_incoming','sw_outgoing','lw_incoming','lw_outgoing','NR_sw','NR_lw','NR_tot'};    
        datamatrix2 = [year,month,day,hour,minute,second,jday,iok,agc_Avg,u_star,...
            wnd_dir_compass,wnd_spd,CO2_mean,CO2_std,H2O_mean,H2O_std,...        
            fc_raw,fc_raw_massman,fc_water_term,fc_heat_term_massman,fc_raw_massman_wpl,...
            E_raw,E_raw_massman,E_water_term,E_heat_term_massman,E_wpl_massman,...
            HSdry,HSdry_massman,HL_raw,HL_wpl_massman,...
            Tdry,air_temp_hmp,Tsoil_2cm,Tsoil_6cm,VWC,precip,atm_press,rH...
            Par_Avg,sw_incoming,sw_outgoing,lw_incoming,lw_outgoing,NR_sw,NR_lw,NR_tot];
           
    elseif sitecode == 7
        header2 = {'timestamp','year','month','day','hour','minute','second','jday','iok','agc_Avg','u_star',...
            'wnd_dir_compass','wnd_spd','CO2_mean','CO2_std','H2O_mean','H2O_std',...
            'fc_raw','fc_raw_massman','fc_water_term','fc_heat_term_massman','fc_raw_massman_wpl',...
            'E_raw','E_raw_massman','E_water_term','E_heat_term_massman','E_wpl_massman',...
            'HSdry','HSdry_massman','HL_raw','HL_wpl_massman',...
            'Tdry','air_temp_hmp','Tsoil','canopy_5cm','canopy_10cm','open_5cm','open_10cm',...
            'soil_heat_flux_open','soil_heat_flux_mescan','soil_heat_flux_juncan','precip','atm_press','rH'...
            'Par_Avg','sw_incoming','sw_outgoing','lw_incoming','lw_outgoing','NR_sw','NR_lw','NR_tot'};    
        datamatrix2 = [year,month,day,hour,minute,second,jday,iok,agc_Avg,u_star,...
            wnd_dir_compass,wnd_spd,CO2_mean,CO2_std,H2O_mean,H2O_std,...        
            fc_raw,fc_raw_massman,fc_water_term,fc_heat_term_massman,fc_raw_massman_wpl,...
            E_raw,E_raw_massman,E_water_term,E_heat_term_massman,E_wpl_massman,...
            HSdry,HSdry_massman,HL_raw,HL_wpl_massman,...
            Tdry,air_temp_hmp,Tsoil,canopy_5cm,canopy_10cm,open_5cm,open_10cm,...
            soil_heat_flux_open,soil_heat_flux_mescan,soil_heat_flux_juncan,precip,atm_press,rH...
            Par_Avg,sw_incoming,sw_outgoing,lw_incoming,lw_outgoing,NR_sw,NR_lw,NR_tot];
        
%     elseif sitecode == 8
%         header2 = {'timestamp','year','month','day','hour','minute','second','jday','iok','u_star',...
%             'wnd_dir_compass','wnd_spd','CO2_mean','CO2_std','H2O_mean','H2O_std',...
%             'fc_raw','fc_raw_massman','fc_water_term','fc_heat_term_massman','fc_raw_massman_wpl',...
%             'E_raw','E_raw_massman','E_water_term','E_heat_term_massman','E_wpl_massman',...
%             'HSdry','HSdry_massman','HL_raw','HL_wpl_massman',...
%             'Tdry','air_temp_hmp','precip','atm_press','rH'};    
%         datamatrix2 = [year,month,day,hour,minute,second,jday,iok,u_star,...
%             wnd_dir_compass,wnd_spd,CO2_mean,CO2_std,H2O_mean,H2O_std,...        
%             fc_raw,fc_raw_massman,fc_water_term,fc_heat_term_massman,fc_raw_massman_wpl,...
%             E_raw,E_raw_massman,E_water_term,E_heat_term_massman,E_wpl_massman,...
%             HSdry,HSdry_massman,HL_raw,HL_wpl_massman,...
%             Tdry,air_temp_hmp,precip,atm_press,rH];
        
     elseif sitecode == 8 || sitecode == 9
        header2 = {'timestamp','year','month','day','hour','minute','second','jday','iok','u_star',...
            'wnd_dir_compass','wnd_spd','CO2_mean','CO2_std','H2O_mean','H2O_std',...
            'fc_raw','fc_raw_massman','fc_water_term','fc_heat_term_massman','fc_raw_massman_wpl',...
            'E_raw','E_raw_massman','E_water_term','E_heat_term_massman','E_wpl_massman',...
            'HSdry','HSdry_massman','HL_raw','HL_wpl_massman',...
            'Tdry','air_temp_hmp','precip','atm_press','rH'};  
        %atm_press=ones(size(precip)).*-999;
        %air_temp_hmp=ones(size(precip)).*-999;
        datamatrix2 = [year,month,day,hour,minute,second,jday,iok,u_star,...
            wnd_dir_compass,wnd_spd,CO2_mean,CO2_std,H2O_mean,H2O_std,...        
            fc_raw,fc_raw_massman,fc_water_term,fc_heat_term_massman,fc_raw_massman_wpl,...
            E_raw,E_raw_massman,E_water_term,E_heat_term_massman,E_wpl_massman,...
            HSdry,HSdry_massman,HL_raw,HL_wpl_massman,...
            Tdry,air_temp_hmp,precip,atm_press,rH];
    
    else
        header2 = {'timestamp','year','month','day','hour','minute','second','jday','iok','agc_Avg','u_star',...
            'wnd_dir_compass','wnd_spd','CO2_mean','CO2_std','H2O_mean','H2O_std',...
            'fc_raw','fc_raw_massman','fc_water_term','fc_heat_term_massman','fc_raw_massman_wpl',...
            'E_raw','E_raw_massman','E_water_term','E_heat_term_massman','E_wpl_massman',...
            'HSdry','HSdry_massman','HL_raw','HL_wpl_massman',...
            'Tdry','air_temp_hmp','Tsoil','soil_heat_flux_1','soil_heat_flux_2','precip','atm_press','rH'...
            'Par_Avg','sw_incoming','sw_outgoing','lw_incoming','lw_outgoing','NR_sw','NR_lw','NR_tot'};    
        datamatrix2 = [year,month,day,hour,minute,second,jday,iok,agc_Avg,u_star,...
            wnd_dir_compass,wnd_spd,CO2_mean,CO2_std,H2O_mean,H2O_std,...        
            fc_raw,fc_raw_massman,fc_water_term,fc_heat_term_massman,fc_raw_massman_wpl,...
            E_raw,E_raw_massman,E_water_term,E_heat_term_massman,E_wpl_massman,...
            HSdry,HSdry_massman,HL_raw,HL_wpl_massman,...
            Tdry,air_temp_hmp,Tsoil,soil_heat_flux_1,soil_heat_flux_2,precip,atm_press,rH...
            Par_Avg,sw_incoming,sw_outgoing,lw_incoming,lw_outgoing,NR_sw,NR_lw,NR_tot];
    end

    outfilename = strcat(outfolder,filename,'_qc')
    xlswrite(outfilename,header2,'data','A1');
    xlswrite(outfilename,datamatrix2,'data','B2');
    xlswrite(outfilename,timestamp,'data','A2');
    
    if iteration > 4
        
        if sitecode == 8 || sitecode == 9
            numbers_removed = [removednans removed_precip removed_wind removed_nightneg removed_ustar ...
            removed_maxs_mins removed_lowco2 removed_highco2 removed_outofstdnan NaN ...
            (filelength_n-sum(~isnan(record))) sum(~isnan(record))...
            removed_LH removed_LH_wpl_mass removed_HS removed_HSmass ...
            removed_Tdry removed_rH removed_h2o];
            removals_header = {'Original nans','Precip periods','Bad wind direction','Night-time negs','Low ustar',...
            'Over max or min','Low co2','High co2','Outside running std','',...
            'Total co2 pulled','Total retained',...
            'LH values removed','LH with WPL/Massman removed','HS removed','HS with massman removed',...
            'Temp removed','Rel humidity removed','Water removed'};
            xlswrite(outfilename,numbers_removed','numbers removed','B1');
            xlswrite (outfilename, removals_header', 'numbers removed', 'A1');
        else
            numbers_removed = [removednans removed_precip removed_wind removed_nightneg removed_ustar ...
            removed_maxs_mins removed_lowco2 removed_highco2 removed_outofstdnan NaN ...
            (filelength_n-sum(~isnan(record))) sum(~isnan(record))...
            removed_LH removed_LH_wpl_mass removed_HS removed_HSmass ...
            removed_Tdry removed_rH removed_h2o removed_press];
            removals_header = {'Original nans','Precip periods','Bad wind direction','Night-time negs','Low ustar',...
            'Over max or min','Low co2','High co2','Outside running std','',...
            'Total co2 pulled','Total retained',...
            'LH values removed','LH with WPL/Massman removed','HS removed','HS with massman removed',...
            'Temp removed','Rel humidity removed','Water removed','Pressure removed'};
            xlswrite(outfilename,numbers_removed','numbers removed','B1');
            xlswrite (outfilename, removals_header', 'numbers removed', 'A1');
        end
    end
    
    
    if iteration > 6
    
%         header2 = {'timestamp','year','month','day','hour','minute','second','jday','iok','agc_Avg',...
%             'wnd_dir_compass','wnd_spd','CO2_mean','CO2_std','H2O_mean','H2O_std',...
%             'fc_raw','fc_raw_massman','fc_water_term','fc_heat_term_massman','fc_raw_massman_wpl',...
%             'E_raw','E_raw_massman','E_water_term','E_heat_term_massman','E_wpl_massman',...
%             'HSdry','HSdry_massman','HL_raw','HL_wpl_massman',...
%             'Tdry','air_temp_hmp','Tsoil_2cm','Tsoil_6cm','precip','atm_press','rH'...
%             'Par_Avg','sw_incoming','sw_outgoing','lw_incoming','lw_outgoing','NR_sw','NR_lw','NR_tot'};
%         datamatrix2 = [year,month,day,hour,minute,second,jday,iok,agc_Avg,...
%             wnd_dir_compass,wnd_spd,CO2_mean,CO2_std,H2O_mean,H2O_std,...        
%             fc_raw,fc_raw_massman,fc_water_term,fc_heat_term_massman,fc_raw_massman_wpl,...
%             E_raw,E_raw_massman,E_water_term,E_heat_term_massman,E_wpl_massman,...
%             HSdry,HSdry_massman,HL_raw,HL_wpl_massman,...
%             Tdry,air_temp_hmp,Tsoil_2cm,Tsoil_6cm,precip,atm_press,rH...
%             Par_Avg,sw_incoming,sw_outgoing,lw_incoming,lw_outgoing,NR_sw,NR_lw,NR_tot];
  
time_out=fix(clock);
time_out=datestr(time_out);

sname={'Site name: Test'};
email={'Email: andyfox@unm.edu'};
timeo={'Created: ',time_out};
    outfilename = strcat(outfolder,filename,'_AF.xls');
    xlswrite(outfilename,sname,'data','A1');
    xlswrite(outfilename,email,'data','A2');
    xlswrite(outfilename,timeo,'data','A3');
    xlswrite(outfilename,header2,'data','A4');
    xlswrite(outfilename,header2,'data','A5');
    xlswrite(outfilename,header2,'data','A6');    
    end
end