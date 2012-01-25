function h = UNM_Ameriflux_plot_field( ds, field, year )
% UNM_AMERIFLUX_PLOT_FIELD - create a new figure window; plot one field of an
% ameriflux dataset against day of year
%   
% h = UNM_Ameriflux_plot_field( ds, field )
%
% INPUTS
%   ds: matlab dataset; the Ameriflux data
%   field: character string; the field to be plotted
%   year: the year
% OUTPUTS
%   h: handle to the figure window created
%
% (c) Timothy W. Hilton, UNM, January 2012
    
    h = figure( 'Visible', 'off' );
    var_idx = find( strcmp( ds.Properties.VarNames, field ) );
    
    % draw the Greek character mu where 'me' appears in the units
    this_units = ds.Properties.Units{ var_idx };
    this_units = strrep( this_units, 'mu', '\mu' );
    field_label = regexprep( field , '([0-9])p([0-9])', '$1\.$2');
    field_label = strrep( field_label, '_', '\_' );
    
    plot( ds.DTIME, ds.( field ), '.k' );
    xlim( [ 1, 367 ] );
    xlabel( sprintf( '%d day of year', year ) );
    ylabel( sprintf( '%s, [ %s ]', field_label, this_units ) );
    