function leg = legend_ts(ax,idx,loc,varargin)
%% Creates a legend for stacked time series plots

%%INPUT:
%   ax: the axes array used for stacked time series
%   idx: index of subplot where legend should go
%   loc: location within whole window where desired
%   varargin: typicaly string inputs to legend call

%%OUTPUT
%   leg: the legend handle -- can set legend properties after the fact...

%%DESCRIPTION:
%   Creates legend with default font "Caslon" and box off.

%%EXAMPLE:
%l1=nice_ts_legend(ax,1,'northwest','original GISP2 time scale','GICC05-GISP2 time scale');
%This would create a legend with two entries given by last two strings in
%function call. Location would be top left corner of window.

%%MANUALLY CHANGING LOCATION: Please note that the function
%%activate_ts is designed to switch between active axes. Just use this
%%function to activate the desired axis and drag around the legend. Note:
%%you may need to reactivate the last drawn axis afterwards. 

axes(ax(idx+1));
leg=legend(varargin);
set(leg,'location',loc,'fontname','Caslon','box','off');
for i=1:length(ax)
    axes(ax(i));
end
end

