function T_soil_flux_corr =  soil_flux_correct( sitecode, year, write_qc, write_rbd , showfig )
% SOIL_FLUX_CORRECT - Quality control aggregated LI8100 data files 
%   
% USAGE
%    T_out =  Usoil_flux_correct( sitecode, year, write_qc, write_rbd , showfig );
%
% INPUTS:
%    sitecode: UNM_sites object; specifies the site (PJ or PJ_girdle)
%    year: four-digit year: specifies the year
%    showfig: logical; show figures = true, suppress = false
%
% OUTPUTS
%    T_out: MATLAB table: soil variables extracted from data
%
% SEE ALSO
%    table, parse_fluxall_txt_file
%
% author:Alex Moody, UNM , 2017


% Load data
sitecode = UNM_sites( sitecode );

fname = ...
    fullfile( getenv('FLUXROOT'),...
    'SiteData',char(sitecode),'LI-8100-RawDataCards',...
    sprintf('%s_%d_soil_fluxall.txt',char(sitecode),year) );
if exist(fname) == 2
data = li81x_2_table(fname);
else
    fprintf('%s %d soil fluxall missing, skipping this year.\n',...
        char(sitecode),...
        year)
    return
end

% Round to nearest 30 minutes 
data.ts_round = datenum_2_round30min(data.IVDate,14.99,datenum(2006,1,1));

lin_idx = find(data.CrvFitStatus == 'Lin');
exp_idx = find(data.CrvFitStatus == 'Exp');

data_qc = [data(lin_idx,'Lin_Flux') ; data(exp_idx,'Exp_Flux')];
%========================REMOVE BAD DATA===============================

closing_time_max = 18; % Maximum allowable closing time
idx = find(data.TimeClosing > 18 );
data(idx,:) = [];

