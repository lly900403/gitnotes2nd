LoadData

%% =====================================================================
%---------------SECTION I: Setup and Loading----------------------------
%=======================================================================

% Set target fund of analysis and factors to use

UserFilteredFundID=input('\nPlease type in the IDs of funds you want to test, in square brackets.\nFor example:\n[1 5 6 7 8]\n');

numberoffund=size(UserFilteredFundID,2);

UserFilteredFactorID=1:12;

% Revert data series
Funds=Funds(end:-1:1,:);
PRIM=PRIM(end:-1:1,:) ;
Factors=Factors(end:-1:1,:);
Dates=Dates(end:-1:1);



for nn=1 : numberoffund
    
TargetFundID= UserFilteredFundID(nn);
%NFirstHalf=input('\nPlease type in the number of observations to be used for in-sample analysis:\n');
%PValThreshold=input('\nPlease type in a number between 0 and 1 as the p-value threshold for each individual factor:\n');
%CoefficientThreshold=input('\nPlease type in a positive number as the Coefficient Threshold:\n');



TargetFund=Funds(:,TargetFundID);

% Cut NaN dates
Dates=Dates(not(isnan(TargetFund)));
Factors=Factors(not(isnan(TargetFund)),:);
TargetFund=TargetFund(not(isnan(TargetFund)));
UserFilteredFactorID=UserFilteredFactorID(sum(isnan(Factors(:,UserFilteredFactorID)))==0);  %filter out factors with incomplete data

% Set parameters
NMonth=length(Dates);
NFirstHalf=NMonth;
Periods{1}=(1:NFirstHalf)';
Periods{2}=(NFirstHalf+1:NMonth)';
NFactors=4;
NFactors=min(NFactors,length(UserFilteredFactorID));
whichstats={'tstat','adjrsquare','rsquare','yhat'};

%% =====================================================================
%---------------SECTION II: Static--------------------------------------
%=======================================================================

% declare variable
CoefficientsDist=cell(1,2);
CoefficientsDistGlobalFormat=cell(1,2);
PValDist=cell(1,2); 
AdjR2Dist=cell(1,2); 
R2Dist=cell(1,2); 
SelectedTrial=cell(1,2); 
RankAdjR2Dist=cell(1,2); 
RankR2Dist=cell(1,2); 
SelectedFactorID=cell(1,2); 
SelectedFactorNames=cell(1,2);
Coefficients=cell(1,2); 
PVal=cell(1,2); 
BestAdjR2=cell(1,2); 
BestR2=cell(1,2); 
SelectedFactors=cell(1,2);

FactorPortfolioReturnDist=cell(1,2); 
VolRatioDistStacked=cell(1,2); 
VolAdjAlphaDist=cell(1,2); 
Corrcoef=cell(1,2); 

FactorIDCombo=nchoosek(UserFilteredFactorID,NFactors);                            % generate all combinations of factor ID combinations
NTrials=size(FactorIDCombo,1);                                                    % calculate number of combinations/trials for this iteration


SameVolFactorPortfolio=zeros(NMonth,1);

