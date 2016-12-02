function h = make_irga_comparison( irga1 , irga2 )
%make_fluxproc_comparison.m

[year,~,~,~,~,~]=datevec(min(irga1.timestamp));
sitecode='SLand';


myvars = {'un_co2_flux' 'co2_flux',...
    'un_H'        'H',...
    'un_LE' 'LE',...
    'un_h2o_flux' 'h2o_flux'};
%Access variable names through any table T
t_start = datenum([2016,1,1]);
t_end = datenum([2016,7,18]);

[irga1, irga2] = merge_tables_by_datenum(irga1,irga2,...
        'timestamp','timestamp', ...
        14.99,...
        t_start, t_end);
ts = irga2.timestamp;



for i=1:length(myvars)+4;
    if i <= 8
        varname = char(myvars(i));
        h(i) = plot_compare( irga1{:,myvars(i)}, irga2{:,myvars(i)}, ts, varname, sitecode , year )
    elseif i==9 %FCcorrected - FCraw
        i1var = irga1{:,myvars(2)} - irga1{:,myvars(1)}; 
        i2var = irga2{:,myvars(2)} - irga2{:,myvars(1)};
        varname = 'FC corrected - FC raw';
        h(i) = plot_compare( i1var, i2var, ts, varname,sitecode,year)
    elseif i==10 %Hcorrected - Hraw
        i1var = irga1{:,myvars(4)} - irga1{:,myvars(3)}; 
        i2var = irga2{:,myvars(4)} - irga2{:,myvars(3)};
        varname = 'H corrected - H raw ';
        h(i) =plot_compare( i1var, i2var, ts, varname,sitecode,year)
    elseif i==11 %LEcorrected - LEraw
        i1var = irga1{:,myvars(6)} - irga1{:,myvars(5)}; 
        i2var = irga2{:,myvars(6)} - irga2{:,myvars(5)};
        varname = 'LE corrected - LE raw';
        h(i) = plot_compare( i1var, i2var, ts, varname,sitecode,year)
    elseif i==12 %h2o_cor - h2o_raw
        i1var = irga1{:,myvars(8)} - irga1{:,myvars(7)}; 
        i2var = irga2{:,myvars(8)} - irga2{:,myvars(7)};
        varname = 'h2o corrected - h2o raw ';
        h(i) = plot_compare( i1var, i2var, ts, varname,sitecode,year)
    end
end
%    savefig( h , fullfile( getenv('FLUXROOT'),'SiteData', ...
%        sitecode,'fluxcompare_plots',num2str(year) ) )