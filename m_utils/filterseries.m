function [array, testDiff]  = filterseries(series, type, windowsize, ...
    threshold, ignore_nans, debug_plots)
% filterseries.m
%
% Filters a data series using one of 4 algorithms, then returns a filtered
% timeseries. Descriptions of the filters are below. There is an optional
% plotting routine that can be run (uncomment it first).
%
% **Arguments**
%   1 = input data series
%   2 = 'mean', 'median', 'shift', 'sigma', or 'hampel' filter type
%   3 = windowsize , integer number for the moving window size
%   4 = threshold difference above which datapoint is set to nan
%   5 = ignore_nans, filter around the NaN values then re-insert
%   6 = debug_plots: Plot diagnostic plots for each
%
% WARNING! If NaN's are present in the input series, most filters will
% propagate them by about 2x the window size. Therefore, these calculate 
% statistics based on interpolated data, generated using interpseries.m.
%
% author: Gregory E. Maurer (gregmaurer@unm.edu)
% last updated 5/20/2015

% Moving window size - best to make this an ODD number.
window = windowsize;

if ignore_nans
    dummy = repmat( nan, length(series), 1);
    dummy_test = repmat( false, length(series), 1);
    not_nan = ~isnan( series );
    series = series( not_nan );
end

% MEAN - Filter by difference from the mean
if strcmp(type, 'mean')
    % First interpolate over the missing data in the input series
    series_filled = interpseries(series);
    % Then calculate a running mean with the window size
    runningM = filter(ones(window,1)/window, 1, series_filled);
    % Resulting mean is shifted forward in phase by window/2, shift it back
    runningM = circshift(runningM, -floor(window/2));
    % Find difference from the mean
    diff = series - runningM;
    % Change datapoints more than the threshold value away from the 
    % mean to nan
    filteredSeries = series;
    testDiff = abs(diff) > threshold;
    filteredSeries(testDiff) = nan;

% MEDIAN - Filter by difference from the median. 
% Effective spike removal. Make window odd, and keep around 3-5 so that
% rain events (in the case of SWC) are not screened out.
% Use slidefun.m from MATLAB FEx to calculate median
% MATLAB has a native function medfilt1.m that I'm substituting in
elseif strcmp(type, 'median')
    
    % First interpolate over the missing data in the input series
    series_filled = interpseries(series);
    % Calculate running mean
    medianSeries = medfilt1(series, window );
    % Find difference from the median
    diffSeries = abs(series_filled - medianSeries);
    testDiff = diffSeries;
    % For filtering isolated spikes, plot a histogram to determine this parameter 
    spikes = diffSeries > 0.02;
    % Initialize an array of the fixed signal
    filteredSeries = series;
    % Replace data flagged as spikes with medianSeries
    filteredSeries(spikes) = medianSeries(spikes);
    
%     %--------------vvvvvv---old stuff
%     % Then calculate a running median based on the window size.
%     runningM = slidefun(@median, window, series_filled);
%     % Find difference from the mean
%     diff = series - runningM;
%     % Change datapoints more than the threshold value away from the 
%     % mean to nan
%     filteredSeries = series;
%     testDiff = abs(diff) > threshold;
%     filteredSeries(testDiff) = nan;
%     
% SHIFT - Filter by difference from nearest +/- neighbors;
% Warning - multiplies the NaN's in the original data
elseif strcmp(type, 'shift')
    %Calculate difference from nearest neigboring datapoint
    diff1 = series - circshift(series, 1);
    diff2 = series - circshift(series, -1);
    % Change datapoints more than the threshold value away from the 
    % neighbor to nan
    filteredSeries = series;
    testDiff = abs(diff1) > threshold | abs(diff2) > threshold;
    filteredSeries(testDiff) = nan;