for FirstOrSecond=1:1

    CoefficientsDist{FirstOrSecond}=zeros(NFactors+1,NTrials);                                          % declare variable
    CoefficientsDistGlobalFormat{FirstOrSecond}=zeros(size(Factors,2),NTrials);
    PValDist{FirstOrSecond}=zeros(NFactors+1,NTrials);                                                  % declare variable
    AdjR2Dist{FirstOrSecond}=zeros(1,NTrials);                                                          % declare variable
    R2Dist{FirstOrSecond}=zeros(1,NTrials);                                                             % declare variable

    for i=1:NTrials
        stats{1}=regstats(TargetFund(1:NFirstHalf),Factors(1:NFirstHalf,FactorIDCombo(i,:)),...
            'linear',whichstats);                                                                           % regress
        %stats{2}=regstats(TargetFund(1+NFirstHalf:end),Factors(1+NFirstHalf:end,FactorIDCombo(i,:)),...
        %    'linear',whichstats);                                                                           % regress    

        CoefficientsDist{FirstOrSecond}(:,i)=stats{FirstOrSecond}.tstat.beta;                                       % store beta & alpha
        CoefficientsDistGlobalFormat{FirstOrSecond}(FactorIDCombo(i,:),i)=stats{FirstOrSecond}.tstat.beta(2:end);   % store beta & alpha
        PValDist{FirstOrSecond}(:,i)=stats{FirstOrSecond}.tstat.pval;                                               % store p-value
        R2Dist{FirstOrSecond}(:,i)=stats{FirstOrSecond}.rsquare;                                                    % store p-value
        AdjR2Dist{FirstOrSecond}(:,i)=stats{FirstOrSecond}.adjrsquare;                                              % store adjusted r-squared            
    end 
    
    %FactorPortfolioReturnDist{FirstOrSecond}= Factors(Periods{FirstOrSecond},:)*CoefficientsDistGlobalFormat{FirstOrSecond};
    %VolRatioDistStacked{FirstOrSecond}=repmat(std(TargetFund(Periods{FirstOrSecond}))./std(FactorPortfolioReturnDist{FirstOrSecond}),size(Periods{FirstOrSecond}));
    %VolAdjAlphaDist{FirstOrSecond}=mean(TargetFund(Periods{FirstOrSecond}))-mean(VolRatioDistStacked{FirstOrSecond}.*FactorPortfolioReturnDist{FirstOrSecond});
    %Corrcoef{FirstOrSecond}=corrcoef([FactorPortfolioReturnDist{FirstOrSecond},TargetFund(Periods{FirstOrSecond})]);

    % SelectedTrial{FirstOrSecond}=AdjR2Dist{FirstOrSecond}==max(AdjR2Dist{FirstOrSecond});                   % select the highest AdjR2 trial
    RankAdjR2Dist{FirstOrSecond}=sort(AdjR2Dist{FirstOrSecond},'descend');
    %RankAdjR2Dist{FirstOrSecond}=RankAdjR2Dist{FirstOrSecond}(:,end:-1:1);
    RankR2Dist{FirstOrSecond}=sort(R2Dist{FirstOrSecond},'descend');
    %RankR2Dist{FirstOrSecond}=RankR2Dist{FirstOrSecond}(:,end:-1:1);
    
    Best20PctNTrails=round(NTrials*0.2);

    
    for ii=1:Best20PctNTrails
      
        SelectedTrial{FirstOrSecond}=AdjR2Dist{FirstOrSecond}== RankAdjR2Dist{FirstOrSecond}(ii);     
        SelectedFactorID{FirstOrSecond}=FactorIDCombo(SelectedTrial{FirstOrSecond},:);                          % assign selected trial's factor ID
        SelectedFactors{FirstOrSecond}=Factors(Periods{FirstOrSecond},SelectedFactorID{FirstOrSecond});         % assign selected trial's factors
        SelectedFactorNames{FirstOrSecond}=FactorNames(:,SelectedFactorID{FirstOrSecond});                      % assign selected trial's factor names
        Coefficients{FirstOrSecond}=CoefficientsDist{FirstOrSecond}(:,SelectedTrial{FirstOrSecond});            % assign selected trial's factor exposure coefficients
        PVal{FirstOrSecond}=PValDist{FirstOrSecond}(:,SelectedTrial{FirstOrSecond});                            % assign selected trial's p-value
        BestAdjR2{FirstOrSecond}=AdjR2Dist{FirstOrSecond}(:,SelectedTrial{FirstOrSecond});                      % assign selected trial's adjusted r-squared
        BestR2{FirstOrSecond}=R2Dist{FirstOrSecond}(:,SelectedTrial{FirstOrSecond});            

