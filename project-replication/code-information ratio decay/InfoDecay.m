clear;
clc;
close all;
load RawReturnsFlat.mat

FundNames=transpose(FundNames);

AnalysisNameIDs=4:9;
AnalysisQuarterIDs=1:14;


LengthOfPeriod=262;

alpha=zeros(261,9,14);
alphaVol=zeros(261,9,14);
beta=zeros(261,9,14);
ir=zeros(261,9,14);

for QuarterID=AnalysisQuarterIDs
    for NameID=AnalysisNameIDs
        SelectedBenchmark=RawReturns.(strcat('SP500',Quarters{QuarterID}));
        SelectedPortfolio=RawReturns.(strcat(FundNames{NameID},Quarters{QuarterID}));
        % add new 4 rows following the selected portoflio returns
        SelectedPortfolio=[SelectedPortfolio,zeros(size(SelectedPortfolio,1),4)];
        
        for lag=1:261
            %stats=regstats(SelectedPortfolio(lag:lag+LengthOfPeriod-1,1),SelectedBenchmark(lag:lag+LengthOfPeriod-1,1),'linear','beta');
            stats=regstats(SelectedPortfolio(:,1),SelectedBenchmark(:,1),'linear','beta');
            %stats.beta(2)=staticBeta(NameID);
            % the 1st row is the return of the selected portfoio
            % the 2nd row is the beta of the selected portfolio
            SelectedPortfolio(lag,2)=stats.beta(2);
            % the 3rd row is the mean of alpha of the selected portofio
            SelectedPortfolio(lag,3)=...
                mean(SelectedPortfolio(lag:lag+LengthOfPeriod-1,1)-stats.beta(2)*SelectedBenchmark(lag:lag+LengthOfPeriod-1),1)*261;
            % the 4th row is the std of alpha of the selected portoflio
            SelectedPortfolio(lag,4)=...
                ((std(SelectedPortfolio(lag:lag+LengthOfPeriod-1,1)-stats.beta(2)*SelectedBenchmark(lag:lag+LengthOfPeriod-1),1))^2*...
                LengthOfPeriod/(LengthOfPeriod-1))^0.5*sqrt(LengthOfPeriod);    
           % the 5th row is the apprasial ratio of the selected portfolio
            SelectedPortfolio(lag,5)=...
                SelectedPortfolio(lag,3)/SelectedPortfolio(lag,4); 
        end

        %Alpha.(FundNames{NameID})(:,QuarterID)=SelectedPortfolio(1:261,3);
        %IR.(FundNames{NameID})(:,QuarterID)=SelectedPortfolio(1:261,5);
        alpha(:,NameID,QuarterID)=SelectedPortfolio(1:261,3);
        alphaVol(:,NameID,QuarterID)=SelectedPortfolio(1:261,4);
        beta(:,NameID,QuarterID)=SelectedPortfolio(1:261,2);
        ir(:,NameID,QuarterID)=SelectedPortfolio(1:261,5);
        
    end
end

figure

% subplot(2,2,1);
% hold on
% for NameID=AnalysisNameIDs
%     plot(mean(Alpha.(FundNames{NameID}),2));
% end
% 
% 
% legend(FundNames{AnalysisNameIDs});
% 
% subplot(2,2,2);    
% hold on
% for NameID=AnalysisNameIDs
%     plot(mean(IR.(FundNames{NameID}),2));
% end
% legend(FundNames{AnalysisNameIDs});

subplot(2,2,1);
plot(mean(alpha(:,AnalysisNameIDs,AnalysisQuarterIDs),3))
legend(strcat('2mLagAlpha=',...
    cellstr(num2str(100*mean(squeeze(alpha(43,AnalysisNameIDs,AnalysisQuarterIDs)),2),'%.1f%%')),',',FundNames(AnalysisNameIDs)));

subplot(2,2,3);
plot(mean(beta(:,AnalysisNameIDs,AnalysisQuarterIDs),3))
legend(strcat('2mLagBeta=',...
    cellstr(num2str(mean(squeeze(beta(43,AnalysisNameIDs,AnalysisQuarterIDs)),2),'%.2f')),',',FundNames(AnalysisNameIDs)));

% subplot(2,2,4)
% plot(squeeze(mean(beta(:,AnalysisNameIDs,AnalysisQuarterIDs),1)),'*')
% set(gca,'XTickLabel',{'BH','.', 'Childrens','.',  'JANA','.',  'Pershing','.',  'Trian','.',  'VA','.',})

subplot(2,2,2);
plot(transpose(squeeze(alphaVol(1,AnalysisNameIDs,AnalysisQuarterIDs))))
legend(strcat('AlphaVol=',...
    cellstr(num2str(100*mean(squeeze(alphaVol(1,AnalysisNameIDs,AnalysisQuarterIDs)),2),'%.1f%%')),',',FundNames(AnalysisNameIDs)));

subplot(2,2,4);
plot(transpose(squeeze(beta(1,AnalysisNameIDs,AnalysisQuarterIDs))))
hold on;
plot(transpose(mean(squeeze(beta(1,AnalysisNameIDs,AnalysisQuarterIDs)),1)),'-ob')
legend(strcat('Beta=',...
    cellstr(num2str(mean(squeeze(beta(1,AnalysisNameIDs,AnalysisQuarterIDs)),2),'%.2f')),',',FundNames(AnalysisNameIDs)));
