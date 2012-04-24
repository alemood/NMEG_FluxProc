function [ cs616_SWC_labels, ...
           echo_SWC_labels, ...           
           soilT_labels ] = UNM_assign_soilT_labels( sitecode, year )
% UNM_ASSIGN_SOILT_LABELS - assign labels to soil temperature measurements.
%   Labels are of the format soilT_cover_index_depth_*, where cover, index, and
%   depth are character strings.  e.g. "soilT_O_2_12.5_avg" denotes cover type
%   open, index (pit) 2, and depth of 12.5 cm.  Depth is followed by an
%   underscore, and then optional arbitrary text.
%
% USAGE:
%    [ cs616_SWC_labels, echo_SWC_labels, soilT_labels ] = ...
%                             UNM_assign_soilT_labels( sitecode, year )
%
% INPUTS
   
    placeholder = 0;
    labels_template = struct( 'labels', { 'placeholder' }, ...
                              'columns', [ placeholder ] );
    echo_SWC_labels = labels_template;
    cs616_SWC_labels = labels_template;
    soilT_labels = labels_template;
    
    %place holders
    % cs616_SWC_labels.columns = [];
    % cs616_SWC_labels.labels = {};
    
    % echo_SWC_labels.columns = [];
    % echo_SWC_labels.labels = {};
    
    % soilT_labels.columns = [];
    % soilT_labels.labels = {};
    
