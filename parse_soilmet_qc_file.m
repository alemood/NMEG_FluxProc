function tbl = parse_soilmet_qc_file( sitecode, year , varargin)
% PARSE_FLUXALL_QC_FILE - parse tab-delimited ASCII QC file to matlab dataset
%
%   
% The QC file is created by UNM_RemoveBadData (or UNM_RemoveBadData_pre2012).
%
% USAGE:
%     tbl = UNM_parse_QC_txt_file( sitecode, year );
% 
% INPUTS
%    sitecode: UNM_sites object; specifies the site to show
%    year: four-digit year: specifies the year to show
%    suffix: string; 'qc' or 'qc_rbd'
%
% OUTPUTS:
%    tbl: dataset array; the data from the QC file
%
% SEE ALSO
%    dataset, UNM_RemoveBadData, UNM_RemoveBadData_pre2012
%
% author: Timothy W. Hilton, UNM, April 2012
args = inputParser;
args.addRequired( 'sitecode', @(x) ( isnumeric(x) | isa( x, 'UNM_sites' ) ) );
args.addRequired( 'year', @isnumeric );
args.addParameter( 'suffix', 'qc',@ischar) 
args.parse( sitecode, year, varargin{ : } );

sitecode = args.Results.sitecode;
site = get_site_name( sitecode );
year = args.Results.year;
suffix = args.Results.suffix;

qcfile = fullfile( get_site_directory( sitecode ), ...
                   'processed_soil', ...
                   sprintf( '%s_%d_soilmet_%s.txt', site,year , suffix ) );


[ ~, fname, ext ] = fileparts( qcfile );
fprintf( 'reading %s... ', qcfile );

% count the number of columns in the file - this varies between sites
fid = fopen( qcfile, 'r' );
header_line = fgetl( fid );
n_cols = numel( regexp( header_line, ',', 'split' ) );

fmt = repmat( '%f', 1, n_cols );
%fmt = '%f';
tbl = readtable(  qcfile, ...
                 'Delimiter', ',', ...
                 'Format', fmt );

tbl = replace_badvals( tbl, [-9999], 1e-6 );

tbl.timestamp = datenum( tbl.year, tbl.month, tbl.day, ...
    tbl.hour, tbl.min, tbl.second );
%fprintf( 'done\n');
end

