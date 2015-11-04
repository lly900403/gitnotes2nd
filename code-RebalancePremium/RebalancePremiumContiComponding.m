close all;
clc
clear

expectedReturn=0.002;
volatility=0.08;
nYears=60;
nStocks=50;
nTrials=50000;
chop=0.01;

PortfolioValDiff=zeros(nTrials,1);
PortfolioRetDiff=zeros(nTrials,1);
RebPortfolioEndVal=zeros(nTrials,1);
NoRebPortfolioEndVal=zeros(nTrials,1);

for i=1:nTrials
    stockReturns=randn(nYears,nStocks)*volatility+expectedReturn;
    RebPortfolioReturns=mean(exp(stockReturns),2)-1;
    stocksCumVal=exp(sum(stockReturns,1));
    RebPortfolioEndVal(i)=nStocks*1*prod(1+RebPortfolioReturns,1);
    NoRebPortfolioEndVal(i)=1*sum(stocksCumVal,2);
    RebPortfolioRet=log(RebPortfolioEndVal(i)/nStocks);
    NoRebPortfolioRet=log(NoRebPortfolioEndVal(i)/nStocks);
    PortfolioValDiff(i)=RebPortfolioEndVal(i)-NoRebPortfolioEndVal(i);
    PortfolioRetDiff(i)=RebPortfolioRet-NoRebPortfolioRet;
end

ValDiffChopped=PortfolioValDiff(and(PortfolioValDiff>quantile(PortfolioValDiff,chop),PortfolioValDiff<quantile(PortfolioValDiff,1-chop))); 


figure('name','Rebalance or Not?','PaperOrientation','landscape','PaperType','uslegal','PaperPositionMode','Auto');
hold on;
set(gcf, 'Position', get(0,'Screensize')*0.9); 

subplot(1,2,1)
hist(ValDiffChopped,100);
line([0 0],get(gca,'YLim'),'Color',[1 0 0])
line([mean(PortfolioValDiff), mean(PortfolioValDiff)],get(gca,'YLim'),'Color',[0 0.7 0],'linestyle','-.')
line([median(PortfolioValDiff), median(PortfolioValDiff)],get(gca,'YLim'),'Color',[0.5 0.5 0],'linestyle','-.')
Legend1=legend('Portfolio value difference','Zero line','mean of portfolio value difference','median of portfolio value difference');
title('Value Difference');
set(Legend1,'Location','NorthWest','FontSize',8);
legend boxoff

subplot(1,2,2)
hist(PortfolioRetDiff,100);
line([0 0],get(gca,'YLim'),'Color',[1 0 0])
line([mean(PortfolioRetDiff), mean(PortfolioRetDiff)],get(gca,'YLim'),'Color',[0 0.7 0],'linestyle','-.')
line([median(PortfolioRetDiff), median(PortfolioRetDiff)],get(gca,'YLim'),'Color',[0.5 0.5 0],'linestyle','-.')
Legend2=legend('Portfolio return difference','Zero line','mean of portfolio return difference','median of portfolio return difference');
title('Return Difference');
set(Legend2,'Location','NorthWest','FontSize',8);
legend boxoff

figure('name','Rebalance or Not?','PaperOrientation','landscape','PaperType','uslegal','PaperPositionMode','Auto');
hold on;
set(gcf, 'Position', get(0,'Screensize')*0.9); 

subplot(1,2,1)
hist(RebPortfolioEndVal,100);
line([0 0],get(gca,'YLim'),'Color',[1 0 0])
line([mean(RebPortfolioEndVal), mean(RebPortfolioEndVal)],get(gca,'YLim'),'Color',[0 0.7 0],'linestyle','-.')
%line([median(RebPortfolioVal), median(RebPortfolioVal)],get(gca,'YLim'),'Color',[0.5 0.5 0],'linestyle','-.')
Legend1=legend('Portfolio value ','Zero line','mean of portfolio value');
title('RebPortfolioVal');
set(Legend1,'Location','NorthEast','FontSize',8);
legend boxoff

subplot(1,2,2)
hist(NoRebPortfolioEndVal,100);
line([0 0],get(gca,'YLim'),'Color',[1 0 0])
line([mean(NoRebPortfolioEndVal), mean(NoRebPortfolioEndVal)],get(gca,'YLim'),'Color',[0 0.7 0],'linestyle','-.')
%line([median(NoRebPortfolioVal), median(NoRebPortfolioVal)],get(gca,'YLim'),'Color',[0.5 0.5 0],'linestyle','-.')
Legend2=legend('Portfolio return ','Zero line','mean of portfolio value');
title('NoRebPortfolioVal');
set(Legend2,'Location','NorthEast','FontSize',8);
legend boxoff



disp({'Avg $ Diff',mean(PortfolioValDiff)});
disp({'Avg Ret Diff',mean(PortfolioRetDiff)});

disp({'Median $ Diff',median(PortfolioValDiff)});
disp({'Median Ret Diff',median(PortfolioRetDiff)});

disp({'Rebalance Mean',mean(RebPortfolioEndVal)});
disp({'No Rebalance Mean',mean(NoRebPortfolioEndVal)});