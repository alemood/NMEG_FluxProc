function [MR] = moleden2MR(MD, P_kPa, T_c)

% convert molar density (mmol m-3) to mixing ratio (ppm)
% inputs:
% MD - molar density (mmol m-3)
% P_kPa - pressure (kPa)
% T_c - air temperature (oC)

% output:
% MR - mixing ratio (ppm or umol mol-1)

R = 8.314; % [m3 L mol-1 K-1] ideal gas constan 
MR = MD.* R .* (T_c+273.14) ./ P_kPa;