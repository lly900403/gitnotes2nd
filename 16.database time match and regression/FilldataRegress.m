clc;
clear;
[~,~,TempData1] = xlsread('rawstr3');
RawStrOrigin=TempData1(2:end,12);
RawNameOrigin=TempData1(2:end,1);
StartDifOrigin=cell2mat(TempData1(2:end,6));
EndDifOrigin=cell2mat(TempData1(2:end,9));
StrategyID=cell2mat(TempData1(2:end,2));
UniqueStrategyID=unique(StrategyID);
StrategyNameOrigin=TempData1(2:end,3);
[~,~,TempData2] = xlsread('SPX_TS3');
SPXret=cell2mat(TempData2(3:end,3));
SPXdate=cell2mat(TempData2(3:end,2));
[~,~,TempData3] = xlsread('DateMatch');
DateFormat=TempData3(:,1);
DateDif=cell2mat(TempData3(:,2));


close all;                                                                                          % Close previous figure windows

CorrelationFigure=figure('name','correlation','PaperOrientation','landscape','PaperType','uslegal','PaperPositionMode','Auto','Color',[1 1 1]);                                                           % Create figure window

hold on;
set(gcf, 'Position', [-100 20 1600 800]); 

for ThisStrategy=1:5
  disp(['Begin Strategy ',num2str(ThisStrategy),'... ']);  
    %ThisStrategy=234;
%Select Strategy
StrategyName=StrategyNameOrigin(StrategyID==ThisStrategy);
RawStr=RawStrOrigin(StrategyID==ThisStrategy);
RawName=RawNameOrigin(StrategyID==ThisStrategy);
StartDif=StartDifOrigin(StrategyID==ThisStrategy);
EndDif=EndDifOrigin(StrategyID==ThisStrategy);


MonthSeries=(min(StartDif):max(EndDif))';
MonthSeriesDateFormat=DateFormat(MonthSeries);
c=zeros(length(MonthSeries),length(RawStr));
C=cell(length(MonthSeries),length(RawStr));


for i = 1:length(RawStr)
    a=RawStr{i};
    for j = 1 : fix(length(a)/16)
        Bgn=16*j-5;
        End=16*j+10;
         adjdata=a(Bgn:End);
         adjdata = regexp(adjdata, sprintf('\\w{1,%d}', 2), 'match'); %split single string 
         adjdata=strrep(strjoin(fliplr(adjdata)),' ',''); %delete unnecessary space
        %          C{j,i}= hex2num(adjdata);
           C{find(MonthSeries==StartDif(i))+j-1,i}= hex2num(adjdata);
         c(find(MonthSeries==StartDif(i))+j-1,i)=hex2num(adjdata);
    end   
end

