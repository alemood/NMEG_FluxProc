function fh = plot_multiyr_ts( sitecode )
% create fingerprint plots in a 2x3 array of panels from gapfilled Ameriflux
% file for site-year.  Plots Rg, RH, T, NEE, LE, H.
% 
% The data to be plotted are obtained from the site-year gapfilled Ameriflux
% file via get_ameriflux_filename and parse_ameriflux_file and are plotted by
% RBD_plot_fingerprints.
%
% USAGE
%   fh = plot_siteyear_fingerprint_2x3array( sitecode, year, main_t_str )
%
% INPUTS:
%     sitecode: UNM_sites object; specifies the site
%     year: four-digit integer; specifies the year
%     main_t_str: character string; main title to appear centered over all
%          six panels
%
% OUTPUTS:
%     fh: handle of the figure created.
%
% SEE ALSO
%     UNM_sites, get_ameriflux_filename, parse_ameriflux_file, RBD_plot_fingerprints
% 
% author: Greg

yearlist = 2007:2015;

source1 = 'fluxall';
var1 = 'Fc_raw_massman_ourwpl';
source2 = 'reddyproc';
var2 = 'NEE';

for i = 1:length(yearlist)
    year = yearlist(i);
    s1dat_yr = parse_fluxall_txt_file(sitecode, year);
    s2dat_yr = UNM_parse_reddyproc_output(sitecode, year);
    
    if i==1
        s1dat = s1dat_yr;
        s2dat = s2dat_yr;
    else
        s1dat = table_vertcat_fill_vars(s1dat, s1dat_yr);
        s2dat = table_vertcat_fill_vars(s2dat, s2dat_yr);
    end
end

% -9999 to nan
s1dat = replace_badvals(s1dat, [-9999], 0.9);
s2dat = replace_badvals(s2dat, [-9999], 0.9);

figure()
plot(s1dat.timestamp, s1dat{:,var1})
hold on
plot(s2dat.timestamp, s2dat{:,var2})
datetick()
    

