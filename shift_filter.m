function [ filtered_array, flag ] = shift_filter( array_in, ...
                                                   filter_windows, ...
                                                   tol,...
                                                   showfig,...
                                                   varargin )                                             
% filter windows is in observation timesteps (usually 30 minutes)

% Initialize the output array and remove-data flag
if isa( array_in, 'table' );
    filtered_array = table2array( array_in );
else
    filtered_array = array_in;
end
flag = repmat( false, length( filtered_array ), 1 );

% Initialize the figure to plot to
if length( varargin ) > 0
    fig_title = sprintf( '%s %d median filter', ...
        get_site_name( varargin{1} ), varargin{2} );
else
    fig_title = 'Shift filter';
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
for i=1:length( filter_windows );
    
    window = filter_windows( i );
      
    % Filter the array
     %not needed right now for noise filter
    [ filtered_array, rem_idx ] = filterseries( filtered_array, ...
        'shift', [], tol, true, false );
    
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
