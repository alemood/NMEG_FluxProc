years = 2009:2013;
sitecode = UNM_sites.PJ;
filetype = 'gapfilled';
creator = 'cdiac'; % cdiac = Files found on cdiac server

siteInfo = UNM_sites_info( sitecode );

% Choose the directory
if strcmp('greg', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'FluxOut', 'AF_files_Reichstein_current' );
elseif strcmp('tim', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'Ameriflux_files', 'ftp_ameriflux' );
elseif strcmp('cdiac', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'Ameriflux_files', 'cdiac_level1' );
end

% Set up the figure window
fig1 = figure( 'Name', sprintf('%s Rg & FC fingerprints - %s', ...
    get_site_name(sitecode), creator), ...
    'Position', [230 250 1570 750], 'Visible', 'on' );
subplotR = 2;
subplotC = length( years );
% We need to add or subtract a small percentage of each subplot x position
% to make them space out the right way (took some tweaking)
figXpos = linspace(-.095, 0.025, subplotC);

for i = 1:length(years);
    % Load the file for each year in years
    year = years( i );
    filename = sprintf('%s_%d_%s.txt', siteInfo.ameriflux, ...
        year, filetype);

    try
        af = parse_ameriflux_file([dirname '\' filename]);
        % Calculate a decimal day (for fingerprint plotter)
        af.hmstring = num2str(af.HRMIN, '%04u');
        af.hr = str2num(af.hmstring(:, 1:2));
        af.min = str2num(af.hmstring(:,3:4));
        af.decDOY = af.DOY + (af.hr/24 + af.min/(60*24));
    catch
        warning([dirname filename ' not found']);
        % make an artificial timestamp and data column
        af = dataset();
        af.decDOY = linspace(1, 366 - 30/(60*24), 17520)';
        af.FC = (1:17520)';
        af.Rg = (1:17520)';
    end
    
    % -----------------------------------------------------------------
    % Get the NOAA solar model results for all the timestamps in either
    % table
    solDates = ( datenum( year, 1, 0):datenum( year, 12, 31 ) )';
    % [Solar noon, theoretical sunrise, theoretical sunset]
    solCalcs = noaa_solar_calculations( ...
        siteInfo.latitude, ...
        siteInfo.longitude, ...
        datevec( solDates ));
    % Convert from day fraction to hours
    solCalcs = solCalcs .* 24;
    solCalcs = [ solCalcs ( solDates - datenum( year, 1, 0 )) ];
    
    % The top row is for Rg fingerprints
    plotSequence = i;
    plotTitle = sprintf( 'Rg - %d', year );
    
    newax1 = subplot( subplotR, subplotC, plotSequence );
    plot_fingerprint( af.decDOY, af.Rg, plotTitle, 'h_fig', fig1, ...
        'h_ax', newax1, 'cmap', colormap('jet'));
    hold on;
    % Plot solar events
    plot([ 12, 12 ], [ 0, 365 ], '-k');
    plot( solCalcs( :, 1 ) , solCalcs( :, 4 ), ...
        ':', 'color', 'k');
    plot( solCalcs( :, 2 ) , solCalcs( :, 4 ), ...
        ':', 'color', [ 0.8 0.8 0.8 ]);
    plot( solCalcs( :, 3 ) , solCalcs( :, 4 ), ...
        ':', 'color', [ 0.8 0.8 0.8 ]);
    % This is where subplot position addjustment happens
    set(gca, 'Position', get(gca, 'Position') + [figXpos(i), 0, .06, .04])
    if plotSequence > 1;
        set(newax1, 'YTickLabel', [])
    end
    
    % The bottom row is for FC fingerprints
    plotSequence = i + length( years );
    plotTitle = sprintf( 'FC - %d', year );
    
    newax2 = subplot( subplotR, subplotC, plotSequence );
    plot_fingerprint( af.decDOY, af.FC, plotTitle, 'h_fig', fig1, ...
        'h_ax', newax2, 'cmap', colormap(flipud(colormap('jet'))));
    hold on;
    % Plot solar events
    plot([ 12, 12 ], [ 0, 365 ], '-k');
    plot( solCalcs( :, 1 ) , solCalcs( :, 4 ), ...
        ':', 'color', [ 0.2 0.2 0.2 ]);
    plot( solCalcs( :, 2 ) , solCalcs( :, 4 ), ...
        ':', 'color', [ 0.2 0.2 0.2 ]);
    plot( solCalcs( :, 3 ) , solCalcs( :, 4 ), ...
        ':', 'color', [ 0.2 0.2 0.2 ]);
    % Adjust subplots again
    set(gca, 'Position', get(gca, 'Position') + [figXpos(i), 0, .06, .04])
    if plotSequence > 1 + length( years );
        set(newax2, 'YTickLabel', [])
    end
end

suptitle([get_site_name( sitecode ) ' ' filetype ' ' creator ' ']);





