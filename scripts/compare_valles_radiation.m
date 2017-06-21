% COMPARE VALLES RADIATION
% Alex Moody, June 2017

year = 2017;
t1 = parse_fluxall_qc_file(UNM_sites.MCon,year);
t2  = parse_fluxall_qc_file(UNM_sites.MCon_SS,year);
[~, id1, id2] =intersect(t1.jday,t2.jday);
t1 = t1(id1,:);
t2 = t2(id2,:);

scatter(t1.NR_tot,t2.NR_tot,'filled','DisplayName','NetRad')
ax(1) = subplot(5,1,1);
    plot(t1.timestamp,[t1.sw_incoming,t2.sw_incoming]);
    legend('MCon','New MCon')
    title('SW_{in}')
ax(2) = subplot(5,1,2);
    plot(t1.timestamp,[t1.lw_incoming,t2.lw_incoming]);
    title('LW_{in}')
ax(3) = subplot(5,1,3);
    plot(t1.timestamp,[t1.sw_outgoing,t2.sw_outgoing,]);
    title('SW_{out}')
ax(4) = subplot(5,1,4);
    plot(t1.timestamp,[t1.lw_outgoing,t2.lw_outgoing]);
    title('LW_{out}')   
ax(5) = subplot(5,1,5);
    alb1 = [t1.sw_outgoing./t1.sw_incoming];
    alb2 = [t2.sw_outgoing./t2.sw_incoming];
    plot(t1.timestamp,[alb1, alb2])
    ylim([-10 10])
    title('Albedo')
    
datetick('x');
linkaxes(ax , 'x')
dynamicDateTicks(ax  , 'linked')




[ NR_sw, NR_lw, NR_tot ] = ...
    UNM_RBD_calculate_net_radiation( UNM_sites.MCon, 2017, ...
    t1.sw_incoming, t1.sw_outgoing, ...
    t1.lw_incoming, t1.lw_outgoing, ...
    t1.NR_tot, t1.wnd_spd, t1.jday );

plot_qc_radiation(  sitecode, ...
    year, ...
    timestamp, ...
    sw_incoming, ...
    sw_outgoing, ...
    lw_incoming, ...
    lw_outgoing, ...
    Par_Avg, ...
    NR_tot )