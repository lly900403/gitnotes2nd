close all;                                                                                          % Close previous figure windows

StaticFigure=figure('name','Static Equal Volatility','PaperOrientation','landscape','PaperType','uslegal','PaperPositionMode','Auto','Color',[1 1 1]);                                                           % Create figure window

hold on;
set(gcf, 'Position', [200 20 900 700]); 

% R2 vs AR
% ########################
BestR2=R2(:,1);
SelectedPoint=find(BestR2<=quantile(BestR2,0.04) & MeanPerStdBest20PctAR>=quantile(MeanPerStdBest20PctAR,0.75));
SelectedBestR2=BestR2(SelectedPoint);
SelectedMeanPerStdBest20PctAR=MeanPerStdBest20PctAR(SelectedPoint);
scatter(BestR2,MeanPerStdBest20PctAR,'.b');
scatter(SelectedBestR2,SelectedMeanPerStdBest20PctAR,'or');

title({'Distribution of AR and R-Squared'})
ylabel('AR')
xlabel('R-squared')

Legend4=legend('Funds');
set(Legend4,'Location','north')
set(Legend4,'color','none');

ARAbsoluteRange=max(MeanPerStdBest20PctAR);
plot([0,1], [0,0],'-m')                               
xlim([0,1])
ylim([-ARAbsoluteRange,ARAbsoluteRange]);

plot232ylim1=-ARAbsoluteRange;
plot232ylim2=ARAbsoluteRange;

text(0,plot232ylim1*0.95,'Low Correlation','VerticalAlignment','Bottom');
text(0.9,plot232ylim1*0.95,'High Correlation','VerticalAlignment','Bottom');
text(0,plot232ylim1*0.95,'Negative AR','VerticalAlignment','Top');
text(0.9,plot232ylim1*0.95,'Negative AR','VerticalAlignment','Top');

text(0,plot232ylim2,'Low Correlation', 'VerticalAlignment','Top');
text(0.9,plot232ylim2,'High Correlation','VerticalAlignment','Top');
text(0,plot232ylim2,'Positive AR', 'VerticalAlignment','Bottom');
text(0.9,plot232ylim2,'Positive AR','VerticalAlignment','Bottom');


print(StaticFigure,'-dpdf',['All ',num2str(numberoffund),' Funds Scatter']);