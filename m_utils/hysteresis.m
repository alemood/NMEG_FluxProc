function [myRange,inertia,tempav,thav,cav] = hysteresis(daytime,temp,theta,CO2)
%
% HYSTERESIS Computes width of hysteresis loop along axis perpendicular to
% linear regression in y-axis units.
% [day width avg_temp avg_theta avg_CO2] = HYSTERESIS(daytime,temperature,theta,CO2)
% For time series inputs with diurnal hysteresis (temperature, soil
% moisture, CO2 concentration), HYSTERESIS returns the width of the
% hysteresis loop for each day. Outputs include day, hysteresis width,
% average temperature, average soil moisture and average CO2 concentration.
% Currently set up to test hysteresis between soil temperature and soil CO2
% concentration only.  Soil moisture is unused except to calculate daily
% mean.
%
% Originally conceived as a metric for measuring 'inertia' in the soil BGC
% system through hysteresis, hence the variable name 'inertia' for
% 'hysteresis width' in the code below.  Originally developed by Ryan
% Emanuel (UVA), February 2007.  Incorporated into analysis by Diego
% Riveros-Iregui and published as Riveros-Iregui et al., Geophys. Res.
% Lett. 2007 (DOI: 10.1029/2007GL030938).
%
% Converted to function by Ryan Emanuel (NCSU) 2013.
%
% Use CAUTION when applying to conditions outside of those commenly
% observed at TCEF, Montana due to a sensor-specific aspect ratio used for
% measurements of soil CO2 and temperature at TCEF.


%These were the original lines of code used to load data before script was
%converted to a function.
% close all;
% clear all;
% %Load environmental dataset --> replace with your text.
% dat=load('HystT1E3.txt');
% daytime=dat(:,1)-38717;
% CO2_old=dat(:,2);
% temp=dat(:,3);
% theta=dat(:,4);
%Load temporally-matching CO2 dataset
% CO2=load('Co2_20.txt');

%Create a variable of unique days
myRange=unique(floor(daytime));

% figure; 

%For each day, compute the width of the hysteresis loop
for i=1:length(myRange)-1

    %Select observations for day
    aa=find(floor(daytime)==myRange(i));
    
    %Insert NaN into summary variables for missing days
    if ~sum(~isnan(CO2(aa)))
        inertia(i)=NaN;
        iecorr(i)=NaN;
        thav(i)=NaN;
        tempav(i)=NaN;
        cav(i)=NaN;
        continue
    end

    %Compute ranges and averages for each variable
    dim1(i)=max(CO2(aa))-min(CO2(aa));
    dim2(i)=max(temp(aa))-min(temp(aa));
    dim3(i)=max(theta(aa))-min(theta(aa));
    tempav(i)=mean(temp(aa));
    cav(i)=mean(CO2(aa));
    thav(i)=mean(theta(aa));

    %Perform linear regression between CO2 and temperature (dimensions 1
    %and 2)
    [b bint r rint stats(i,:)]=regress(CO2(aa),[ones(size(aa)) temp(aa)]);

    %Find absolute range of regression residuals in PPM 
    inertia(i)=(max(r)-min(r));

    %Compute a corrected axis that is perpendicular to the regression
    %slope.
    iecorr(i)=cos(atan(b(2)./1250)); 
    %Where 1250 is the 'aspect ratio' of the regression, 0-20k ppm and 4-20 deg C --> This is a characteristic of the field site and sensor ranges.

    %Compute slope of the regression
    myslope(i)=b(2);

    %Find the maximum lag time between temperature and CO2.
    bb=find(temp(aa)==max(temp(aa)));
    cc=find(CO2(aa)==max(CO2(aa)));
    lag(i)=(daytime(aa(bb(1)))-daytime(aa(cc(1)))).*24;


%%Lag correlation analysis, unused.
% [c lags]=xcorr(temp(aa),CO2(aa),'coeff');
% bb=find(c==max(c));
% lag(i)=lags(bb(1));

% if mod(i,3)==0
% % figure; plot(temp(aa),CO2(aa),'.-');
% % xlabel('T')
% % ylabel('CO2')
% end

% plot(temp(aa),detrend(CO2(aa)),'.');
% axis([5 20 -2500 2500])
% M(i)=getframe;

end


%Recompute hysteresis inertia along the axis perpendicular to the
%regression slope.
inertia=inertia.*iecorr;
inertia=inertia'; %corrected units of ppm!



%plot3(temp,theta,CO2,'.');

h=plot(thav,inertia,'.');
ylabel('H_m[ppm]')
xlabel('{\theta} [m^3 m^-^3]')
zlabel('[CO_2]')

grid


%%Unused
% dat=load('HystT1E3.txt');
% daytime2=dat(:,1)-38717;
% CO22=dat(:,2);
% temp2=dat(:,3);
% theta2=dat(:,4);

