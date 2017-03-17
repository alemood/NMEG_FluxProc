function std_filter_testing(  sitecode, year, series_in )

close all;

days1 = 1.5;
days2 = 3;
days3 = 7;
days4 = 14;

std_devs = 3;

series_days1 = filterseries(series_in, 'sigma', 48*days1, std_devs, false, true );

series_days2 = filterseries(series_in, 'sigma', 48*days2, std_devs, false, true );

series_days3 = filterseries(series_in, 'sigma', 48*days3, std_devs, false, true );

series_days4 = filterseries(series_in, 'sigma', 48*days4, std_devs, false, true );

h1 = figure( 'Name', 'Filtering results and intermed. statistics' );
a1 = subplot(4, 1, 1);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days1), series_days1, '.k');
title( sprintf( 'Threshold = %d sd  Window = %1.1f days', std_devs, days1 ));
legend('Removed', 'New series');

a2 = subplot(4, 1, 2);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days2), series_days2, '.k');
title( sprintf( 'Threshold = %d sd  Window = %d days', std_devs, days2 ));

a3 = subplot(4, 1, 3);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days3), series_days3, '.k');
title( sprintf( 'Threshold = %d sd  Window = %d days', std_devs, days3 ));

a4 = subplot(4, 1, 4);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days4), series_days4, '.k');
title( sprintf( 'Threshold = %d sd  Window = %d days', std_devs, days4 ));



series_days12 = filterseries(series_days1, 'sigma', 48*days2, 3, false, true );

series_days13 = filterseries(series_days1, 'sigma', 48*days3, 3, false, true );

series_days124 = filterseries(series_days12, 'sigma', 48*days4, 3, false, true );

series_days134 = filterseries(series_days13, 'sigma', 48*days4, 3, false, true );

h1 = figure( 'Name', 'Filtering results and intermed. statistics' );
a1 = subplot(4, 1, 1);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days1), series_days1, '.k');
title( sprintf( 'Threshold = %d sd  Window = %d days', ...
    std_devs, days1 ));
legend('Removed', 'New series');

a2 = subplot(4, 1, 2);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days1), series_days1, '.m', ...
    1:length(series_days12), series_days12, '.k');
title( sprintf( 'Threshold = %d sd  Window = %d & %d days', ...
    std_devs, days1, days2 ));

a3 = subplot(4, 1, 3);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days12), series_days12, '.m', ...
    1:length(series_days124), series_days124, '.k');
title( sprintf( 'Threshold = %d sd  Window = %d, %d, and %d days', ...
    std_devs, days1, days2, days4 ));

a4 = subplot(4, 1, 4);
plot(1:length(series_in), series_in, '.r', ...
    1:length(series_days13), series_days13, '.m', ...
    1:length(series_days134), series_days134, '.k');
title( sprintf( 'Threshold = %d sd  Window = %d, %d, and %d days', ...
    std_devs, days1, days3, days4 ));

junk = 99;