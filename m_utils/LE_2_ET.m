% LE_2_ET - Convert 30min latent heat flux to ET ( W/m^2 to mm/s ) and sum (integrate)
%     for each 30min period. Note that this method uses the full day of ET,
%     rather than just daytime values

setenv('UNCERTAIN','C:\Users\alex\Desktop\uncertainty_output\Daily');
setenv('AFLX','C:\Code\NMEG_utils\processed_data\daily_aflx\FLUXNET2015_c');
% Ameriflux sitelist 
sitelist={'US-Seg', 'US-Ses','US-Wjs', 'US-Mpj' , 'US-Vcp' ,'US-Vcm'};
yearlist=( 2007:2016 );
convert2mm = false; % I believe the Keenan uncertainty files are in mm already.
parseKeenan = false;
% ------------- LOAD FILES------------------
for i = 1:length(sitelist)
    if parseKeenan
        for j = 1:length(yearlist)
            site = sitelist{i}; year = yearlist(j);
            fname = fullfile(getenv('UNCERTAIN'),strrep(site,'US-',''),...
                strcat( site ,'_',num2str(year),'_gapfilled_df.csv') );
            t{ j, i } = text_2_table(fname ,'n_header_lines',1);
        end
    end
    % Now ameriflux files
    fname= fullfile( getenv('AFLX'),strcat(site,'_daily_aflx.csv') );
    aflx_t{i} = parse_aflx_daily_file(fname);
end

% ----------- MAKE TABLES ------------------------
Mpg = vertcat(t{ :, 1 } );
Mpg = replace_badvals( Mpg , -9999 , 1 );
Mpj = vertcat(t{ :, 2 } );
Mpj = replace_badvals( Mpj , -9999 , 1 );
% Create matlab timestamp
Mpg.timestamp = datenum(Mpg.Year, 1 , 0 ) + Mpg.DOY;
Mpj.timestamp = datenum(Mpj.Year, 1 , 0 ) + Mpj.DOY;

if convert2mm
% -------------
% GIRDLE CALCS
% ------------
% Calculate latent heat of vaporization 
Mpg.Lv = ( 2.501 - 0.00237 * ( Mpg.TA_f ) ) .* 10^3;
et_mms = ( 1 \ ( Mpg.Lv .* 1000 )) .* Mpg.LEf;
% Integrate over full day
Mpg.ET_mm_int = et_mms;

% Calculate for uncertainties
etu_mms = ( 1 \( Mpg.Lv * 1000 )) .* Mpg.LEu;
% Integrate over full day
Mpg.ETu_mm_int = etu_mms;


% -------------
% CONTROL CALCS
% ------------
% Calculate latent heat of vaporization 
Mpj.Lv = ( 2.501 - 0.00237 * ( Mpj.TA_f ) ) .* 10^3;
et_mms = ( 1 / ( Mpj.Lv * 1000 )) .* Mpg.LEf;
% Integrate over full day
Mpj.ET_mm_int = et_mms.*86400;

% Calculate for uncertainties
etu_mms = ( 1 / ( Mpj.Lv * 1000 )) .* Mpj.LEu;
% Integrate over full day
Mpj.ETu_mm_int = etu_mms;
end
wyarray = [{datenum(2009,1,1) datenum(2009, 9, 30 )};
            {datenum(2009, 10 , 1) datenum(2010, 9 , 30)};
            {datenum(2010, 10 , 1) datenum(2011, 9 , 30)};
            {datenum(2011, 10 , 1) datenum(2012, 9 , 30)}];
% CUMULATIVE LE FOR PJ GIRDLE
for j = 1:length(yearlist)
    t_start = wyarray{ j , 1 };
    t_end = wyarray{ j , 2 };
    [colname colid] = regexp_header_vars(Mpg,'LE');
    idx = Mpg.timestamp >= t_start & Mpg.timestamp <= t_end;
    LEaccumPJG(j , :) = max(cumsum([Mpg.LEf(idx),Mpg.LEu(idx)] ,'omitnan'));
end
% CUMULATIVE LE FOR PJ CONTROL
for j = 1:length(yearlist)
    t_start = wyarray{ j , 1 };
    t_end = wyarray{ j , 2 };
    [colname colid] = regexp_header_vars(Mpj,'LE');
    idx = Mpj.timestamp >= t_start & Mpj.timestamp <= t_end;
    LEaccumPJC(j , :) = max(cumsum([Mpj.LEf(idx),Mpj.LEu(idx)] ,'omitnan'));
end

% -------------------------------------------------------------------------
%                  DEAL WITH AFLX DAILY FILES 
% -------------------------------------------------------------------------

Mpg = vertcat(aflx_t{ :, 1 } );
Mpg = replace_badvals( Mpg , -9999 , 1 );
Mpj = vertcat(aflx_t{ :, 2 } );
Mpj = replace_badvals( Mpj , -9999 , 1 );

for j = 1:length(yearlist)
    t_start = wyarray{ j , 1 };
    t_end = wyarray{ j , 2 };
    [colname colid] = regexp_header_vars(Mpg,'LE');
    idx = Mpg.TIMESTAMP >= t_start & Mpg.TIMESTAMP <= t_end;
    LEaccumPJG_aflx(j , :) = max(cumsum([Mpg.ET_mm_dayint(idx),Mpg.ET_mm_dayint_unc(idx)] ,'omitnan'));
end
% CUMULATIVE LE FOR PJ CONTROL
for j = 1:length(yearlist)
    t_start = wyarray{ j , 1 };
    t_end = wyarray{ j , 2 };
    [colname colid] = regexp_header_vars(Mpj,'LE');
    idx = Mpj.TIMESTAMP >= t_start & Mpj.TIMESTAMP <= t_end;
    LEaccumPJC_aflx(j , :) = max(cumsum([Mpj.ET_mm_dayint(idx),Mpj.ET_mm_dayint_unc(idx)] ,'omitnan'));
end

all_accum_le =...
    horzcat([2009:2012]',LEaccumPJC, LEaccumPJG , LEaccumPJC_aflx ,LEaccumPJG_aflx)

cumulativeLEmm = array2table( all_accum_le , ...
    'VariableNames',{'WaterYear' 'LEf_Mpj', 'LEun_Mpj','LEf_Mpg','LEun_Mpg',...
    'LEf_daytime_Mpj', 'LEunsd_Mpj','LEf_daytime_Mpg','LEunsd_Mpg' } );

fname = fullfile(getenv('FLUXROOT'),'cumulative_LE_mm_WY2009-WY2012.txt');
writetable( cumulativeLEmm, fname, 'delimiter',',','WriteRowNames',true);
        
%[uniqueYears,idxToUnique,idxFromUniqueBackToAll] = unique(Mpg.Year);
% cumulativeLE = accumarray(idxFromUniqueBackToAll,Mpg.LEf,[],@nanmean);
%cumulativeLE = accumarray(idxFromUniqueBackToAll,Mpg.LEf,[],@cumsum);
    



