% Analyze.m, analyzes associative memory from Education Inference experiment
% MvK 2017
 
% per subject
subjects = [2,3,4,5,6,7,10,11,12,13,14,15,17,18,19,20,23,26,27,30,31];

for s=1:length(subjects) 
    
    if subjects(s) ~= 23
        % read in congruent excelfile: I use readtable here caue matlab
        % doesn't like to read in so much data at once somehow
        con_data = readtable(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_con.xlsx',subjects(s))),'Sheet','congruent');
        inc_data = readtable(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_con.xlsx',subjects(s))),'Sheet','incongruent');

        con_data = [con_data;inc_data]; % merge files to form one big table

        % read in timing excelfile
        timing1_data_all = readtable(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_timing.xlsx',subjects(s))),'Sheet','congruent');
        timing2_data_all = readtable(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_timing.xlsx',subjects(s))),'Sheet','incongruent');

        % add performance ratings to timing tables
        for i=1:height(timing1_data_all)
            timing1_data_all{i,5} = con_data{find(strcmp(con_data{:,1},timing1_data_all{i,1})),5};
        end

        for i=1:height(timing2_data_all)
            timing2_data_all{i,5} = con_data{find(strcmp(con_data{:,1},timing2_data_all{i,1})),5};
        end

        av1 = mean(timing1_data_all{:,5});
        av2 = mean(timing2_data_all{:,5});

        % calculate results with curiosity as independent measure
        timing1_data = sortrows(timing1_data_all,3);
        timing2_data = sortrows(timing2_data_all,3);
        % delete rows where curiosity is zero
        timing1_data(find(timing1_data{:,3}==0),:) = []; 
        timing2_data(find(timing2_data{:,3}==0),:) = [];

        cur1_2 = mean(timing1_data{find(timing1_data{:,3}==2),5});
        cur1_2_tr = length(find(timing1_data{:,3}==2));
        cur1_3 = mean(timing1_data{find(timing1_data{:,3}==3),5});
        cur1_3_tr = length(find(timing1_data{:,3}==3));
        cur2_2 = mean(timing2_data{find(timing2_data{:,3}==2),5});
        cur2_2_tr = length(find(timing2_data{:,3}==2));
        cur2_3 = mean(timing2_data{find(timing2_data{:,3}==3),5});
        cur2_3_tr = length(find(timing2_data{:,3}==3));

        % calculate results with reactivation as independent measure
        timing1_data = sortrows(timing1_data_all,4);
        timing2_data = sortrows(timing2_data_all,4);
        % delete rows where reactivation is zero
        timing1_data(find(timing1_data{:,4}==0),:) = []; 
        timing2_data(find(timing2_data{:,4}==0),:) = [];

        reac1_1 = mean(timing1_data{find(timing1_data{:,4}==1),5});
        reac1_1_tr = length(find(timing1_data{:,4}==1));
        reac1_2 = mean(timing1_data{find(timing1_data{:,4}==2),5});
        reac1_2_tr = length(find(timing1_data{:,4}==2));
        reac1_3 = mean(timing1_data{find(timing1_data{:,4}==3),5});
        reac1_3_tr = length(find(timing1_data{:,4}==3));
        reac2_1 = mean(timing2_data{find(timing2_data{:,4}==1),5});
        reac2_1_tr = length(find(timing2_data{:,4}==1));
        reac2_2 = mean(timing2_data{find(timing2_data{:,4}==2),5});
        reac2_2_tr = length(find(timing2_data{:,4}==2));
        reac2_3 = mean(timing2_data{find(timing2_data{:,4}==3),5});
        reac2_3_tr = length(find(timing2_data{:,4}==3));

    elseif subjects(s) == 23 % read in directly as this subject was not in the congruency set
        % read in excelfile
        timing1_data_all = xlsread(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_timing.xlsx',subjects(s))),1,'C:E');   
        timing2_data_all = xlsread(fullfile('..','logfiles',sprintf('s%i',subjects(s)),sprintf('pic_desc_s%i_timing.xlsx',subjects(s))),2,'C:E'); 

        av1 = mean(timing1_data_all(:,3));
        av2 = mean(timing2_data_all(:,3));

        % calculate results with curiosity as independent measure
        timing1_data = sortrows(timing1_data_all,3);
        timing2_data = sortrows(timing2_data_all,3);
        % delete rows where curiosity is zero
        timing1_data(find(timing1_data(:,3)==0),:) = []; 
        timing2_data(find(timing2_data(:,3)==0),:) = [];

        cur1_2 = mean(timing1_data(find(timing1_data(:,1)==2),3));
        cur1_2_tr = length(find(timing1_data(:,1)==2));
        cur1_3 = mean(timing1_data(find(timing1_data(:,1)==3),3));
        cur1_3_tr = length(find(timing1_data(:,1)==3));
        cur2_2 = mean(timing2_data(find(timing2_data(:,1)==2),3));
        cur2_2_tr = length(find(timing2_data(:,1)==2));
        cur2_3 = mean(timing2_data(find(timing2_data(:,1)==3),3));
        cur2_3_tr = length(find(timing2_data(:,1)==3));

        % calculate results with reactivation as independent measure
        timing1_data = sortrows(timing1_data_all,2);
        timing2_data = sortrows(timing2_data_all,2);
        % delete rows where reactivation is zero
        timing1_data(find(timing1_data(:,2)==0),:) = []; 
        timing2_data(find(timing2_data(:,2)==0),:) = [];

        reac1_1 = mean(timing1_data(find(timing1_data(:,2)==1),3));
        reac1_1_tr = length(find(timing1_data(:,2)==1));
        reac1_2 = mean(timing1_data(find(timing1_data(:,2)==2),3));
        reac1_2_tr = length(find(timing1_data(:,2)==2));
        reac1_3 = mean(timing1_data(find(timing1_data(:,2)==3),3));
        reac1_3_tr = length(find(timing1_data(:,2)==3));
        reac2_1 = mean(timing2_data(find(timing2_data(:,2)==1),3));
        reac2_1_tr = length(find(timing2_data(:,2)==1));
        reac2_2 = mean(timing2_data(find(timing2_data(:,2)==2),3));
        reac2_2_tr = length(find(timing2_data(:,2)==2));
        reac2_3 = mean(timing2_data(find(timing2_data(:,2)==3),3));
        reac2_3_tr = length(find(timing2_data(:,2)==3));
    end
    
    outcomes(s,:) = [av1,cur1_2,cur1_3,reac1_1,reac1_2,reac1_3,cur1_2_tr,cur1_3_tr,reac1_1_tr,reac1_2_tr,reac1_3_tr, ...
        av2,cur2_2,cur2_3,reac2_1,reac2_2,reac2_3,cur2_2_tr,cur2_3_tr,reac2_1_tr,reac2_2_tr,reac2_3_tr];
    outcomes(isnan(outcomes)) = -1; % does not solve the problem but at least makes it easier to find the NaNs in other programs
    
    % close and clear
    close all;
    clearvars -except subjects outcomes;
end

col_header={'av1','cur1_2','cur1_3','reac1_1','reac1_2','reac1_3','av2','cur2_2','cur2_3','reac2_1','reac2_2','reac2_3'};
xlswrite('outcomes_ass_timing.xlsx',col_header,1,'A1');
xlswrite('outcomes_ass_timing.xlsx',outcomes,1,'A2');
