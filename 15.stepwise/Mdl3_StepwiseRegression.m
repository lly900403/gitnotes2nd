LoadData
%% =====================================================================
%---------------SECTION I: Setup and Loading----------------------------
%=======================================================================
% Revert data series
Funds=Funds(end:-1:1,:);
PRIM=PRIM(end:-1:1,:);
Factors=Factors(end:-1:1,:);
Dates=Dates(end:-1:1);

UserFilteredFundID=input('\nPlease type in the IDs of funds you want to test, in square brackets.\nFor example:\n[1 5 6 7 8]\n');
numberoffund=size(UserFilteredFundID,2);
[NSample NFactors]= size(Factors);
numberoffund=size(UserFilteredFundID,2);
UserFilteredFactorID=1:NFactors;

penter=input('\nThe maximum p value for a term to be added (default is 0.05).\n');
premove=input('\nThe minimum p value for a term to be removed(default is 0.10).\n');


%% =====================================================================
%---------------SECTION II: Stepwise Regression-------------------------
%=======================================================================
% Set parameters and variables
whichstats={'tstat','adjrsquare','rsquare','yhat'};
PVal=cell(NFactors,numberoffund);
SameVolCoefficientDist=cell(NFactors,numberoffund);
RiskAdjMonthlyAlpha=zeros(1,numberoffund);
RiskAdjAlpha=zeros(1,numberoffund);
ApraisalRatio=zeros(1,numberoffund);
AdjR2=zeros(1,numberoffund);                                                         
R2=zeros(1,numberoffund);  
R2PRIM =zeros(1,numberoffund);
ApraisalRatioPRIM = zeros(1,numberoffund);


for nn =1 : numberoffund
    TargetFundID= UserFilteredFundID(nn);
    TargetFund=Funds(:,TargetFundID);

    % Cut NaN dates
    %Dates=Dates(not(isnan(TargetFund)));
    %Factors=Factors(not(isnan(TargetFund)),:);
    %TargetFund=TargetFund(not(isnan(TargetFund)));
    %UserFilteredFactorID=UserFilteredFactorID(sum(isnan(Factors(:,UserFilteredFactorID)))==0);
    
    %mdl = stepwiselm(Factors,TargetFund,'linear')
    [b,~,pval,inmodel,stats,~,~] = stepwisefit(Factors,TargetFund,'penter',penter,'premove',premove,'display','off');
    % Factor ID of variables in the final model
    FactorIDCombo=find(inmodel);
    Coefficient= b(FactorIDCombo); % Coefficient estimate for terms in the final model
    PVal(FactorIDCombo,nn)= num2cell(pval(FactorIDCombo)); % p-values for coefficient
    SelectedFactors=Factors(:,FactorIDCombo); % Selected factor series 

    
    % Calculate same vol coefficients and monthly actual alpha
    yfit = SelectedFactors*Coefficient;
    FundVol=std(TargetFund);
    FactorPortfolioVol= std(yfit);
    SameVolCoefficient = Coefficient*FundVol/FactorPortfolioVol;
    SameVolFactorPortfolioReturn = SelectedFactors*SameVolCoefficient;
    RiskAdjMonthlyAlpha = TargetFund-SameVolFactorPortfolioReturn;
    RiskAdjAlpha(1,nn) = mean(RiskAdjMonthlyAlpha)*12;
    ApraisalRatio(1,nn) = RiskAdjAlpha(1,nn)/std(RiskAdjMonthlyAlpha*12^0.5);
    %Store same volatility coefficients
    SameVolCoefficientDist(FactorIDCombo,nn)= num2cell(SameVolCoefficient);
    
    %Calculate R^2 and adjusted R^2
    TSS = stats.SStotal;
    RSS = stats.SSresid;
    R2(1,nn) = 1 - RSS/TSS;
    AdjR2(1,nn) =1 - (1-R2(1,nn))*(stats.dfe+stats.df0)/(stats.dfe);
    
    
%% =====================================================================
%---------------SECTION IV: PRIM regression---------------------------
%=======================================================================
    PRIMstats=regstats(TargetFund,PRIM,'linear',whichstats);    
    CoefficientsPRIM=PRIMstats.tstat.beta;
    R2PRIM(1,nn)=PRIMstats.rsquare; 
    %  SameVolFactorPortfolio(Periods{FirstOrSecond})=SelectedFactors{FirstOrSecond}*SameVolCoefficients{FirstOrSecond}(2:end);
    SimuPRIMPortfolio= PRIM*CoefficientsPRIM(2:end);
    AlphaPRIM=TargetFund-SimuPRIMPortfolio;
    ApraisalRatioPRIM(1,nn)= mean(AlphaPRIM)*12/(std(AlphaPRIM)*12^0.5);

end
disp('Regression finished')
%% =====================================================================
%---------------SECTION V: Generate Alpha List--------------------------
%=======================================================================
%table of beta exposure
Names=FundNames(UserFilteredFundID);
header = {'FundID','FundName','Alpha','AR','AdjR2','AR PRIM','R-Square PRIM',FactorNames{UserFilteredFactorID}};
T =table(UserFilteredFundID', Names',RiskAdjAlpha(1,:)',ApraisalRatio(1,:)',AdjR2(1,:)',ApraisalRatioPRIM',R2PRIM',SameVolCoefficientDist');
filename ='Alpha_AR_Stats_Stepwise.xlsx';
writetable(T,filename);
xlswrite(filename,header,'sheet1','A1');
%table of p-value
header = {'FundID','FundName','Alpha','AR','AdjR2','AR PRIM','R-Square PRIM',FactorNames{UserFilteredFactorID}};
T2 =table(UserFilteredFundID', Names',RiskAdjAlpha(1,:)',ApraisalRatio(1,:)',AdjR2(1,:)',ApraisalRatioPRIM',R2PRIM',PVal');
filename ='Alpha_AR_Stats_Stepwise_pvalue.xlsx';
writetable(T2,filename);
xlswrite(filename,header,'sheet1','A1');

disp('All Funds excel finished')

