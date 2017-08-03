function idx = DOYidx( DOY )
% DOYidx - calculates the array index for a specified day of year (DOY) in an
% array containing one year's worth of data at 30-minute observation intervals
% (48 observations per day).
%
% DOY may be fractional or integral.  0 <= DOY < 367.
%
% Useful for finding a particular time range within an annual 30-minute dataset.
%
%
%
% USAGE
%    idx = DOYidx( DOY );
%
% INPUTS
%    DOY: numeric; day of year.  fractional or integral.  0 <= DOY < 367.
% 
% OUTPUTS
%    idx: index of DOY in an annual thirty-minute dataset.  0 <= idx <= 17569.
%
% author: Timothy W. Hilton, UNM, June 2012
warning('This may break index requests if DOY = 1. Fix to 1.0208 as you encounter them')
if ( DOY < 1.0208 ) | ( DOY >= 367 )
    error( 'DOY must satisfy 1.0208 <= DOY < 367' );
end



obs_per_day = 48;
%idx = int32( ( obs_per_day * DOY ) - obs_per_day + 1 ); 
% The above line was offsetting indices by a half hour forward. Measurement
% appeared to happen later than it should.
idx = int32( ( obs_per_day * DOY ) - obs_per_day);