switch sitecode
    
  case 1  % GLand
    switch year
      case { 2009, 2010 }
        cs616_SWC_labels.columns = 157:178;
        cs616_SWC_labels.labels = { 'cs616SWC_open_1_2.5', ...
                            'cs616SWC_open_1_12.5', ...
                            'cs616SWC_open_1_22.5', ...
                            'cs616SWC_cover_1_2.5', ...
                            'cs616SWC_cover_1_12.5', ...
                            'cs616SWC_cover_1_22.5', ...
                            'cs616SWC_open_2_2.5', ...
                            'cs616SWC_open_2_12.5', ...
                            'cs616SWC_open_2_22.5', ...
                            'cs616SWC_cover_2_2.5', ...
                            'cs616SWC_cover_2_12.5', ...
                            'cs616SWC_cover_2_22.5', ...
                            'cs616SWC_open_3_2.5', ...
                            'cs616SWC_open_3_12.5', ...
                            'cs616SWC_open_3_22.5', ...
                            'cs616SWC_open_3_37.5', ...
                            'cs616SWC_open_3_52.5', ...
                            'cs616SWC_cover_3_2.5', ...
                            'cs616SWC_cover_3_12.5', ...
                            'cs616SWC_cover_3_22.5', ...
                            'cs616SWC_cover_3_37.5', ...
                            'cs616SWC_cover_3_52.5' };
        
        echo_SWC_labels.columns = [];
        echo_SWC_labels.labels = {};
        
        soilT_labels.columns = 215:234;
        soilT_labels.labels = { 'soilT_open_1_2.5', ...
                            'soilT_open_1_12.5', ...
                            'soilT_open_1_22.5', ...
                            'soilT_cover_1_2.5', ...
                            'soilT_cover_1_12.5', ...
                            'soilT_cover_1_22.5', ...
                            'soilT_open_2_2.5', ...
                            'soilT_open_2_12.5', ...
                            'soilT_open_2_22.5', ...
                            'soilT_cover_2_2.5', ...
                            'soilT_cover_2_12.5', ...
                            'soilT_cover_2_22.5', ...
                            'soilT_open_3_2.5', ...
                            'soilT_open_3_12.5', ...
                            'soilT_open_3_22.5', ...
                            'soilT_open_3_37.5', ...
                            'soilT_open_3_52.5', ...
                            'soilT_cover_3_2.5', ...
                            'soilT_cover_3_12.5', ...
                            'soilT_cover_3_22.5' };%, ...
                            % 'soilT_cover_3_37.5', ...
                            % 'soilT_cover_3_52.5' };
    end   %switch GLand year
    
  case 2 %SLand
    switch year
      case { 2009, 2010 }
        cs616_SWC_labels.columns = 157:178;
        cs616_SWC_labels.labels = { 'cs616SWC_open_1_2.5', ...
                            'cs616SWC_open_1_12.5', ...
                            'cs616SWC_open_1_22.5', ...
                            'cs616SWC_open_1_37.5', ...
                            'cs616SWC_open_1_52.5', ...
                            'cs616SWC_cover_1_2.5', ...
                            'cs616SWC_cover_1_12.5', ...
                            'cs616SWC_cover_1_22.5', ...
                            'cs616SWC_cover_1_37.5', ...
                            'cs616SWC_cover_1_52.5', ...
                            'cs616SWC_open_2_2.5', ...
                            'cs616SWC_open_2_12.5', ...
                            'cs616SWC_open_2_22.5', ...
                            'cs616SWC_open_2_37.5', ...
                            'cs616SWC_open_2_52.5', ...
                            'cs616SWC_cover_2_2.5', ...
                            'cs616SWC_cover_2_12.5', ...
                            'cs616SWC_cover_2_22.5', ...
                            'cs616SWC_cover_2_37.5', ...
                            'cs616SWC_cover_2_52.5' };
        
        echo_SWC_labels.columns = [];
        echo_SWC_labels.labels = {};
        
        soilT_labels.columns = 217:236;
        soilT_labels.labels = { 'soilT_bare_1_2.5', 'soilT_bare_1_12.5', ...
                            'soilT_bare_1_22.5', 'soilT_bare_1_37.5', ...
                            'soilT_bare_1_52.5', 'soilT_cover_1_2.5', ...
                            'soilT_cover_1_12.5', 'soilT_cover_1_22.5', ...
                            'soilT_cover_1_37.5', 'soilT_cover_1_52.5', ...
                            'soilT_bare_2_2.5', 'soilT_bare_2_12.5', ...
                            'soilT_bare_2_22.5', 'soilT_bare_2_37.5', ...
                            'soilT_bare_2_52.5', 'soilT_cover_2_2.5', ...
                            'soilT_cover_2_12.5', 'soilT_cover_2_22.5', ...
                            'soilT_cover_2_37.5', 'soilT_cover_2_52.5' };
    end    % switch SLand year
    
  case 3  % JSav
    switch year
      case { 2009, 2010 }
        cs616_SWC_labels.columns = 162:179;
        cs616_SWC_labels.labels = { 'cs616SWC_open_1_5', ...
                            'cs616SWC_open_1_10', 'cs616SWC_open_1_20', ...
                            'cs616SWC_open_1_40', 'cs616SWC_open_2_5', ...
                            'cs616SWC_open_2_10', 'cs616SWC_open_2_20', ...
                            'cs616SWC_open_2_40', 'cs616SWC_edge_1_5', ...
                            'cs616SWC_edge_1_10', 'cs616SWC_edge_1_20', ...
                            'cs616SWC_edge_1_40', 'cs616SWC_canopy_1_5', ...
                            'cs616SWC_canopy_1_10', 'cs616SWC_canopy_1_20', ...
                            'cs616SWC_canopy_1_40', 'cs616SWC_unknown_1_1', ...
                            'cs616SWC_unknown_1_1' };
        
        echo_SWC_labels.columns = 180:197;
        echo_SWC_labels.labels = { ['SWC_J_1_2.5', 'SWC_J_1_12.5', ...
                            'SWC_J_1_22.5','SWC_J_2_2.5', 'SWC_J_2_12.5', ...
                            'SWC_J_2_22.5', 'SWC_J_3_2.5', 'SWC_J_3_12.5', ...
                            'SWC_J_3_22.5', 'SWC_O_1_2.5', 'SWC_O_1_12.5', ...
                            'SWC_O_1_22.5', 'SWC_O_2_2.5', 'SWC_O_2_12.5', ...
                            'SWC_O_2_22.5', 'SWC_O_3_2.5', 'SWC_O_3_12.5', ...
                            'SWC_O_3_22.5'] };

        soilT_labels.columns = 198:215;
        soilT_labels.labels = { 'SoilT_J_1_2.5_Avg', 'SoilT_J_1_12.5_Avg', ...
                            'SoilT_J_1_22.5_Avg', 'SoilT_J_2_2.5_Avg', ...
                            'SoilT_J_2_12.5_Avg', 'SoilT_J_2_22.5_Avg', ...
                            'SoilT_J_3_2.5_Avg', 'SoilT_J_3_12.5_Avg', ...
                            'SoilT_J_3_22.5_Avg', 'SoilT_O_1_2.5_Avg', ...
                            'SoilT_O_1_12.5_Avg', 'SoilT_O_1_22.5_Avg', ...
                            'SoilT_O_2_2.5_Avg', 'SoilT_O_2_12.5_Avg', ...
                            'SoilT_O_2_22.5_Avg', 'SoilT_O_3_2.5_Avg', ...
                            'SoilT_O_3_12.5_Avg', 'SoilT_03_22.5_Avg' };
    end   % switch JSav year

  case 4  % PJ control
    
    cs616_SWC_labels.columns = [];
    cs616_SWC_labels.labels = {};
    
    echo_SWC_labels.columns = []; %166:189;
    echo_SWC_labels.labels = {}; % { 'echo_wcr(1)', 'echo_wcr(2)', 'echo_wcr(3)', 'echo_wcr(4)', 'echo_wcr(5)', 'echo_wcr(6)', 'echo_wcr(7)', 'echo_wcr(8)', 'echo_wcr(9)', 'echo_wcr(10)', 'echo_wcr(11)', 'echo_wcr(12)', 'echo_wcr(13)', 'echo_wcr(14)', 'echo_wcr(15)', 'echo_wcr(16)', 'echo_wcr(17)', 'echo_wcr(18)', 'echo_wcr(19)', 'echo_wcr(20)', 'echo_wcr(21)', 'echo_wcr(22)', 'echo_wcr(23)', 'echo_wcr(24)' };
    
    soilT_labels.columns = [];
    soilT_labels.labels = {};
    
end
    


        