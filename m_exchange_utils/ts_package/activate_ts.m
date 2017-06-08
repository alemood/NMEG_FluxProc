function [] = activate_ts(ax,idx)
%% Activates desired axis layer for nice stacked time series figure

%%INPUT:
%   ax: the axes array used for stacked time series
%   idx: index of subplot where legend should go

axes(ax(idx+1));
end

