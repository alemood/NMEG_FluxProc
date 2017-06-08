%clear all; close all; clc;

time=0:.1:50; %time array (100 year spacing)

%sets up figure
ax=figure_ts(4,[0 50],1,'Time (ky BP)');

%ticks and ylabels for each axis
ytix1=[0,10,20,30,40]; ylbl1='Var. A';
ytix2=[4,3,2,1,0]; ylbl2='Var. B';
ytix3=[0.0,0.1,0.2,0.3,0.4]; ylbl3='Var. C';
ytix4=[1000,2000,3000,4000,5000]; ylbl4='Var. D';

%plots 2 series on first axis
subplot_ts(ax,1,ytix1,ylbl1,...
    's1',time,rand(1,length(time)).*40,'Color',[102 0 204]./255,'linewidth',1.25,...
    's2',0:50,rand(51,1).*40,'ok','markerfacecolor','r');

%plots 1 series on second axis
subplot_ts(ax,2,ytix2,ylbl2,...
    's1',time,rand(length(time),1).*4,'b','linewidth',1.25);

%plots 1 series on third axis
subplot_ts(ax,3,ytix3,ylbl3,...
    's1',time,rand(length(time),1).*.4,'--r','linewidth',1);

%plots 1 series on fourth axis
subplot_ts(ax,4,ytix4,ylbl4,...
    's1',time,rand(length(time),1).*5000,'-.k','linewidth',1);

l1=legend_ts(ax,1,'northwest','Series 1','Series 2'); %makes a legend
patch_ts(ax,14.7,17.9,[.9 .9 .9]); %makes a shaded region (patch)

activate_ts(ax,1) %try it: you can now manually drag legend around