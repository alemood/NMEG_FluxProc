function [ filtered_array, flag ] = noise_filter( array_in, ...
                                                   filter_windows, ...
                                                   showfig ,...
                                                   varargin )                                             
% filter windows is in observation timesteps (usually 30 minutes)

% Initialize the output array and remove-data flag
if isa( array_in, 'table' );
    filtered_array = table2array( array_in );
    colname = array_in.Properties.VariableNames{1};
else
    filtered_array = array_in;
end
flag = repmat( false, length( filtered_array ), 1 );

% Initialize the figure to plot to
if length( varargin ) > 0
    fig_title = sprintf( '%s %d median filter', ...
        get_site_name( varargin{1} ), varargin{2} );
elseif exist('colname')
    fig_title = sprintf('%s Noise filter',colname);
else
    fig_title = 'Noise Filter';
end

if showfig
h_fig1 = figure( 'Name', fig_title, ...
    'Position', [150 150 1050 550], 'Visible', 'on' );
hold on;
% Colors and legend strings for plotting
colors = { '.r', '.m', '.b', '.y', '.g', '.c' };
leg_strings = {};
 % Plot the raw array
    plot( 1:length( filtered_array ), filtered_array, colors{1} );
    leg_string{ 1 } = sprintf( 'Raw Data' );
end

% Loop through each filter window and filter/plot
[r ,c ] = size( filter_windows);
for i=1:r;
    
    window = filter_windows(i,:);
      
    % Filter the array
    threshold = []; %not needed right now for noise filter
    [ filtered_array, rem_idx ] = filterseries( filtered_array, ...
        'noisy', window, threshold, true, false );
    
    % Plot the previously filtered array for contrast and add legend
    if showfig
    plot( 1:length( filtered_array ), filtered_array, colors{i+1} );
    leg_string{ i + 1 } = sprintf( 'Window = %1.1f', window );
    end
  
    
    % Add remove indices to std_flag
    flag = flag | rem_idx;
end
    
% Plot final points
if showfig
plot( 1:length( filtered_array ), filtered_array, '.k' );
leg_string{ i + 2 } = 'Filtered data';
legend( leg_string, 'Location', 'SouthWest' );
end

% If needed, convert back to table
if isa( array_in, 'table' );
    filtered_array = array2table( filtered_array, ...
        'VariableNames', array_in.Properties.VariableNames );
end                                               
