function make_fluxproc_comparison( sitecode, date_start, date_end, varargin )

[ this_year, ~, ~ ] = datevec( now );
% -----
% define optional inputs, with defaults and typechecking
% -----
args = inputParser;
args.addRequired( 'sitecode', @(x) ( isintval( x ) | isa( x, 'UNM_sites' ) ) );
args.addRequired( 'date_start', ...
               @(x) ( all( x >= 2006 ) ) );
args.addRequired( 'date_end', ...
               @(x) ( all( x <= now ) ) );
args.addOptional('irgacompare', false , @islogical); 

% parse required and optional inputs
args.parse( sitecode, date_start, date_end, varargin{ : } );
sitecode = args.Results.sitecode;
date_start = args.Results.date_start;
date_end = args.Results.date_end;
irgacompare = args.Results.irgacompare;


[year,~,~,~,~,~]=datevec(date_start);

if irgacompare
    if sitecode ~= UNM_sites.SLand || sitecode ~= UNM_sites.MCon_SS
        fprintf('%s does not have a closed path IRGA. IRGA comparison aborted' ,...
            char(sitecode));
        return
    end
    type = 'irga';
    %Get filenames for processed 7200 data. Might be good to start
    %processing 7200 data automatically in EP for New MCon and SLand
    fnames72 = list_files(fullfile('C:','Research_Flux_Towers',...
        'SiteData',char(sitecode),...
        'ep_data'),'ep_SLand_7200_.*(\.csv$)' ); 
    fnames75 = list_files(fullfile('C:','Research_Flux_Towers',...
        'SiteData',char(sitecode),...
        'ep_data'),'ep_SLand_\d\d\d\d_\d\d_\d\d_\d\d\d\d.*(\.csv$)' ); 
    %FIME, find regex for sussing out 7500 files (line above)
    
    % make datenums for the dates and sort
    dns = tstamps_from_filenames( fnames72 );
    [ dns, idx ] = sort( dns );
    fnames72 = fnames72( idx );
    % find the files that are within the date range requested
    idx = find( ( dns >= date_start ) & ( dns <= date_end ) );
    % Include last file before the start date in case it includes data
    % within the date range
    idx = [min(idx)-1 idx];
    fnames72 = fnames72 ( idx ); 
    %fmt = 'dd mmm yyyy HH:MM';
    %fprintf( 1, ['reading EddyPro files:\n',repmat('%s\n',1,numel(idx)),'\n\t'],fnames72(:));
    % Get data tables from closed-past analyzer (Li-Cor 7200)
    
    T72 = table();
    for i = 1:numel(fnames72)
    %FIXME This is pretty slow, is there a better way to do this?
    temp = eddypro_2_table(char(fnames72(i))); 
    T72 = table_foldin_data(temp, T72);
    end
    
    % Get data tables from open-path analyzer (Li-Cor 7500)
    % Repeat same steps as above
    dns = tstamps_from_filenames( fnames75 );
    [ dns, idx ] = sort( dns );
    fnames75 = fnames72( idx );
    idx = find( ( dns >= date_start ) & ( dns <= date_end ) );
    idx = [min(idx)-1 idx];
    fnames75 = fnames72 ( idx ); 
    T75 = table ();
    for i = 1:numel(fnames75)
    temp = eddypro_2_table(char(fnames75(i))); 
    T75 = table_foldin_data(temp, T75);
    end
    
    %FIXME The figure maker below will use a table called T, so 7200 and
    %7500 eddypro output tables should be combined (outerjoin? inner join?)
    %so that all variables are there. They will be suffixed with _1 or _2
    %by matlab. 
    
    %IRGA comparisons are made using EddyPro Outputs, so both tables have
    %the same var names. FIXME - maybe start putting irga2 from eddypro in
    %fluxall.
    ep_var = {'un_co2_flux' 'co2_flux',...
    'un_H', 'H',...
    'un_LE' 'LE',...
    'un_h2o_flux' 'h2o_flux'};
   % ts_72 = T = 
else  %Otherwise, just go ahead and compare NMEG vs EP
    type = 'fluxproc';
    T = parse_fluxall_txt_file(sitecode, year );
    nmeg_var = {'Fc_raw' 'Fc_raw_massman_ourwpl',...
        'SensibleHeat_dry' 'HSdry_massman', ...
        'LatentHeat_raw' 'LatentHeat_wpl_massman', ...
        'E_raw' 'E_raw_massman'};
    ep_var = {'un_co2_flux' 'co2_flux',...
        'un_H', 'H',...
        'un_LE' 'LE',...
        'un_h2o_flux' 'h2o_flux'};
    ts = T.timestamp;
end
%Access variable names through any table T

% Discard data outside of requested time period
discard_idx = ( ( T.timestamp < date_start ) | ...
                ( T.timestamp > date_end ) ); 
T( discard_idx, : ) = [];



for i=1:length(nmeg_var)+4;
    if i <= 8
        NMEGvar = nmeg_var(i); % NMEG REFERENCE FOR ACCESSING TABLE
        EPvar = ep_var((i));   % EP REFERENCE FOR ACCESSING TABLE
        varname = char(nmeg_var(i));
        h(i) = ...
            plot_bivariate_comparison( T{:,NMEGvar}, T{:,EPvar}, ts, type, ...
            'fig_name', varname, 'sitecode', sitecode );
    elseif i==9 %FCcorrected - FCraw
        NMEGvar = T{:,nmeg_var(2)} - T{:,nmeg_var(1)}; 
        EPvar = T{:,ep_var(2)} - T{:,ep_var(1)};
        varname = 'FC raw - FC corrected';
        h(i) = ...
            plot_bivariate_comparison( NMEGvar, EPvar, ts, type, ...
            'fig_name', varname, 'sitecode', sitecode );
    elseif i==10 %Hcorrected - Hraw
        NMEGvar = T{:,nmeg_var(4)} - T{:,nmeg_var(3)}; 
        EPvar = T{:,ep_var(4)} - T{:,ep_var(3)};
        varname = 'H raw - H corrected';
        h(i) = ...
            plot_bivariate_comparison( NMEGvar, EPvar, ts, type, ...
            'fig_name', varname, 'sitecode', sitecode );
    elseif i==11 %LEcorrected - LEraw
        NMEGvar = T{:,nmeg_var(6)} - T{:,nmeg_var(5)}; 
        EPvar = T{:,ep_var(6)} - T{:,ep_var(5)};
        varname = 'LE raw - LE corrected';
        h(i) = ...
            plot_bivariate_comparison( NMEGvar, EPvar, ts, type, ...
            'fig_name', varname, 'sitecode', sitecode );
    elseif i==12 %h2o_cor - h2o_raw
        NMEGvar = T{:,nmeg_var(8)} - T{:,nmeg_var(7)}; 
        EPvar = T{:,ep_var(8)} - T{:,ep_var(7)};
        varname = 'h2o raw - h2o cor ';
        h(i) = ...
            plot_bivariate_comparison( NMEGvar, EPvar, ts, type, ...
            'fig_name', varname, 'sitecode', sitecode );
    end
end
%    savefig( h , fullfile( getenv('FLUXROOT'),'SiteData', ...
%        sitecode,'fluxcompare_plots',num2str(year) ) )