close all;                                                                                          % Close previous figure windows

StaticFigure=figure('name','Static Equal Volatility','PaperOrientation','landscape','PaperType','uslegal','PaperPositionMode','Auto','Color',[1 1 1]);                                                           % Create figure window

hold on;
set(gcf, 'Position', [200 20 900 700]); 
% R2 vs alpha
% ########################

plot232ylim1=-0.15;	%range for Chart'R2 vs alpha'		
plot232ylim2=0.15;		
plot232ylim3=-6;	%range for Chart'R2 vs AR'		
plot232ylim4=6;	

%xlim([0,1])
%ylim([plot232ylim1,plot232ylim2]);

RankR2Dist20=RankR2Dist{1}(1:round(NTrials*0.2));


[ax, h1, h2] = plotyy(RankR2Dist20, Alpha(nn,1:round(NTrials*0.2)), RankR2Dist20, AR(nn,1:round(NTrials*0.2)),'scatter');
%plotyy(RankR2Dist{1}, Alpha(nn,:), RankR2Dist{1}, AR(nn,:),@scatter,@scatter)

%scatter(RankR2Dist20,Alpha(nn,1:round(NTrials*0.2)),'.c');
%scatter(RankR2Dist20(1),Alpha(nn,1),'ob');
%scatter(RankR2Dist20,AR(nn,1:round(NTrials*0.2)),'.m');
%scatter(RankR2Dist20(1),AR(nn,1),'om');

title({'Distribution of Alpha&AR and R-Squared';[cell2mat(FundNames(TargetFundID))]})
%ylabel('Alpha')
xlabel('R-squared')
set(get(ax(1), 'Ylabel'), 'String', 'Alpha');
set(get(ax(2), 'Ylabel'), 'String', 'Appraisal Ratio');

set(h1,'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');

set(h2,'MarkerEdgeColor','r');


set(ax(1),'ycolor','b') % y1 axis color
set(ax(2),'ycolor','r') % y2 axis color

set(ax(1),'Xlim',[0,1]);
set(ax(2),'Xlim',[0,1]);
set(ax(1),'Ylim',[plot232ylim1,plot232ylim2]);
set(ax(2),'Ylim',[plot232ylim3,plot232ylim4]);

Legend4=legend(['R2-Alpha Top20% Trials,Best Fit Alpha=',num2str(round(Alpha(nn,1)*10^4)/(10^4))],['R2-AR Top20% Trials,Best Fit AR=',num2str(round(AR(nn,1)*10^2)/(10^2))]);
set(Legend4,'Location','north')
set(Legend4,'color','none');

%AlphaAbsoluteRange=max([abs(VolAdjAlphaDist{1}),abs(VolAdjAlphaDist{2})])*12;
plot([0,1], [0,0],'-black')                               % Plot zero-alpha line
plot([RankR2Dist20(1),RankR2Dist20(1)], [plot232ylim1,plot232ylim2],'-m')                               % Plot zero-alpha line
plot([RankR2Dist20(round(NTrials*0.2)),RankR2Dist20(round(NTrials*0.2))], [plot232ylim1,plot232ylim2],'-m')                               % Plot zero-alpha line
text(RankR2Dist20(1),plot232ylim1*0.8,['Best Fit R2=',num2str(round(RankR2Dist20(1)*10^2)/(10^2))],'color','m');
text(RankR2Dist20(round(NTrials*0.2)),plot232ylim1*0.9,['20% Best Fit R2=',num2str(round(RankR2Dist20(round(NTrials*0.2))*10^2)/(10^2))],'color','m');

text(0,plot232ylim1+0.01,'Low Correlation','VerticalAlignment','Bottom');
text(0.9,plot232ylim1+0.01,'High Correlation','VerticalAlignment','Bottom');
text(0,plot232ylim1+0.01,'Negative Alpha & AR','VerticalAlignment','Top');
text(0.9,plot232ylim1+0.01,'Negative Alpha & AR','VerticalAlignment','Top');

text(0,plot232ylim2-0.01,'Low Correlation', 'VerticalAlignment','Top');
text(0.9,plot232ylim2-0.01,'High Correlation','VerticalAlignment','Top');
text(0,plot232ylim2-0.01,'Positive Alpha & AR', 'VerticalAlignment','Bottom');
text(0.9,plot232ylim2-0.01,'Positive Alpha & AR','VerticalAlignment','Bottom');

print(StaticFigure,'-dpdf',[num2str(TargetFundID),'Top20-R2-Alpha-AR-Scatter']);
