clc;
clear;
[~,~,TempData] = xlsread('rawstr');
RawStr=TempData(2:end,3);
NewStr=RawStr;
RawName=TempData(2:end,1:2)';
RawDate=TempData(2:end,4:5)';

for i = 1:length(RawStr)
    a=RawStr{i};
  if mod((length(a)-10),16)>0
      NewStr{i}='00000000000000000000000000';
      %NewStr{i,:}=[];
      %RawName{i,:}=[];
  end
end
for i = 1:length(NewStr)
    a=NewStr{i};
    for j = 1 : fix(length(a)/16)
        Bgn=16*j-5;
        End=16*j+10;
         adjdata=a(Bgn:End);
         adjdata = regexp(adjdata, sprintf('\\w{1,%d}', 2), 'match'); %split single string 
         adjdata=strrep(strjoin(fliplr(adjdata)),' ',''); %delete unnecessary space
         C{j,i}= hex2num(adjdata);
         c(j,i)=hex2num(adjdata);
    end   
end

TestSum=sum(c,1);
Effect=find(TestSum~=0);
c1=c(:,Effect);
C1=C(:,Effect);
name=RawName(:,Effect);
date=RawDate(:,Effect);


disp('Transformation finished')

Cellcombo= vertcat(name,date,C1);
% to combine cells, the matrix can not be combined

% for excel
% one sheet is not enough to write, but one workbook is ok
% so write into 10 sheets in 1 workbook
for nn = 0:9
    filename=['US_HF_Datagroup_Liying.xlsx'];
    if nn<=8
        xlswrite(filename,Cellcombo(:,1000*nn+1:1000*(nn+1)),['Datagroup_',num2str(nn+1)],'A1');
    else
        % for the last 1 sheet, residual is not enough for 1000 funds
        xlswrite(filename,Cellcombo(:,1000*9+1:end),['Datagroup_',num2str(10)],'A1');
    end 
end 
disp('All Funds excel finished')

%T =table(name',c1');
%filename=['HF_DB_Trans.xlsx'];
%writetable(T,filename);