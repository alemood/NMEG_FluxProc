function ax = figure_ts(nAxes,xlims,isRev,lbl)

%% Stacked time series figure
%% SUMMARY creates figure and returns axis handles for stacked time
%%          series plots with shared xaxis, default: box on and caslon axis
%%          fonts
%%For use with stacked time series plotting package.

%INPUT:
%   nAxes: number of vertically stacked axes
%	xlims: limits on xaxis range (cannot be empty)
%	isRev: 1 if xaxis reversed, 0 if not
%   lbl: string for x axis label

%OUTPUT:
%   ax: axes array used for other nice_ts function calls


set(0, 'DefaultAxesFontName', 'Caslon')
set(0,'DefaultTextInterpreter','Tex')
figure
ax(1)=gca;
set(ax(1),'Xtick',[],'Ytick',[],'ylim',[-10*nAxes 0]);
box on;
for i=1:nAxes
    if mod(i,2)==1
        ax(i+1)=axes('YAxisLocation', 'Left');
    else
        ax(i+1)=axes('YAxisLocation', 'Right');
    end
    ylim([-10*nAxes-2 2])
    set(ax(i+1), 'color', 'none');
    if i>1
        set(ax(i+1), 'XTick', []);
    end
end

%%handle reversed xaxis
if isRev==1
    set(ax(:),'xlim',xlims,'xdir','reverse');
else
    set(ax(:),'xlim',xlims);
end

%%xlabel
axes(ax(2));
xlabel(lbl);
linkaxes(ax(:));