%% =====================================================================
%---------------SECTION V: Return Calculation--------------------------
%=======================================================================
    % Calculate same vol coefficients, factor portfolio, and monthly actual alpha
        FundVol{FirstOrSecond}=std(TargetFund(Periods{FirstOrSecond}));
        SameVolCoefficients{FirstOrSecond}=Coefficients{FirstOrSecond}*FundVol{FirstOrSecond}/std(SelectedFactors{FirstOrSecond}*Coefficients{FirstOrSecond}(2:end));
        SameVolFactorPortfolio(Periods{FirstOrSecond})=SelectedFactors{FirstOrSecond}*SameVolCoefficients{FirstOrSecond}(2:end);
        if ii==1
            FactorExposure(nn,:)=FundVol{FirstOrSecond}/std(SelectedFactors{FirstOrSecond}*Coefficients{FirstOrSecond}(2:end))*CoefficientsDistGlobalFormat{FirstOrSecond}(:,find(SelectedTrial{FirstOrSecond}))';
        end
        SameVolMonthlyActualAlpha{FirstOrSecond}=TargetFund(Periods{FirstOrSecond})-SameVolFactorPortfolio(Periods{FirstOrSecond});
        MeanSameVolMonthlyActualAlpha{FirstOrSecond}= mean(SameVolMonthlyActualAlpha{FirstOrSecond});
        ApraisalRatio{FirstOrSecond}= MeanSameVolMonthlyActualAlpha{FirstOrSecond}*12/(std(SameVolMonthlyActualAlpha{FirstOrSecond})*12^0.5);
        %ApraisalRatio{FirstOrSecond}=mean(SameVolMonthlyActualAlpha{FirstOrSecond})*12/(std(SameVolMonthlyActualAlpha{FirstOrSecond})*12^0.5);
    
    % Calculate factor contribution to returns
         ArithSameVolFactorContributionsWithActualAlpha{FirstOrSecond}...
         =12*[MeanSameVolMonthlyActualAlpha{FirstOrSecond},SameVolCoefficients{FirstOrSecond}(2:end)'.*mean(SelectedFactors{FirstOrSecond})];
         %=12*[mean(SameVolMonthlyActualAlpha{FirstOrSecond}),SameVolCoefficients{FirstOrSecond}(2:end)'.*mean(SelectedFactors{FirstOrSecond})];
    % nn=nth fund, ii=iist best fit
        Alpha(nn,ii)= 12*MeanSameVolMonthlyActualAlpha{FirstOrSecond};
        AR(nn,ii)= ApraisalRatio{FirstOrSecond};
        R2(nn,ii)= BestR2{FirstOrSecond};
    end
%% =====================================================================
%---------------SECTION VIII: PRIM regression-------------------------------
%=======================================================================
    PRIMstats=regstats(TargetFund(1:NFirstHalf),PRIM(1:NFirstHalf),'linear',whichstats);    
    CoefficientsPRIM=PRIMstats.tstat.beta;
    R2PRIM(nn,1)=PRIMstats.rsquare; 
    %  SameVolFactorPortfolio(Periods{FirstOrSecond})=SelectedFactors{FirstOrSecond}*SameVolCoefficients{FirstOrSecond}(2:end);
    SimuPRIMPortfolio= PRIM*CoefficientsPRIM(2:end);
    AlphaPRIM=TargetFund-SimuPRIMPortfolio;
    ApraisalRatioPRIM(nn,1)=mean(AlphaPRIM)*12/(std(AlphaPRIM)*12^0.5);
end

%% =====================================================================
%---------------SECTION VII: Static Charts-------------------------------
%=======================================================================
%R2AlphaScatter;

%R2AlphaARScatter;

%R2AlphaARScatterTop20Pct;
end
disp('All charts finished')

%% =====================================================================
%---------------SECTION VI: Generate Alpha List-------------------------
%=======================================================================

% Calculate avg alpha of best 20% Adjusted R2
% Best20PctNTrails=round(NTrials*0.2);

%Best20PctAlpha=Alpha(:,1:Best20PctNTrails);
%Best20PctAR=AR(:,1:Best20PctNTrails);

MeanBest20PctAlpha=zeros(nn,1);
StdBest20PctAlpha=zeros(nn,1);
MeanPerStdBest20PctAlpha=zeros(nn,1);
MeanBest20PctAR=zeros(nn,1);
StdBest20PctAR=zeros(nn,1);
MeanPerStdBest20PctAR=zeros(nn,1);

for i=1:nn
    MeanBest20PctAlpha(i,1)=mean(Alpha(i,:));
    MaxAlpha = max(Alpha,[],2);
    MinAlpha = min(Alpha,[],2);
    StdBest20PctAlpha(i,1)=std(Alpha(i,:));
    MeanPerStdBest20PctAlpha(i,1)=mean(Alpha(i,:))/std(Alpha(i,:)); 
    MeanBest20PctAR(i,1)=mean(AR(i,:));
    MaxAR= max(AR,[],2);
    MinAr = min(AR,[],2);
    StdBest20PctAR(i,1)=std(AR(i,:));
    MeanPerStdBest20PctAR(i,1)=mean(AR(i,:))/std(AR(i,:)); 
end

Names=FundNames(UserFilteredFundID);
header = {'FundID','FundName','R-Square MF(best)','Alpha mean/std(Best20%)','AR mean/std (Best20%)','R-Square PRIM','AR PRIM',FactorNames{UserFilteredFactorID}};
T =table(UserFilteredFundID', Names',R2(:,1),MeanPerStdBest20PctAlpha,MeanPerStdBest20PctAR,R2PRIM,ApraisalRatioPRIM,FactorExposure);
filename = 'R2-Alpha-AR-Stats.xlsx';
writetable(T,filename);
xlswrite(filename,header,'sheet1','A1');


disp('All Funds excel finished')

