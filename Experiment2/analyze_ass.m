% Analyze.m, analyzes associative memory from Education Inference experiment
% MvK 2017
 
% per subject
subjects = [1,2,3,4,7,8,9,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27,28];

for s=1:length(subjects)
    disp(sprintf('Running subject %i',subjects(s)));
    % read in excelfile
    con_data_all = xlsread(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_withmetamemory.xlsx',subjects(s))),1,'C:E'); % read in encoding logfile   
    inc_data_all = xlsread(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_withmetamemory.xlsx',subjects(s))),2,'C:E'); % read in encoding logfile 
    
    con_av = mean(con_data_all(:,3));
    inc_av = mean(inc_data_all(:,3));
    
%     % calculate results with memory as independent measure
%     con_cur_hits = mean(nonzeros(con_data(find(con_data(:,3)>0),1)));
%     con_cur_miss = mean(nonzeros(con_data(find(con_data(:,3)==0),1)));
%     inc_cur_hits = mean(nonzeros(inc_data(find(inc_data(:,3)>0),1)));
%     inc_cur_miss = mean(nonzeros(inc_data(find(inc_data(:,3)==0),1)));
%     
%     con_reac_hits = mean(nonzeros(con_data(find(con_data(:,3)>0),2)));
%     con_reac_miss = mean(nonzeros(con_data(find(con_data(:,3)==0),2)));
%     inc_reac_hits = mean(nonzeros(inc_data(find(inc_data(:,3)>0),2)));
%     inc_reac_miss = mean(nonzeros(inc_data(find(inc_data(:,3)==0),2)));
    
    % calculate results with metamemory as independent measure
    con_data = sortrows(con_data_all,1);
    inc_data = sortrows(inc_data_all,1);
    % delete rows where metamemory is zero
    con_data(find(con_data(:,1)==0),:) = []; 
    inc_data(find(inc_data(:,1)==0),:) = [];
        
    con_cur2 = mean(con_data(find(con_data(:,1)==2),3));
    con_cur2_tr = length(con_data(find(con_data(:,1)==2)));
    con_cur3 = mean(con_data(find(con_data(:,1)==3),3));
    con_cur3_tr = length(con_data(find(con_data(:,1)==3)));
    inc_cur2 = mean(inc_data(find(inc_data(:,1)==2),3));
    inc_cur2_tr = length(con_data(find(inc_data(:,1)==2)));
    inc_cur3 = mean(inc_data(find(inc_data(:,1)==3),3));
    inc_cur3_tr = length(con_data(find(inc_data(:,1)==3)));

    % calculate results with reactivation as independent measure
    con_data = sortrows(con_data_all,2);
    inc_data = sortrows(inc_data_all,2);
    % delete rows where reactivation is zero
    con_data(find(con_data(:,2)==0),:) = []; 
    inc_data(find(inc_data(:,2)==0),:) = [];
        
    con_reac1 = mean(con_data(find(con_data(:,2)==1),3));
    con_reac1_tr = length(con_data(find(con_data(:,2)==1)));
    con_reac2 = mean(con_data(find(con_data(:,2)==2),3));
    con_reac2_tr = length(con_data(find(con_data(:,2)==2)));    
    con_reac3 = mean(con_data(find(con_data(:,2)==3),3));
    con_reac3_tr = length(con_data(find(con_data(:,2)==3)));    
    inc_reac1 = mean(inc_data(find(inc_data(:,2)==1),3));
    inc_reac1_tr = length(inc_data(find(inc_data(:,2)==1)));    
    inc_reac2 = mean(inc_data(find(inc_data(:,2)==2),3));
    inc_reac2_tr = length(inc_data(find(inc_data(:,2)==2)));        
    inc_reac3 = mean(inc_data(find(inc_data(:,2)==3),3));
    inc_reac3_tr = length(inc_data(find(inc_data(:,2)==3)));        
      
    outcomes(s,:) = [con_av, con_cur2, con_cur3, con_reac1, con_reac2, con_reac3, con_cur2_tr, con_cur3_tr, con_reac1_tr, con_reac2_tr, con_reac3_tr, ...
        inc_av, inc_cur2, inc_cur3, inc_reac1, inc_reac2, inc_reac3, inc_cur2_tr, inc_cur3_tr, inc_reac1_tr, inc_reac2_tr, inc_reac3_tr];
    outcomes(isnan(outcomes)) = -1; % does not solve the problem but at least makes it easier to find the NaNs in other programs
    
    clearvars -except subjects outcomes
end

col_header={'con_av', 'con_cur2', 'con_cur3', 'con_reac1', 'con_reac2', 'con_reac3', 'con_cur2_tr', 'con_cur3_tr', 'con_reac1_tr', 'con_reac2_tr', 'con_reac3_tr', ...
    'inc_av', 'inc_cur2', 'inc_cur3', 'inc_reac1', 'inc_reac2', 'inc_reac3', 'inc_cur2_tr', 'inc_cur3_tr', 'inc_reac1_tr', 'inc_reac2_tr', 'inc_reac3_tr'};
xlswrite('outcomes_ass.xlsx',col_header,1,'A1');
xlswrite('outcomes_ass.xlsx',outcomes,1,'A2');
