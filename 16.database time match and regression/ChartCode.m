figure
[ax, h1, h2] =plotyy(MonthSeries',[Quantile25';Quantile50';Quantile75'],MonthSeries,(Quantile75-Quantile25)',@plot,@bar);
title([StrategyName(1);'3-year Rolling Correlation to SPX']);

% 337 stand for 1/1/1995 
% 584 stand for 8/31/2015
set(ax(1),'Xlim',[337,584]);
set(ax(2),'Xlim',[337,584]);
set(ax(1),'xtick',337:50:584);
set(ax(2),'xtick',337:50:584);
set(ax(1),'xticklabel',{'1995','2000','2005','2010','2015'});
set(ax(2),'xticklabel',{'1995','2000','2005','2010','2015'});
set(ax(1),'Ylim',[-1,1]);
set(ax(2),'Ylim',[0,3]);
set(ax(1),'ytick',-1:0.2:1);
set(ax(2),'ytick',0:0.25:1);


xlabel('Time')
set(get(ax(1), 'Ylabel'), 'String', '3-year Rolling Correlation to SPX');
set(get(ax(2), 'Ylabel'), 'String', 'Correlation Dispersion');

legend('25% Quantile(lhs)','50% Quantile(lhs)','75% Quantile(lhs)','75%-25%(rhs)');
set(legend,'Location','NorthWest');

hold on
xRange=xlim(ax(1));
plot([xRange(1),xRange(2)], [0.5/3*2-1,0.5/3*2-1],':black');  

disp('Figure finished');