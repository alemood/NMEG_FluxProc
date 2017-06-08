function [wateryear , wyDOY ] = ts2wateryear( ts )
% TS2WATERYEAR Convert a serial matlab timestamp to a water year and
% water year DOY. Water year is defined relative to New Mexico's climate
% and runs from October 1st to September 30th of the following year
%
% This works on vectors of double only right now. Table functionality to
% come later if I get to it.
%
% author: Alex Moody , UNM , 2017

% Initialize an vector of zeros for the water year output
wateryear = zeros( length( ts ) ,1  );

% Vectorize the timestamp
[year, month , day, ~ , ~ , ~ ] = datevec(ts);
% Find the unique years
yearvec = unique(year);

% For each water year find the corresponding index in the julian calendar
for j = 1:length(yearvec)
    wy_idx = find( ts <= datenum( yearvec(j) , 9 , 30) & ...
        ts >= datenum( yearvec(j) - 1 , 10, 1) );
    wateryear(wy_idx) = yearvec(j);
end

% Find the water year decimal DOY
wyDOY =  ts - datenum(  wateryear, 10, 0 ) + day;
