years = 2009:2013;
sitecode = UNM_sites.PJ;
filetype = 'gapfilled';
creator = 'cdiac'; % cdiac = Files found on cdiac server

% Choose the directory
if strcmp('greg', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'FluxOut', 'AF_files_Reichstein_current' );
elseif strcmp('tim', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'Ameriflux_files', 'ftp_ameriflux' );
elseif strcmp('cdiac', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'Ameriflux_files', 'cdiac_level1' );
end

% Get site configuration
conf = parse_yaml_config( 'SiteVars', sitecode );

% Set up the figure window
fig1 = figure( 'Name', sprintf('%s Rg monthly timeseries - %s', ...
    get_site_name(sitecode), creator), ...
    'Position', [230 250 1570 750], 'Visible', 'on' );
subplotR = 2;
subplotC = length( years );
% We need to add or subtract a small percentage of each subplot x position
% to make them space out the right way (took some tweaking)
figXpos = linspace(-.09, 0.015, subplotC);

siteinfo = UNM_sites_info(sitecode);
afname = siteinfo.ameriflux;

for i = 1:length(years);
    % Load the file for each year in years
    year = years( i );
    filename = sprintf('%s_%d_%s.txt', afname, year, filetype);
    try
        af = parse_ameriflux_file([dirname '\' filename]);
        % Calculate a decimal day (for fingerprint plotter)
        af.hmstring = num2str(af.HRMIN, '%04u');
        af.hr = str2num(af.hmstring(:, 1:2));
        af.min = str2num(af.hmstring(:,3:4));
        af.decHR = af.hr + af.min/60;
        af.decDOY = af.DOY + (af.hr/24 + af.min/(60*24));
    catch
        warning([dirname filename ' not found']);
        % make an artificial timestamp and data column
        af = dataset();
        af.decDOY = linspace(1, 366 - 30/(60*24), 17520)';
        af.decHR = repmat( linspace(.5, 24, 48)', 365, 1 );
        af.Rg = (1:17520)';
        af.PAR = (1:17520)';
    end
    
    % Also make a Summer solstice dataset for Rg and PAR
    tstart = 171; % June 20
    tend = 191; % July 10
    tsolNoon = datevec(datenum(year, 7, 1));
    solCalcs = noaa_solar_calculations( conf.latitude, conf.longitude, ...
        tsolNoon );
    solCalcs = solCalcs * 24;
    afSubset = af(af.decDOY >= tstart & af.decDOY <= tend, :);
    
    % Group based on decHR and then accumarray with mean
    times = unique(afSubset.decHR);
    [lia, groups] = ismember(afSubset.decHR, times);
    indices = [groups ones(size(groups))];
    %sums = accumarray(indices, afSubset.Rg);
    meanRg = accumarray(indices, afSubset.Rg, ...
        [numel(unique(groups)) 1], @mean);
    meanPAR = accumarray(indices, afSubset.PAR, ...
        [numel(unique(groups)) 1], @mean);
    
    
    % The top row is for Rg plots
    plotSequence = i;
    plotTitle = sprintf( 'Rg - %d', year );
    
    newax1 = subplot( subplotR, subplotC, plotSequence );
    xlim([1 24]);
    ylim([-5 1500]);
    hold on;
    for j = tstart:tend
        dayData = af( floor( af.decDOY ) == j, :);
        plot(dayData.decHR, dayData.Rg, '.k');
    end
    plot([12, 12], [-5, 1500], '-k');
    plot([solCalcs(1), solCalcs(1)], [-5, 1500], '--r');
    plot([solCalcs(2), solCalcs(2)], [-5, 1500], ':r');
    plot([solCalcs(3), solCalcs(3)], [-5, 1500], ':r');
    plot( times, meanRg, '-og' );
    % This is where subplot position adjustment happens
    set(gca, 'Position', get(gca, 'Position') + [figXpos(i), 0, .05, .03])
    title(plotTitle);
    if plotSequence > 1;
        set(newax1, 'YTickLabel', [])
    end
    
    % The bottom row is for PAR plots
    plotSequence = i + length( years );
    plotTitle = sprintf( 'PAR - %d', year );

    newax2 = subplot( subplotR, subplotC, plotSequence );
    xlim([1 24]);
    ylim([-5 3000]);
    hold on;
    for j = tstart:tend
        dayData = af( floor( af.decDOY ) == j, :);
        plot(dayData.decHR, dayData.PAR, '.k');
        
    end
    plot([12, 12], [-5, 3000], '-k');
    plot([solCalcs(1), solCalcs(1)], [-5, 3000], '--r');
    plot([solCalcs(2), solCalcs(2)], [-5, 3000], ':r');
    plot([solCalcs(3), solCalcs(3)], [-5, 3000], ':r');
    plot(times, meanPAR, '-og');
    set(gca, 'Position', get(gca, 'Position') + [figXpos(i), 0, .05, .03])
    title(plotTitle);
    if plotSequence > 1 + length( years );
        set(newax2, 'YTickLabel', [])
    end
end

suptitle([get_site_name(sitecode) ' ' filetype ' ' creator]);