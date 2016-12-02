function h_fig_flux = plot_compare( NMEGvar, EPvar , ts, fig_name , sitecode , year)

 pal = cbrewer( 'qual', 'Dark2', 5 ); 
                   
 h_fig_flux = figure( 'Units', 'Normalized', ...
                      'Name', [fig_name, ' - ' , sitecode ], ...
                      'position',[.1 .1 .4 .7],...
                      'NumberTitle', 'off' );
                  
%ax_flags = subplot( 'Position', [ 0.1, 0.05, 0.89, 0.2 ] );
%ax_ts = subplot( 'Position', [ 0.1, 0.30, 0.89, 0.64 ] );
ax_ts = subplot(3,3,[1 3]);
ax_tsdiff = subplot(3,3,[4 6]);
ax_sc = subplot(3,3,7);
ax_hist = subplot(3,3,8);
ax_qq = subplot(3,3,9);
%suptitle(sitecode)
hold on; 
box on;
% --------
% plot time series and diffs in top 

axes( ax_ts );
h_ts = plot( ts ,[NMEGvar EPvar]);
gray82 = [ 209, 209, 209 ] / 255;  %RGB specs for unix color "gray82"
set( h_ts, 'MarkerEdgeColor', gray82  );
mylim1 = [prctile(vertcat(NMEGvar,EPvar),.1) prctile(vertcat(NMEGvar,EPvar),99.9)];
ylim( mylim1 );
title( fig_name  );
datetick( 'x' , 1 );
legend('irga1','irga2','best')

axes( ax_tsdiff );
h_tsdiff = plot( ts, NMEGvar - EPvar);
gray82 = [ 209, 209, 209 ] / 255;  %RGB specs for unix color "gray82"
set( h_tsdiff, 'MarkerEdgeColor', gray82  );
%xlim( [ 0, 106 ] );
mylim2 = [prctile(NMEGvar - EPvar, .1) prctile(NMEGvar - EPvar, 99.9)];
ylim( mylim2 );
xlabel( 'Date' );
datetick( 'x' , 1 );
title('irga1 - irga2');

hold off

% -------
% plot scatter of data and regression line
axes (ax_sc);
[fr, gof, o,xData,yData] = createFit(NMEGvar, EPvar);
h_sc = plot( fr, xData, yData );

axis equal
ylim([mylim1])
xlim([mylim1])
% Label axes
xlabel irga1
ylabel irga2
legend HIDE
grid on
refline(1)


% ----------
% plot histogram of residuals
axes (ax_hist);
hist( o.residuals, 20);
%xlim([-20 20])

% ----------
% qqplot
axes (ax_qq);
qqplot( NMEGvar , EPvar);
xlabel('irga1 Quantiles');ylabel('irga2 Quantiles');


linkaxes( [ ax_ts, ax_tsdiff ], 'x' );  %make axes zoom together horizontally

% Save plots as fig files and pdfs

% 
% saveas( gcf , ...
%     fullfile( getenv('FLUXROOT'),'SiteData',sitecode,...
%     'fluxcompare_plots',num2str(year)),'fig');
end

