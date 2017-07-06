yearlist = 2007:2016;
sitecode = UNM_sites.JSav;
for i = 1:length(yearlist)
    year = yearlist( i );
    if i == 1
        fluxall_T = parse_fluxall_qc_file(sitecode, year  );
       % T_soil = dealwithheaders( fluxall_T , sitecode ) ;
    else
        fluxall_T_to_append = parse_fluxall_qc_file( sitecode, year  );
        fluxall_T = table_append_common_vars(fluxall_T,fluxall_T_to_append);
        
       % T_soil_to_append = dealwithheaders( fluxall_T , sitecode ) ;
       % T_soil = table_append_common_vars(T_soil , T_soil_to_append);
    end
end

for i = 1:length(yearlist)
    year = yearlist( i );
    if i == 1
        T_soil = parse_soilmet_qc_file(sitecode, year  );
    else
        T_soil_to_append = parse_soilmet_qc_file( sitecode, year  );
        T_soil = table_append_common_vars(T_soil , T_soil_to_append);
    end
end
T_soil.timestamp = datenum([T_soil.year,T_soil.month,T_soil.day,T_soil.hour,T_soil.min,T_soil.second]);

 % RBD
 % Get SHF column namaes
    [cols_shf_corr, ts_loc] = regexp_header_vars( T_soil, 'shf|SHF' );
    % Remove SHF values > 200 < -150
    data = table2array( T_soil );
    subset = data( :, ts_loc );
    bad_ts = subset > 200 | subset < -170;
    subset( bad_ts ) = NaN;
    data( :, ts_loc ) = subset;
    T_soil = array2table( data, ...
        'VariableNames', T_soil.Properties.VariableNames );
    
    displaynames = cellfun(@char, cols_shf_corr,'UniformOutput',false);
% compare 2009 to 2015 to see if there is an obvious multiplication factor

 plot(T_soil.timestamp,T_soil{:,cols_shf_corr});datetick;dynamicDateTicks;legend(displaynames)

% Get the unique days, and their indices
[uniqueDays,idxToUnique,idxFromUniqueBackToAll] = unique(floor(T_old.timestamp));

dailyMeanOld = accumarray(idxFromUniqueBackToAll,T_old.SHF_O1_AVG,[],@nanmean);
[fitresultdPJ ,gofdPJ ] = createFit(uniqueDays, dailyMeanOld, false );

dailyMeanNew = accumarray(idxFromUniqueBackToAll,T_new.SHF_O1_AVG,[],@nanmean);
[fitresultdPJG ,gofdPJG ] = createFit(uniqueDays, dailyMeanNew, false );

dailyDiff = dailyMeanOld - dailyMeanPJG;
[fitresultdiffPJ, gofdiffPJ] = createFit(uniqueDays, dailyDiff ,false );

sca
    plot(fitresultdPJ,uniqueDays,dailyMeanOld,'.') ;hold on
    plot(fitresultdPJG, uniqueDays,dailyMeanPJG , '.' ); 
    ylabel('\mumol m^{-2} s^{-1}')



function T_soil = dealwithheaders( fluxall_T , sitecode )
% -----
% Get soil water content and soil temperature data from fluxall data
% -----

% Get header resolution
% Use sitecode and dataloggerType to find appropriate header resolution file
resFileName = sprintf('%s_HeaderResolution.csv', 'flux');
resFilePathName = fullfile( getenv('FLUXROOT'), 'FluxProcConfig', ...
    'HeaderResolutions', char( sitecode ), resFileName );
res = readtable( resFilePathName );
    
% Get soil data from fluxall
% First find QC headers matching regexp
re_soil = '[Ss][Ww][Cc]|SOILT|SHF|TCAV';
res_idx = find( ~cellfun( @isempty, regexp( res.qc_mapping, re_soil )));
% Index CURRENT headers in fluxall that match these QC headers
fluxall_idx = ismember(res.current( res_idx ), fluxall_T.Properties.VariableNames);
% Extract indexed soil columns from the fluxall table
T_soil = fluxall_T( :, res.current( res_idx( fluxall_idx) ) );
% Sometimes regexp acts weird and cuts up fluxall header variables and the
% code does not pick up any columns. Throw an error here
if isempty(T_soil)
    error('Header Resolution Mapping failed')
    return
end
% Rename extracted soil columns with the qc_mapping names
T_soil.Properties.VariableNames = res.qc_mapping( res_idx( fluxall_idx) );

% Get SHF and TCAV data column names
[cols_shf, ~] = regexp_header_vars( T_soil, 'SHF|shf' );

T_soil = [ fluxall_T( :, {'year', 'month', 'day', 'hour', 'min', 'second'}), ...
    T_soil( : ,cols_shf )];
end