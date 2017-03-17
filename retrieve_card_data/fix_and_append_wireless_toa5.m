%function toa5_out  = fix_and_append_wireless_toa5 (  fname )
% FIX_AND_APPEND_WIRELESS_TOA5 - Formats 30 min files downloaded from the
% Socorro server to a form similar to TOA5 derive from TOB3 files on cards.
% This then creates a file containing new data since the last download in 
% the site's TOA5 directory
%
% This file format was derived by following the instructions in the manual for
% LoggerNet v 4.1 (section 8.3.5; Running CardConvert From a Command Line).  I
% just copied everything from lastrun.ccf -- TWH.
%
% USAGE:
%    
%
% INPUTS
%    
%
% OUTPUTS
%    
%
%   Alex Moody, University of New Mexico, Nov 2016
%t  = toa5_2_table ( path_to_wireless_toa5 );
t = toa5_2_table


% REMOVE RECORD FIELD. WE DON'T USE THIS
t.RECORD = [];

% TOA5_2_TABLE REFORMATS THE NATIVE TOA5 TIMESTAMP. TO KEEP THINGS UNIFORM
% LET'S REDO THIS, EVEN IF IT GETS CHANGED LATER ON.
t.TIMESTAMP = cellstr(datestr(t.timestamp,'yyyy-mm-dd HH:MM:SS'));
t = [t.TIMESTAMP t(:,1:end-1)];
t.Properties.VariableNames{1} = 'TIMESTAMP';
% RETRIEVE LAST TIMESTAMP FOR FILENAMING
ts_for_file = datestr(max(t.timestamp),'yyyy_mm_dd_HHMM');
% DELETE SERIAL TIMESTAMP COLUMN
t.timestamp = [];
t = toa5_out;



writetable( toa5_out, ...
         strcat( 'TOA5_',ts_for_file,'.dat'),...
         'Delimiter',',');
