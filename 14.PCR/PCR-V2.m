
%% =====================================================================
%---------------SECTION I: Setup and Loading----------------------------
%=======================================================================
LoadData

% Revert data series
Funds=Funds(end:-1:1,:);
PRIM=PRIM(end:-1:1,:);
Factors=Factors(end:-1:1,:);
Dates=Dates(end:-1:1);

% Set target fund of analysis and factors to use
UserFilteredFundID=input('\nPlease type in the IDs of funds you want to test, in square brackets.\nFor example:\n[1 5 6 7 8]\n');
numberoffund=size(UserFilteredFundID,2);
[NSample NFactors]= size(Factors);
UserFilteredFactorID=1:NFactors;
% Adjust variables when the variables have very different amounts of variability
%adjFactors=zscore(Factors);


%% =====================================================================
%-----SECTION II: Principal Componenets Analysis on Explicit Factors----
%=======================================================================
[PCAloading,PCAscore,PCAvar,~,explained,mu]= pca(Factors);
CumExplanatoryPower = (cumsum(PCAvar)./sum(PCAvar))*100;
%disp('EigenVector')
%coeff
%disp('EigenValue')
%latent
FactorID=[1:length(explained)]';
disp('ExplanatoryPower')
disp('FactorID  FactorPower  CumPower')
disp([FactorID, explained,CumExplanatoryPower]);

PCnum=input('\n Choosing the number of components:\n');


%% =====================================================================
%--------------SECTION III: Principal Componenets Regresstion-----------
%=======================================================================
% Set parameters and variables
whichstats={'tstat','adjrsquare','rsquare','yhat'};
BetaPC=zeros(PCnum,numberoffund);
BetaFactors=zeros(NFactors,numberoffund);
SameVolbetaFactors=zeros(NFactors,numberoffund);
BetaPCR=zeros(NFactors+1,numberoffund);
PVal=zeros(PCnum,numberoffund);                                     
AdjR2=zeros(1,numberoffund);                                                         
R2=zeros(1,numberoffund);  
RiskAdjMonthlyAlpha=zeros(1,numberoffund);
RiskAdjAlpha=zeros(1,numberoffund);
R2PRIM =zeros(1,numberoffund);
ApraisalRatioPRIM = zeros(1,numberoffund);

for nn =1 : numberoffund
    TargetFundID= UserFilteredFundID(nn);
    TargetFund=Funds(:,TargetFundID);
    
    %%Cut NaN dates
    %Dates=Dates(not(isnan(TargetFund)));
    %Factors=Factors(not(isnan(TargetFund)),:);
    %TargetFund=TargetFund(not(isnan(TargetFund)));
    
    % Principal componenets regresstion and statistic
    stats= regstats(TargetFund-mean(TargetFund),PCAscore(:,1:PCnum),'linear',whichstats);
    BetaPC(:,nn)=stats.tstat.beta(2:end);  % beta of selected PC
    PVal(:,nn)=stats.tstat.pval(2:end);                                    
    AdjR2(1,nn)=stats.adjrsquare;                                                        
    %R2(1,nn)=stats.adjrsquare;
    
    % To make the PCR results easier to interpret in terms of the original explicit factors
    % transform betaPC into regression coefficients for the original, uncentered variables.
    BetaFactors(:,nn)= PCAloading(:,1:PCnum)*BetaPC(:,nn);  
    BetaPCR = [mean(TargetFund) - mean(Factors)*BetaFactors(:,nn); BetaFactors(:,nn)];
    yfitPCR = [ones(NSample,1) Factors]*BetaPCR;
    
    
    % Calculate same vol coefficients and monthly actual alpha
    FundVol=std(TargetFund);
    FactorPortfolioVol= std(yfitPCR);  
    SameVolFactorPortfolioReturn = yfitPCR *FundVol/FactorPortfolioVol;
    SameVolbetaFactors(:,nn) = BetaFactors(:,nn)*FundVol/FactorPortfolioVol;
    
     
    SameVolFactorPortfolioReturn= Factors * SameVolbetaFactors(:,nn);
    RiskAdjMonthlyAlpha = TargetFund-SameVolFactorPortfolioReturn;
    RiskAdjAlpha(1,nn) = mean(RiskAdjMonthlyAlpha)*12;
    ApraisalRatio(1,nn) = RiskAdjAlpha(1,nn)/std(RiskAdjMonthlyAlpha*12^0.5);
    
    % Calculate R^2 and adjusted R^2
    % TSS = sum((TargetFund-mean(TargetFund)).^2);
    % RSS = sum((TargetFund-SameVolFactorPortfolioReturn).^2);
    % R2(1,nn) = 1 - RSS/TSS;
    % AdjR2(1,nn) = 1-(1-R2(1,nn))*(NSample-1)/(NSample-NFactors-1);
    

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
%% =====================================================================
%---------------SECTION V: Generate Alpha List--------------------------
%=======================================================================
Names=FundNames(UserFilteredFundID);
header = {'FundID','FundName','AdjR2','Alpha','AR','R-Square PRIM','AR PRIM',FactorNames{UserFilteredFactorID}};
T =table(UserFilteredFundID', Names',AdjR2(1,:)',RiskAdjAlpha(1,:)',ApraisalRatio(1,:)',R2PRIM',ApraisalRatioPRIM',SameVolbetaFactors');
filename ='Alpha_AR_Stats_PCR.xlsx';
writetable(T,filename);
xlswrite(filename,header,'sheet1','A1');


disp('All Funds excel finished')
