function [ cs616_SWC_labels, ...
           echo_SWC_labels, ...           
           soilT_labels, ...
           TCAV_labels ] = UNM_assign_soil_data_labels( sitecode, year )

% UNM_ASSIGN_SOIL_DATA_LABELS - assign labels to soil measurements.
%   Labels are of the format soilT_cover_index_depth_*, where cover, index, and
%   depth are character strings.  e.g. "soilT_O_2_12.5_avg" denotes cover type
%   open, index (pit) 2, and depth of 12.5 cm.  Depth is followed by an
%   underscore, and then optional arbitrary text.
%
% USAGE:
%    [ cs616_SWC_labels, echo_SWC_labels, soilT_labels, TCAV_labels ] = ...
%                             UNM_assign_soil_data_labels( sitecode, year )
%
% INPUTS
   
    placeholder = 0;
    labels_template = struct( 'labels', { 'placeholder' }, ...
                              'columns', [ placeholder ] );
    echo_SWC_labels = labels_template;
    cs616_SWC_labels = labels_template;
    soilT_labels = labels_template;
    TCAV_labels = labels_template;
    %place holders
    % cs616_SWC_labels.columns = [];
    % cs616_SWC_labels.labels = {};
    
    % echo_SWC_labels.columns = [];
    % echo_SWC_labels.labels = {};
    
    % soilT_labels.columns = [];
    % soilT_labels.labels = {};
    
switch sitecode
    
    % --------------------------------------------------
  case 1  % GLand
    switch year
      case { 2009, 2010 }
        cs616_SWC_labels.columns = 157:178;
        cs616_SWC_labels.columns = [ 157:172, 174:177 ];
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
                            'cs616SWC_open_3_37.5', ...        %'cs616SWC_open_3_52.5', ...
                            'cs616SWC_cover_3_2.5', ...
                            'cs616SWC_cover_3_12.5', ...
                            'cs616SWC_cover_3_22.5', ...
                            'cs616SWC_cover_3_37.5' };%, ...
                                                      %'cs616SWC_cover_3_52.5' };
        
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
                            'soilT_cover_3_2.5', ...
                            'soilT_cover_3_12.5', ...
                            'soilT_cover_3_22.5', ...
                            'soilT_cover_3_37.5' }; %, ...

        TCAV_labels.columns = 210:211;
        TCAV_labels.labels = { 'TCAV_open_Avg', 'TCAV_cover_Avg' };

    end   %switch GLand year

    % --------------------------------------------------
  case 2 %SLand
    switch year
      case { 2009, 2010 }
        cs616_SWC_labels.columns = 157:176;
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
    
    % --------------------------------------------------
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
                            'cs616SWC_unknown_2_1' };
        
        echo_SWC_labels.columns = 180:197;
        echo_SWC_labels.labels = { 'SWC_J_1_2.5', 'SWC_J_1_12.5', ...
                            'SWC_J_1_22.5','SWC_J_2_2.5', 'SWC_J_2_12.5', ...
                            'SWC_J_2_22.5', 'SWC_J_3_2.5', 'SWC_J_3_12.5', ...
                            'SWC_J_3_22.5', 'SWC_O_1_2.5', 'SWC_O_1_12.5', ...
                            'SWC_O_1_22.5', 'SWC_O_2_2.5', 'SWC_O_2_12.5', ...
                            'SWC_O_2_22.5', 'SWC_O_3_2.5', 'SWC_O_3_12.5', ...
                            'SWC_O_3_22.5' };

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

        TCAV_labels.columns = 216:217;
        TCAV_labels.labels = { 'TCAV_Avg_1', 'TCAV_Avg_2' };
    end   % switch JSav year
    
    % --------------------------------------------------
  case 4  %PJ
    % note that PJ and PJ girdle do not report soil moisture or soil T in
    % their FluxAll files, so their soil data are parsed separately.
    switch year
      case 2009
        TCAV_labels.columns = 216:217;
      case 2010
        TCAV_labels.columns = 206:207;
    end
    TCAV_labels.labels = { 'TCAV_pinon_1_Avg', 'TCAV_juniper_1_Avg' };

    % --------------------------------------------------
    
  case 11  % unburned grass
    
    cs616_SWC_labels.columns = [];
    cs616_SWC_labels.labels = {};
    
    echo_SWC_labels.columns = []; 
    echo_SWC_labels.labels = {}; 
    
    soilT_labels.columns = [];
    soilT_labels.labels = {};
    
    TCAV_labels.columns = [];
    TCAV_labels.labels = {};

end
    


        