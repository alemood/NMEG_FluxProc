function pat = patch_ts(ax,x1,x2,col)
%% Makes a shaded patch beneath plotted time series for a stacked time s
%%  series plot

%%INPUT:
%   ax: axes array from nice_ts_figure
%   x1: lower endpoint in time (by x value)
%   x2: higher endpoint in time (by x value)
%   col: 1x3 color RGB (scaled / 255) color array

%%OUTPUT:
%   pat: patch handle

axes(ax(1))
ymax=5;
ymin=(length(ax)-1)*-10-5;
pat=patch([x1,x2,x2,x1],[ymin,ymin,ymax,ymax],col);

set(pat,'edgecolor','none');
for i=2:length(ax)
    axes(ax(i));
end

end

