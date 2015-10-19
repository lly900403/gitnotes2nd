clear;


for nn=1:2
    [TempData1,TempData2,TempDataRawFactors] = xlsread('HexDataReturn_testcut.xlsx',nn);
    DataHex=TempDataRawFactors(6:end,1:end); %remember to change range later
    Header=TempDataRawFactors(1:5,1:end);
    [n p]=size(DataHex);
    DataDec=cell(1500,500); %%% NEED TO CHANGE THE ROW NUMBER
    for j =1:p
        for i=1:n 
            adjdata=DataHex{i,j}; 
            if isnan(adjdata)==1 
                DataDec{i,j}=blanks(2);
            elseif size(adjdata,1)==0
                DataDec{i,j}=blanks(2);
            else
                adjdata = regexp(adjdata, sprintf('\\w{1,%d}', 2), 'match'); %split single string 
                % adjdata= fliplr(adjdata); %revert sequence
                % adjdata= strjoin(fliplr(adjdata)); % combine string array
                adjdata=strrep(strjoin(fliplr(adjdata)),' ',''); %delete unnecessary space
                DataDec{i,j}= hex2num(adjdata);% convert from hex format to dec fprmat
                if isnan(DataDec{i,j})==1
                    DataDec{i,j}=blanks(2);
                end 
            end 
        end
    end
    Cellcombo=vertcat(Header,DataDec);
    filename=['US_HF_Datagroup.xlsx'];
    xlswrite(filename,Cellcombo,['Datagroup_',num2str(nn)],'A1');
end

disp('All Funds excel finished')