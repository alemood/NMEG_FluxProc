function jday = IDXjday( idx )
% IDXjday - calculates the decimal day for a specified observation (DOY) in an
% array containing one year's worth of data at 30-minute observation intervals
% (48 observations per day). Assume Midnight of New Years is not included,
% therefore there will not be a jday == 1; This index show be in the
% previous year.
%
% idx must be an integer
%
% Useful for finding a particular time range within an annual 30-minute dataset.
%
% USAGE
%    jday = IDXjday( idx );
%
% INPUTS
%    idx: numeric; scalar or vector of observations in array, table, spreadsheet. 
%         17520 idx in regular year, 17568 in leap year.
% 
% OUTPUTS
%    jday: Decimal date of 30 minute observation
%
% author: Alex Moody, UNM, 2017

if ( idx < 0 ) | ( idx >= 17568 )
    error( 'Index must satisfy 0 <= Index < 367' );
end

obs_per_day = 48;
jday = ( obs_per_day  + idx ) ./ obs_per_day;
