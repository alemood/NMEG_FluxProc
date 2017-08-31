function fh = compare_multiyr_ts( sitecode1,  sitecode2, varname ,yearlist )
% Plot a comparison timeseries and regression of a variable from two
% different UNM_sites. 
% 
% The data to be plotted are obtained from the site-year gapfilled Ameriflux
% file via get_ameriflux_filename and parse_ameriflux_file and are plotted by
% RBD_plot_fingerprints.
%
% USAGE
%   fh = compare_multiyr_ts( sitecode1, sitecode2, varname )
%
% INPUTS:
%     sitecode1: UNM_sites object; specifies the site
%     sitecode2: UNM_sites object; specifies the site
%     varname  : str ; specifies variable name to plot from QC file.
%     yearlist : array; years to compare
%
% OUTPUTS:
%     fh: handle of the figure created.
%
% SEE ALSO
%     
% 
% author: Alex Moody, UNM, July 2017


for i = 1:length(yearlist)
    year = yearlist(i);
    s1dat_yr = parse_fluxall_qc_file(sitecode1, year);
    s2dat_yr = parse_fluxall_qc_file(sitecode2, year);
    
    if i==1
        s1dat = s1dat_yr;
        s2dat = s2dat_yr;
    else
        s1dat = table_vertcat_fill_vars(s1dat, s1dat_yr);
        s2dat = table_vertcat_fill_vars(s2dat, s2dat_yr);
    end
end


% [~,~,R] =regress( Par_Avg,[ones(length(sw_incoming),1) sw_incoming]);
% out_idx = find(R <= prctile(R,0.6) | R >= prctile(R,99.95));
% figure;gscatter(Par_Avg,sw_incoming,R <= prctile(R,0.60) | R >= prctile(R,99.95) );

[fr, gof ] = createFit( s1dat{:,varname},s2dat{:,varname} );

fh = figure('Position',[187 604 1528 413]);
% Timeseries
ax(1)=subplot(2,3,[1,2]);
    plot(s1dat.timestamp, s1dat{:,varname});
    hold on
    plot(s2dat.timestamp, s2dat{:,varname});
    datetick('x','mmm-yy','keepticks')
    ylabel(varname,'Interpreter','none');
    legend(char(sitecode1),char(sitecode2));
    hold off
% Percent Differences time series
percentDiff = abs((s1dat{:,varname} - s2dat{:,varname})./...
   nanmean([s1dat{:,varname} s2dat{:,varname}],2));
ax(2)=subplot(2,3,[4,5]);
    semilogy(s1dat.timestamp,percentDiff,'k');
    ylabel('% difference')
    datetick('x','mmm-yy','keepticks')
% Link timeseries axes    
linkaxes(ax,'x');
dynamicDateTicks(ax,'linked');
    
% Linear Regression
subplot(1,3,3);
    plot( fr,  s1dat{:,varname}, s2dat{:,varname});  
    grid on
    xlabel(char(sitecode1));
    ylabel(char(sitecode2));
    % Create textbox
    annotation(gcf,'textbox',...
    [0.81 0.12 0.09 0.26],...
    'String',sprintf('rsquare = %1.2f \n RMSE = %3.2f \n y = %1.2f*x + %1.2f',...
    gof.rsquare,gof.rmse,fr.p1,fr.p2),...
    'FitBoxToText','on');
end

function [fitresult, gof] = createFit( x ,y)

% Fit
[xData, yData] = prepareCurveData( x, y );
% Set up fittype and options.
ft = fittype( 'poly1' );
% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );
end