% Cellcombo1= vertcat(RawName',C);
% ddddddd=num2cell([0;MonthSeries]);
% Cellcombo2= horzcat(ddddddd,Cellcombo1);
% 
% filename=['234Strategy_Trans.xlsx'];
% xlswrite(filename,Cellcombo2);

disp('Transformation finished')

%%
if 1==1
    % rolling 6 months return
    e=zeros(length(MonthSeries),length(RawStr));
%d=zeros(length(MonthSeries)-(36-1),length(RawStr));
for i = 1:length(RawStr)
    fundret=c(:,i);
    effectivefundrettime=MonthSeries(fundret~=0);
    effectivefundlocation=find(fundret~=0);
OverlapBgn=max(effectivefundrettime(1),SPXdate(1));
OvetlapEnd=min(effectivefundrettime(length(effectivefundrettime)),SPXdate(length(SPXdate)));

    matchfundret=fundret(MonthSeries>=OverlapBgn&MonthSeries<=OvetlapEnd);
matchSPXret=SPXret(SPXdate>=OverlapBgn&SPXdate<=OvetlapEnd);
for k=6:length(matchfundret)
    rollingfundret=matchfundret(k-6+1:k);
    %rollingSPXret=matchSPXret(k-6+1:k);
    cumrollingfundret=prod(rollingfundret+1)-1;
    e(effectivefundlocation(1)+k-1,i)=cumrollingfundret;
end
end


TimeLength=size(e,1);
CumRetQuantile5=zeros(TimeLength,1);
CumRetQuantile25=zeros(TimeLength,1);
 CumRetQuantile50=zeros(TimeLength,1);
 CumRetQuantile75=zeros(TimeLength,1);
 CumRetQuantile95=zeros(TimeLength,1);
for i=1:TimeLength
    cumrollingfundretThisDate=e(i,:);
     cumrollingfundretThisDate=cumrollingfundretThisDate(not(isnan(cumrollingfundretThisDate))&cumrollingfundretThisDate~=0);
     if size(cumrollingfundretThisDate,2)>=20
         CumRetQuantile5(i)=quantile(cumrollingfundretThisDate,0.05);
         CumRetQuantile25(i)=quantile(cumrollingfundretThisDate,0.25);
          CumRetQuantile50(i)=quantile(cumrollingfundretThisDate,0.5);
           CumRetQuantile75(i)=quantile(cumrollingfundretThisDate,0.75);
           CumRetQuantile95(i)=quantile(cumrollingfundretThisDate,0.05);
     else
         CumRetQuantile5(i)=NaN;
         CumRetQuantile25(i)=NaN;
          CumRetQuantile50(i)=NaN;
           CumRetQuantile75(i)=NaN;
           CumRetQuantile95(i)=NaN;
     end 
end

disp('Cum rolling 6 months return finished');

WorstDateDif=[506 537 429 418 411];
for  mmm=1:length(WorstDateDif)
    chartdata25(mmm,ThisStrategy)=CumRetQuantile25(MonthSeries==WorstDateDif(mmm));
    chartdata50(mmm,ThisStrategy)=CumRetQuantile50(MonthSeries==WorstDateDif(mmm));
    chartdata75(mmm,ThisStrategy)=CumRetQuantile75(MonthSeries==WorstDateDif(mmm));
end

disp('Worst data finished');

end
   

%%
if 1==1
    % rolling 3 yr correlation
    d=zeros(length(MonthSeries),length(RawStr));
%d=zeros(length(MonthSeries)-(36-1),length(RawStr));
for i = 1:length(RawStr)
    fundret=c(:,i);
    effectivefundrettime=MonthSeries(fundret~=0);
    effectivefundlocation=find(fundret~=0);
OverlapBgn=max(effectivefundrettime(1),SPXdate(1));
OvetlapEnd=min(effectivefundrettime(length(effectivefundrettime)),SPXdate(length(SPXdate)));

    matchfundret=fundret(MonthSeries>=OverlapBgn&MonthSeries<=OvetlapEnd);
matchSPXret=SPXret(SPXdate>=OverlapBgn&SPXdate<=OvetlapEnd);
for k=36:length(matchfundret)
    rollingfundret=matchfundret(k-36+1:k);
    rollingSPXret=matchSPXret(k-36+1:k);
    rollingcorrelation=corr(rollingSPXret,rollingfundret);
    d(effectivefundlocation(1)+k-1,i)=rollingcorrelation;
end
end


TimeLength=size(d,1);
 Quantile25=zeros(TimeLength,1);
 Quantile50=zeros(TimeLength,1);
 Quantile75=zeros(TimeLength,1);
for i=1:TimeLength
    CorrThisDate=d(i,:);
     CorrThisDate=CorrThisDate(not(isnan(CorrThisDate))&CorrThisDate~=0);
     if size(CorrThisDate,2)>=20
         Quantile25(i)=quantile(CorrThisDate,0.25);
          Quantile50(i)=quantile(CorrThisDate,0.5);
           Quantile75(i)=quantile(CorrThisDate,0.75);
     else
         Quantile25(i)=NaN;
          Quantile50(i)=NaN;
           Quantile75(i)=NaN;
     end 
end

disp('Correlation finished');

hold on    
subplot(2,3,ThisStrategy);

plot(MonthSeries,Quantile25,':b');
hold on
plot(MonthSeries,Quantile50,'b');
hold on
plot(MonthSeries,Quantile75,':b');
hold on
%bar(MonthSeries,(Quantile75-Quantile25))
%fill([(Quantile75-Quantile25),0],[-1,0],'r');
title([StrategyName(1);'3-year Rolling Correlation to SPX']);
xlabel('Time');
ylabel('3-year Rolling Correlation to SPX');
legend('25%','50%','75%');
set(legend,'Location','SouthEast');
ylim([-1,1]);
xlim([337,584]);
% 337 stand for 1/1/1995 
% 584 stand for 8/31/2015
%set(gca,'xtick',MonthSeries([1:50:length(MonthSeries)]) );
%set(gca,'xticklabel',MonthSeriesDateFormat(1:50:length(MonthSeries)));
set(gca,'xtick',337:50:584);
set(gca,'xticklabel',{'1995','2000','2005','2010','2015'});

disp('Figure finished');

end

end

print(CorrelationFigure,'-dpdf',[num2str(ThisStrategy),' 3-year Rolling Correlation to SPX']);

disp('All finished');




