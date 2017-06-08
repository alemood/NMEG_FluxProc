function h_fig = plot_bivariate_comparison( var1, var2 , ts, type , ...
                                                   varargin )

 
p = inputParser ;
p.addRequired( 'var1', @isnumeric );
p.addRequired( 'var2', @isnumeric );
p.addRequired( 'ts',   @isnumeric );
p.addRequired( 'type', @(x)  strcmpi( x, 'fluxproc' ) | ... 
                             strcmpi( x, 'irga' )| ...
                             strcmpi( x, 'general') );
p.addParameter( 'fig_name', [], @(x) ischar(x) || isempty(x) );
p.addParameter( 'sitecode',  @( x ) ( isnumeric( x ) | isa( x, 'UNM_sites' ) ) ); 
p.addOptional( 'varnames',[], @iscell); 

p.parse( var1, var2, ts, type, varargin{ : } );
var1 = p.Results.var1;
var2 = p.Results.var2;
ts = p.Results.ts;
type = p.Results.type;
fig_name = p.Results.fig_name;
sitecode = char(p.Results.sitecode);
varnames = p.Results.varnames;
 
 
% Handle axes and variable names                  
switch type
  case 'fluxproc'
      var1name = 'NMEG';
      var2name = 'EP';
  case 'irga'
      var1name = 'Open Path';
      var2name = 'Closed Path';
  case 'general'
      if exist('varnames')
          var1name = char(varnames{1});
          var2name = char(varnames{2});
      else
          var1name = 'Var 1';
          var2name = 'Var 2';
      end 
end
 
% re = sprintf( '(?:^|%s)(\"(?:[^\"]+|\"\")*\"|[^%s]*)', ' , ', ' , ' );
% temp_name = regexp( fig_name, re, 'tokens' );
% temp_name = [ temp_name{ : } ];
temp_name = strrep(fig_name,'_',' '); % Remove underscores 
fig_name = temp_name;

pal = cbrewer( 'qual', 'Dark2', 5 );                  
h_fig = figure( 'Units', 'Normalized', ...
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
% ---------------------------------
% plot time series and diffs in top 

axes( ax_ts );
h_ts = plot( ts ,[var1 var2]);
gray82 = [ 209, 209, 209 ] / 255;  %RGB specs for unix color "gray82"
set( h_ts, 'MarkerEdgeColor', gray82  );
mylim1 = [prctile(vertcat(var1,var2),.1) prctile(vertcat(var1,var2),99.9)];
ylim( mylim1 );
title( fig_name  );
datetick( 'x' , 2 );
legend(var1name,var2name, 'Location','best'  )

axes( ax_tsdiff );
h_tsdiff = plot( ts, var1 - var2);
gray82 = [ 209, 209, 209 ] / 255;  %RGB specs for unix color "gray82"
set( h_tsdiff, 'MarkerEdgeColor', gray82  );
%xlim( [ 0, 106 ] );
mylim2 = [prctile(var1 - var2, .1) prctile(var1 - var2, 99.9)];
ylim( mylim2 );
xlabel( 'Date' );
datetick( 'x' , 1 );
title([var1name,' - ',var2name]);

hold off
linkaxes( [ ax_ts, ax_tsdiff ], 'x' ); %make axes zoom together horizontally
dynamicDateTicks([ax_ts ax_tsdiff], 'linked') %file exchange utility to update dateticks
  

% ----------------------------------------
% plot scatter of data and regression line
axes (ax_sc);
[fr, gof, o,xData,yData] = createFit(var1, var2);
h_sc = plot( fr, xData, yData );

axis equal
ylim([mylim1])
xlim([mylim1])
% Label axes
xlabel(var1name)
ylabel(var2name)
legend HIDE
grid on
refline(1)


% ---------------------------
% plot histogram of residuals


% Try to remove extreme residuals to make a worthwhile histogram
% o.residuals = o.residuals(o.residuals > prctile(o.residuals,0.05) & ...
%     o.residuals < prctile(o.residuals,0.95));
[count x] = hist( o.residuals, 20);
axes (ax_hist);
bar(x, count/sum(count));
    ylabel('\it{freq}')
    x=get(gca,'xlim');
    y=get(gca,'ylim');
%     title(sprintf('mean= %1.3f,med= %1.3,std= %1.3f' ,  nanmean( o.residuals ) ,nanmedian( o.residuals ),nanstd( o.residuals ) ) );
%     text(x(1)+5,y(2)*.92,sprintf('mean= %1.3f' ,  nanmean( o.residuals )   ) ) ;
%     text(x(1)+5,y(2)*.82,sprintf('median= %1.3f' ,  nanmedian( o.residuals )   ) ) ;
%     text(x(1)+5,y(2)*.72,sprintf('std= %1.3f' ,  nanstd( o.residuals )  ) )
     xlabel(sprintf('mean= %1.3f med= %1.3f \n std= %1.3f' ,  nanmean( o.residuals ) ,nanmedian( o.residuals ),nanstd( o.residuals ) ) ,...
         'FontSize',8);

% -------
% qqplot
axes (ax_qq);
qqplot( var1 , var2);
xlabel([var1name,' Quantiles']);ylabel([var2name,' Quantiles']);

% Save plots as fig files and pdfs

% 
% saveas( gcf , ...
%     fullfile( getenv('FLUXROOT'),'SiteData',sitecode,...
%     'fluxcompare_plots',num2str(year)),'fig');
end

