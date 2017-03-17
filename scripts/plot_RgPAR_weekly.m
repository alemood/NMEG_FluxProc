years = 2009:2013;
sitecode = 'US-Mpj';
filetype = 'with_gaps';
creator = 'tim'; % cdiac = Files found on cdiac server

% Choose the directory
if strcmp('greg', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'FluxOut', 'AF_files_Reichstein_current' );
elseif strcmp('tim', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'Ameriflux_files', 'ftp_ameriflux' );
elseif strcmp('cdiac', lower(creator))
    dirname = fullfile(getenv('FLUXROOT'), 'Ameriflux_files', 'cdiac_level1' );
end

% Set up the figure window
fig1 = figure( 'Name', sprintf('%s Rg monthly timeseries - %s', ...
    sitecode, creator), ...
    'Position', [230 250 1570 750], 'Visible', 'on' );
subplotR = 2;
subplotC = length( years );
% We need to add or subtract a small percentage of each subplot x position
% to make them space out the right way (took some tweaking)
figXpos = linspace(-.09, 0.015, subplotC);

for i = 1:length(years);
    % Load the file for each year in years
    year = years( i );
    filename = sprintf('%s_%d_%s.txt', sitecode, year, filetype);
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
        af.Rg = (1:17520)';
        af.PAR = (1:17520)';
    end
    
    % The top row is for Rg plots
    plotSequence = i;
    plotTitle = sprintf( 'Rg - %d', year );
    
    newax1 = subplot( subplotR, subplotC, plotSequence );
    xlim([1 24]);
    ylim([-5 1500]);
    hold on;
    for j = 1:365
        dayData = af(af.DOY==j, :);
        plot(dayData.decHR, dayData.Rg, '.b');
        plot([12, 12], [-5, 1500], '--r');
    end
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
    for j = 1:365
        dayData = af(af.DOY==j, :);
        plot(dayData.decHR, dayData.PAR, '.k');
        plot([12, 12], [-5, 3000], '--r');
    end
    set(gca, 'Position', get(gca, 'Position') + [figXpos(i), 0, .05, .03])
    title(plotTitle);
    if plotSequence > 1 + length( years );
        set(newax2, 'YTickLabel', [])
    end
end

suptitle([sitecode ' ' filetype ' ' creator ' ']);