% SIGMA - Filter that removes data using standard deviation of the data.
% Use movingstd.m from MATLAB FEx to calculate StdDev of series
% FIXME - Consider using a running median rather than mean here, see Ron 
% Pearson's ideas about this.
elseif strcmp(type, 'sigma')
    % First fill in the missing data in the input series with 1d
    % interpolation (this should be avoided in some cases)
    series_filled = interpseries(series);
    % Then calculate a running std based on the window size.
    runningStd = movingstd(series_filled, window);
    % This calculation creates complex numbers when the temperature is
    % near zero for extended periods (due to negative numbers in
    % the variance). Give them their real number value (should be 0).
    runningStd = real(runningStd);
    % However, when StDev = 0, which occurs when variability is very low 
    % (in winter), this filter fails because there is a small difference
    % between runningM and the original data. Give the StDev a very
    % small value in this case (but larger than the difference above).
    testzero = runningStd==0;
    runningStd(testzero) = 0.005;
    % Also calculate a running mean and a sigmas vector
    runningM = filter(ones(window,1)/window, 1, series_filled);
    %runningM = medfilt1(series_filled, window);
    %runningM = slidefun(@median, window, series_filled);
    sigmas = threshold * runningStd;
    % Resulting stat is shifted forward in phase by window/2, shift it back
    runningM = circshift(runningM, -floor(window/2));
    % Fix the ends of the running mean
    slen = length(series);
    fix = floor(window/2);
    for i = 1:floor(window/2)
      runningM(i) = mean(series(1:(fix+i)));
      runningM((slen-fix)+i) = mean(series((slen-2*fix+i):slen));
    end
    % Set a hi and low value (# of sigmas from mean) to filter outliers.
    hi = runningM + sigmas;
    lo = runningM - sigmas;
    % Change datapoints beyond the hi/lo thresholds to nan
    filteredSeries = series;
    testDiff = filteredSeries > hi | filteredSeries < lo;
    filteredSeries(testDiff) = nan;

% HAMPEL - Filter using a Hampel filter
% Use hampel.m from MATLAB FEx to filter outliers. This is a complicated
% algorithm, so look at the documentation before changing parameters.
elseif strcmp(type, 'hampel')
    x = (1:length(series))';
    % Hampel filter - parameters are default here, including a window size
    % that is based on the size of the input array, and a threshold value
    % of 3 (for removing outliers).
    [filteredSeries,remove,~,~] = hampel(series,23);
    filteredSeries(remove) = nan;
    
% NOISY filter, so called. Implemented to attempt to screen out very noisy
% periods and then just keep minimum values if there appears to be a
% signal. This probably should be implemented first
elseif strcmp( type, 'noisy' )
    % Calculate vector of moving standard deviation
    stdM = movstd( series, window ); 
    % Find significant changes in the moving std
    change_idx = findchangepts( stdM );%, 'MaxNumChanges',10 );
    fprintf('Found %d significant change(s) in the moving std\n', ...
        length(change_idx));
    % Add the end 
    change_idx = vertcat(change_idx, length( series ) );
    % Subset the moving std and try to automate selection of noisey periods
    % based on range of std
    pointer = 1;
    subsets ={};
    for i = 1: length(change_idx) 
        if i == length(change_idx) 
            subsets{i} = stdM( pointer : end ); 
        else
            subsets{i} = stdM( pointer : change_idx( i ) - 1 );
            pointer = change_idx(i) ;
        end
    end
    % Determine the range of subsets
    stdM_range = cellfun( @(x) range(x), subsets );
    stdM_mean  = cellfun( @(x) mean(x), subsets );
    
    % Super weird and arbitrary selection of noisy areas. Heuristic as hell
    nsy_idx = find( stdM_range > 0.07 | stdM_mean > 0.10 | stdM_range./stdM_mean < 2); 
    fprintf('Filtering %d subsets with std ranges > 0.07 or std means > 0.9\n',length(nsy_idx))
    clear subsets
    % Get a moving minimum noisey intervals The window here will probably vary pit to pit
    % and based on the behavior of the noise. This also may only work when
    % the majority of noise variance is lies above the minimum.
    filteredSeries = series;
    for i = 1:length( nsy_idx )
        subset = [];
        % Extract this noisy period from the raw series
        if nsy_idx( i ) == 1
            subset_idx =  1 : change_idx(nsy_idx( i ) );
        else
        subset_idx = change_idx( nsy_idx( i ) - 1 ) : change_idx( nsy_idx( i ) ) ;
        end
        subset = series( subset_idx );
        % Test to see if noise is complete garbage or not (varies quickly over full
        % range of probe)
%         if range(subset) > 0.40 % trying to set this higher than a rain event, though rain events should make it through
%            %fprintf('>>>>> Data appear to be garbage. Tossing this whole subset <<<<<\n')
%            %fprintf('Range of subset from idx %d-%d > 0.4; %d points removed.\n',...
% %                min(subset_idx),...
% %                max(subset_idx),...
% %                length(subset));
% %            subset(:) = NaN; 
%            
%            fprintf('>>>>> Data appear to be garbage. That is OK for now. <<<<<\n')
%         else % If there is a faint signal in the noise, extract
        % Get moving minimum
        minM = movmin( subset , 21 );
        keep_idx = subset == minM;
        subset( ~keep_idx ) = NaN;
        fprintf('>>>>> Signal may be present! Keeping apparent minimum <<<<<\n')
        fprintf('Removed %d / %d (%1.1f%%) of noisy points\n',...
            sum(~keep_idx), length(subset),...
            sum(~keep_idx)/length(subset) * 100 ); %percentage of pts removed
%         end
        filteredSeries(subset_idx) = subset;
    end
    % testDiff here is just data removed by the movmin filter. These will
    % get removed in the parent function.
    testDiff = ~isfinite(filteredSeries) ;
else
    error('Invalid filter type (mean, median, shift, sigma, noisy, or hampel')
end

if ignore_nans
    dummy( not_nan ) = filteredSeries;
    dummy_test( not_nan ) = testDiff;
    array = dummy;
    testDiff = dummy_test;
else
    array = filteredSeries;
end

% Plot the unfiltered/filtered data and some statistics.
if debug_plots
    h = figure;
    set(h, 'Name', 'Filtering results and intermed. statistics');
    plot(1:length(series), series, '.r', 1:length(filteredSeries), ...
        filteredSeries, '.k', 1:length(runningM), runningM, '.g')
    hold on;
    if strcmp(type, 'sigma')
        plot(1:length(runningStd), runningStd, '-b');
    end
    title(['Threshold = ' num2str(threshold) ' Window = ' num2str(window)]);
    legend('Removed', 'New series', 'M\_stat', 'StDev');
end
