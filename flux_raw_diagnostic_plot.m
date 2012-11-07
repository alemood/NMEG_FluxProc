function [result, pdfname] = flux_raw_diagnostic_plot(fluxraw, site, mod_date)
% FLUX_RAW_DIAGNOSTIC_PLOT - makes diagnostic plots of each variable from a
%   Campbell Scientific datalogger *.flux.dat 30-minute file
    
    nvar = length(fluxraw.Properties.VarNames);
    
    psname = fullfile(getenv('PLOTDEPOT'), ...
                      sprintf('%s_%s_flux_raw.ps', site, ...
                              datestr(mod_date, 'YYYY-mm-dd')));

    fprintf(1, 'plotting diagnostic plots...');
    this_fig = figure();

    %% SevEco doesn't have an Fc_wpl column
    if (not(strcmp(site, 'SevEco')))
        Fc_wpl_idx = find(strcmp(fluxraw.Properties.VarNames, 'Fc_wpl'));
        plot(fluxraw.timestamp, fluxraw.Fc_wpl, '.k');
        datetick('x', 'ddmmmyyyy');
        ylim([-50, 50]);
        xlabel('timestamp');
        ylabel(sprintf('%s (%s)', ...
                       'Fc\_wpl', ...
                       fluxraw.Properties.Units{Fc_wpl_idx}));
        title(sprintf('%s %s', strrep(site, '_', '\_'), datestr(mod_date)));
        print('-dpsc2', psname, sprintf('-f%d', this_fig));
        event = waitforbuttonpress();
    end
    
    wait = 1;
    for i=1:length(fluxraw.Properties.VarNames)
        this_var = fluxraw.Properties.VarNames{i};
        this_units = fluxraw.Properties.Units{i};
        plot(fluxraw.timestamp, ...
             fluxraw.(this_var), ...
             '.k');
        dynamicDateTicks();  % Matlab FEX function - date ticks play nice
                             % with zooming and panning
        %datetick('x', 'ddmmmyyyy');
        xlabel('timestamp');
        ylabel(sprintf('%s (%s)', strrep(this_var, '_', '\_'), this_units));
        title(sprintf('%s %s', strrep(site, '_', '\_'), datestr(mod_date)));
        print('-dpsc2', psname, '-append', '-loose', sprintf('-f%d', this_fig));
        if wait
            wait = waitforbuttonpress();
        else
            set(this_fig, 'Visible', 'off');
        end
    end
    close(this_fig);
    
    fprintf(1, 'done\nwriting pdf file...');
    pdfname = strrep(psname, '.ps', '.pdf');
    ps2pdf('psfile', psname, ...
           'pdffile', pdfname, ...
           'deletepsfile', 1);
    
    [result, msg] = system('which pdfcrop');
    if result == 0
        system(sprintf('pdfcrop %s %s', pdfname, pdfname));
    end
    
    fprintf(1, ' wrote %s\n', pdfname);