function [data_out] = averageTimeSeries( ts, data, newtime, varargin );
%  YEAR / MONTH / DAY / HOUR / DATA
%  1994   3       7     4      25.786

p = inputParser;
p.addRequired( 'ts',[], ...
    @(x) isnumeric( x ) & ( min(x) >  datenum([2005,1,1]) ) );
p.addRequired(' data',@isnumeric);
p.addRequired( 'newtime', @ischar );
p.addParameter( 'method','mean',@ischar)
p.addParameter( 'use_wateryear', false, @islogical );
% parse optional inputs
p.parse( ts, data, newtime, varargin{ : } );
ts = p.Results.ts;
data = p.Results.data;
newtime = p.Results.newtime;
method = p.Results.method;
use_wateryear = p.Results.use_wateryear;

warning('Work in progress')

if use_wateryear 
    fprintf('Calculating average based on water year')
    [wy , wyDOY]  = ts2wateryear(ts);
end
% Vectorize MATLAB serial data
[y , m , d , h , ~ , ~] = datevec( ts );
% Concatenate 
data = horzcat( y , m , d , h , data );

switch method
    case 'mean'
        f = @nanmean;
    case 'cumulative'
        f = @(x) cumsum(x,'omitnan');
    case 'min'
        f = @nanmin;
    case 'max'
        f = @nanmax;
end

switch newtimes
    case 'hourly'     
        [ah,~,ch] = unique(data(:,1:4),'rows');
        out = [ah,accumarray(ch,data(:,5),[], f )];
    case 'daily'        
        [ad,~,cd] = unique(data(:,1:3),'rows');
        out = [ad,accumarray(cd,data(:,5),[], f )];
    case 'monthly'
        [am,~,cm] = unique(data(:,1:2),'rows');
        out = [am,accumarray(cm,data(:,5),[], f )];
    case 'yearly'
        [ay,~,cy] = unique(data(:,1),'rows');
        out = [ay,accumarray(cy,ts(:,5),[], f )];       
end

        
