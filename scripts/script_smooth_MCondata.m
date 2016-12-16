fname = fullfile(getenv('FLUXROOT'), 'Flux_Tower_Data_By_Site', 'MCon',...
    'soil_data','soil_fromMarcy_clean.csv');

T = readtable(fname);



T.new = num2str(T.YYMMDDhhmm, '%010u');

T.timestamp = datenum(T.new, 'YYmmDDHHMM');

T.YYMMDDhhmm = [];

varnames = T.Properties.VariableNames;
for i=1:length(varnames)-1
    nanidx = T.(varnames{i}) == -9999;
    T.(varnames{i})(nanidx) = NaN;
end

ds = table2dataset(T);

ds_30min = dataset_fill_timestamps(ds, 'timestamp');

ds_30min_smooth = UNM_soil_data_smoother_GEM(ds_30min, 12, true);

