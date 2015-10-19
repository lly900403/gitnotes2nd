>>  help stepwisefit
 stepwisefit Fit regression model using stepwise regression
    B=stepwisefit(X,Y) uses stepwise regression to model the response variable
    Y as a function of the predictor variables represented by the columns
    of the matrix X.  The result B is a vector of estimated coefficient values
    for all columns of X.  The B value for a column not included in the final
    model is the coefficient that would be obtained by adding that column to
    the model.  stepwisefit automatically includes a constant term in all
    models.
 
    [B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwisefit(...) returns additional
    results.  
SE is a vector of standard errors for B.  
PVAL is a vector of p-values for testing if B is 0.  
INMODEL is a logical vector indicating which predictors are in the final model.  
STATS is a structure containing additional statistics.  
NEXTSTEP is the recommended next step -- either the index of the next predictor to move in or out, or 0 if no further
    steps are recommended.  
HISTORY is a structure containing information about the history of steps taken.
 
    [...]=stepwisefit(X,Y,'PARAM1',val1,'PARAM2',val2,...) specifies one or
    more of the following name/value pairs:
 
      'inmodel'  A logical vector, or a list of column numbers, indicating which
                 predictors to include in the initial fit (default none)
      'penter'   Max p-value for a predictor to be added (default 0.05)
      'premove'  Min p-value for a predictor to be removed (default 0.10)
      'display'  Either 'on' (default) to display information about each
                 step or 'off' to omit the display
      'maxiter'  Maximum number of steps to take (default is no maximum)
      'keep'     A logical vector, or a list of column numbers, indicating which
                 predictors to keep in their initial state (default none)
      'scale'    Either 'on' to scale each column of X by its standard deviation
                 before fitting, or 'off' (the default) to omit scaling.
 
    Example:
       load hald 
       stepwisefit(ingredients,heat,'penter',.08)

    Reference page in Help browser
       doc stepwisefit

>> [B,SE,PVAL,INMODEL,STATS,NEXTSTEP,HISTORY]=stepwisefit(Factors,TargetFund)
Initial columns included: none
Step 1, added column 7, p=0.00165387
Step 2, added column 16, p=0.0403401
Step 3, added column 9, p=0.00732499
Final columns included:  7 9 16 
    'Coeff'      'Std.Err.'    'Status'    'P'     
    [ 0.0832]    [  0.1021]    'Out'       [0.4207]
    [ 0.0962]    [  0.0758]    'Out'       [0.2122]
    [-0.0734]    [  0.0615]    'Out'       [0.2405]
    [ 0.1283]    [  0.1450]    'Out'       [0.3820]
    [-0.1570]    [  0.2292]    'Out'       [0.4978]
    [ 0.1907]    [  0.1225]    'Out'       [0.1282]
    [-0.4709]    [  0.1861]    'In'        [0.0158]
    [ 0.1332]    [  0.1546]    'Out'       [0.3945]
    [ 0.3152]    [  0.1111]    'In'        [0.0073]
    [ 0.0440]    [  0.0976]    'Out'       [0.6549]
    [ 0.0253]    [  0.0777]    'Out'       [0.7471]
    [-0.0572]    [  0.0993]    'Out'       [0.5684]
    [-0.1385]    [  0.1141]    'Out'       [0.2330]
    [-0.0039]    [  0.1138]    'Out'       [0.9726]
    [-0.5562]    [  0.4240]    'Out'       [0.1979]
    [ 0.6706]    [  0.2309]    'In'        [0.0062]
    [-0.7884]    [  0.5249]    'Out'       [0.1419]
    [-0.0984]    [  0.1368]    'Out'       [0.4766]


B =

    0.0832
    0.0962
   -0.0734
    0.1283
   -0.1570
    0.1907
   -0.4709
    0.1332
    0.3152
    0.0440
    0.0253
   -0.0572
   -0.1385
   -0.0039
   -0.5562
    0.6706
   -0.7884
   -0.0984


SE =

    0.1021
    0.0758
    0.0615
    0.1450
    0.2292
    0.1225
    0.1861
    0.1546
    0.1111
    0.0976
    0.0777
    0.0993
    0.1141
    0.1138
    0.4240
    0.2309
    0.5249
    0.1368


PVAL =

    0.4207
    0.2122
    0.2405
    0.3820
    0.4978
    0.1282
    0.0158
    0.3945
    0.0073
    0.6549
    0.7471
    0.5684
    0.2330
    0.9726
    0.1979
    0.0062
    0.1419
    0.4766


INMODEL =

  Columns 1 through 16

     0     0     0     0     0     0     1     0     1     0     0     0     0     0     0     1

  Columns 17 through 18

     0     0


STATS = 

       source: 'stepwisefit'
          dfe: 37
          df0: 3
      SStotal: 0.0147
      SSresid: 0.0084
        fstat: 9.3894
         pval: 9.5191e-05
         rmse: 0.0150
           xr: [41x15 double]
           yr: [41x1 double]
            B: [18x1 double]
           SE: [18x1 double]
        TSTAT: [18x1 double]
         PVAL: [18x1 double]
         covb: [18x18 double]
    intercept: 0.0096
       wasnan: [41x1 logical]


NEXTSTEP =

     0


HISTORY = 

       B: [18x3 double]
    rmse: [0.0171 0.0164 0.0150]
     df0: [1 2 3]
      in: [3x18 logical]

>>
