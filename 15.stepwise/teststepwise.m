nn=21; 
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
    
    %stepwise(Factors,TargetFund)
%stepwise(Factors,TargetFund,inmodel,penter,premove)
%[B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwisefit(Factors,TargetFund)
