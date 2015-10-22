%% =====================================================================
%---------------------------Part 0: Load data---------------------------
%=======================================================================

clear;
clc;

% Load factor data
[TempData1,TempData2,TempDataRawFactors] = xlsread('HFRI_NAV.xlsx');
IndexNames=TempDataRawFactors(1,2:end);
IndexNAV=TempData1(end:-1:1,:); %reverse NAV data
benchmark=cell(1,2);
correlation=cell(1,2);
beta=cell(1,2);


%% =====================================================================
%---------------Part 1: Correlation and Beta Estimates------------------
%=======================================================================
IndexROR=IndexNAV(1:end-1,:)./IndexNAV(2:end,:)-1; %calculate monthly return
[n p]=size(IndexROR);

for m=1:2    %set up benchmark index                       
    benchmarkindex=IndexROR(:,m);   
    correlation{m}=cell(n-59,p-2);
    beta{m}=cell(n-59,p-2);
    for i=1:p-2           %choose target HFRI index
        for ii=1:n-59     %set up rolling period (60 month/period)
            Targetindex=IndexROR(ii:ii+59,i+2);     %select index data in the rolling period
            benchmark=benchmarkindex(ii:ii+59);     %select benchmark data in the rolling period
            count=sum(isnan(Targetindex));          %count nan data in index data
            if count==0
                correlation{m}{ii,i}=corr(Targetindex,benchmark); %calculate rolling correlation
                stats=regstats(Targetindex,benchmark,'linear',{'beta'});
                beta{m}{ii,i}=stats.beta(2);                      %calculate rolling beta
            else
                correlation{m}{ii,i}='#N/A';
                beta{m}{ii,i}='#N/A';
            end 
        end
    end
end

disp('correlation and beta finished')

%% =====================================================================
%---------------Part 2: Cumulated return and Drawdown ---------------
%=======================================================================
%calculate monthly return
IndexCumROR=IndexNAV(1:end-6,:)./IndexNAV(7:end,:)-1; 

%calculate drawdown and maximun drawdown
IndexNAVDD=IndexNAV(end:-1:1,:); %revert reversed NAV data
DateDD=TempData2(2:end,1); 
DD=cell(1,2);
peakmonth=cell(1,2);
[N P]=size(IndexNAVDD);

for m=1:2
    DD{m}=zeros(N,P);
    peakmonth{m}=cell(N,1);
    peak=-99999;
    for i =1:N
        if IndexNAVDD(i,m)>peak  %record peak data and data panel 
            peak=IndexNAVDD(i,m);
            peakpanel=IndexNAVDD(i,:);
            peakmonth{m}(i)=DateDD(i);
        end
        DD{m}(i,:)=(IndexNAVDD(i,:)-peakpanel)./peakpanel; %drawdown, should be a negative return
    end 
end 

%% =====================================================================
%-----------------------Part 3: Generate excel -----------------------
%=======================================================================
%  5YEAR rolling correlation and beta
filename ='HFRI_analysis.xlsx';
Date=TempData2(3:end,1);
Date=Date(end:-1:1,:);
Date1=Date(1:250);

header = {'Date',IndexNames{1,3:end}};

T1 =vertcat(header,horzcat(Date1,beta{1}));
T2 =vertcat(header,horzcat(Date1,beta{2}));
T3 =vertcat(header,horzcat(Date1,correlation{1}));
T4 =vertcat(header,horzcat(Date1,correlation{2}));

%Cumulative return 
Date2=Date(1:304);
header2 = {'Date',IndexNames{1,1:end}};
T5 =vertcat(header2,horzcat(Date2,num2cell(IndexCumROR)));

                
%drawdown 
T6 =vertcat(header2,horzcat(DateDD,num2cell(DD{1})));
T7 =vertcat(header2,horzcat(DateDD,num2cell(DD{2})));

%create table
xlswrite(filename,T1,'beta(s&p)','A1');
xlswrite(filename,T2,'beta(world)','A1');
xlswrite(filename,T3,'corr(s&p)','A1');
xlswrite(filename,T4,'corr(world)','A1');    
xlswrite(filename,T5,'6MCumROR','A1');
xlswrite(filename,T6,'Drawdown(s&p)','A1');
xlswrite(filename,T7,'Drawdown(world)','A1');

disp('HFRI_analysis.xlsx Created')
disp('All finished')
