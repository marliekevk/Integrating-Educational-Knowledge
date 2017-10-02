% Randomization of Educational schema inference - MvK 2016

for s=27:30
    clearvars -except s;
    
    %% Setup stage
    
    % set parameters
    total = 80;
    order = [ones(1,total/4),2*ones(1,total/4),3*ones(1,total/4),4*ones(1,total/4)];
    order_rand = order(randperm(length(order)));

    % read in stimuli
    stimuli = readtable('stims/ass.xlsx');
    stimuli(:,4) = num2cell(order_rand'); % add order_rand as fourth column
    stimuli = sortrows(stimuli,4); % sort according to order_rand
    con_stims1 = [stimuli(1:total/4,1),stimuli(1:total/4,2),array2table(ones(1,total/4)')]; % congruent, first description
    inc_stims1 = [stimuli(total/4+1:total/2,1),stimuli(total/4+1:total/2,2),array2table(2*ones(1,total/4)')]; % incongruent, first description
    con_stims2 = [stimuli(total/2+1:total/4*3,1),stimuli(total/2+1:total/4*3,3),array2table(3*ones(1,total/4)')]; % congruent, second description
    inc_stims2 = [stimuli(total/4*3+1:total,1),stimuli(total/4*3+1:total,3),array2table(4*ones(1,total/4)')]; % incongruent, second description
    lures = [table2cell(stimuli(1:total/4,3));table2cell(stimuli(total/4+1:total/2,3));...
        table2cell(stimuli(total/2+1:total/4*3,2));table2cell(stimuli(total/4*3+1:total,2))];
    
    % randomize again for final order within categories
    con_stims1 = con_stims1(randperm(total/4),:);
    inc_stims1 = inc_stims1(randperm(total/4),:);
    con_stims2 = con_stims2(randperm(total/4),:);
    inc_stims2 = inc_stims2(randperm(total/4),:);
    lures = lures(randperm(total));
    
    % determine picture names (word without spaces and capital letters)
    for i = 1:total/4
        word = {''};
        % con_stims1
        word = table2cell(con_stims1(i,1));
        word = sprintf('%s%s',cell2mat(lower(strrep(word,' ',''))),'.jpg');
        con_stims1_words(i) = {word};
              
        % inc_stims1
        word = table2cell(inc_stims1(i,1));
        word = sprintf('%s%s',cell2mat(lower(strrep(word,' ',''))),'2.jpg');
        inc_stims1_words(i) = {word};
        
        % con_stims2
        word = table2cell(con_stims2(i,1));
        word = sprintf('%s%s',cell2mat(lower(strrep(word,' ',''))),'2.jpg');
        con_stims2_words(i) = {word};
        
        % inc_stims2
        word = table2cell(inc_stims2(i,1));
        word = sprintf('%s%s',cell2mat(lower(strrep(word,' ',''))),'.jpg');
        inc_stims2_words(i) = {word};    
    end
    
    % add column with words to tables
    con_stims1(:,4) = cell2table(con_stims1_words');
    inc_stims1(:,4) = cell2table(inc_stims1_words');
    con_stims2(:,4) = cell2table(con_stims2_words');
    inc_stims2(:,4) = cell2table(inc_stims2_words');
    
    %% Executive phase
    
    % make blocks  
    cntr = 0;
    for i = 1:10 % 10 blocks, every block gets 8 items, 2 per condition
        
        % read in stimuli
        stims = [table2cell(con_stims1(i*2-1,:));table2cell(con_stims1(i*2,:));...
            table2cell(con_stims2(i*2-1,:));table2cell(con_stims2(i*2,:));...
            table2cell(inc_stims1(i*2-1,:));table2cell(inc_stims1(i*2,:));...
            table2cell(inc_stims2(i*2-1,:));table2cell(inc_stims2(i*2,:))];    
        
        % pseudorandomize order such that no more than three con or three inc
        % follow each other       
        ok = zeros(1,6); % for encoding
        
        while find(ok == 0)
            ok = zeros(1,6);
            random = randperm(8);            
            for j=1:6
                if random(j) < 5 && random(j+1) < 5 && random(j+2) < 5
                    ok(j) = 0;
                elseif random(j) > 4 && random(j+1) > 4 && random(j+2) > 4
                    ok(j) = 0;
                else
                    ok(j) = 1;
                end
            end
        end
               
        ok = zeros(1,6); % for retrieval
        
        while find(ok == 0)
            ok = zeros(1,6);
            random2 = randperm(8);            
            for j=1:6
                if random2(j) < 5 && random2(j+1) < 5 && random2(j+2) < 5
                    ok(j) = 0;
                elseif random2(j) > 4 && random2(j+1) > 4 && random2(j+2) > 4
                    ok(j) = 0;
                else
                    ok(j) = 1;
                end
            end
        end        
        
        % set condition counters for timing conditions
        cntr_con1 = 1;
        cntr_inc1 = 1;
        cntr_con2 = 1;
        cntr_inc2 = 1;
        timing_con1 = randperm(2);
        timing_inc1 = randperm(2);
        timing_con2 = randperm(2);
        timing_inc2 = randperm(2);
        
        % fill arrays
        for j=1:8
            %encoding
            stims_enc{j+cntr,1} = stims(random(j),1); % word
            stims_enc{j+cntr,2} = stims(random(j),2); % description
            stims_enc(j+cntr,3) = stims(random(j),3); % congruency condition
            stims_enc{j+cntr,4} = stims(random(j),4); % figure name
            % timing conditions for AC encoding
            if stims{random(j),3} == 1
                stims_enc{j+cntr,5} = timing_con1(cntr_con1);
                cntr_con1 = cntr_con1 + 1;
            elseif stims{random(j),3} == 2
                stims_enc{j+cntr,5} = timing_inc1(cntr_inc1); 
                cntr_inc1 = cntr_inc1 + 1;
            elseif stims{random(j),3} == 3
                stims_enc{j+cntr,5} = timing_con2(cntr_con2);
                cntr_con2 = cntr_con2 + 1;
            elseif stims{random(j),3} == 4
                stims_enc{j+cntr,5} = timing_inc2(cntr_inc2);
                cntr_inc2 = cntr_inc2 + 1;
            end
            
            %retrieval
            stims_ret{j+cntr,1} = stims(random2(j),1); % word
            stims_ret{j+cntr,2} = stims(random2(j),2); % description
            stims_ret(j+cntr,3) = stims(random2(j),3); % congruency condition
            stims_ret{j+cntr,4} = stims(random2(j),4); % figure name
        end
        
        % heighten cntr
        cntr = cntr+8;
    end
    
    % final recall
    ok = 0;
    
    while ok == 0
        ok = 1;
        stims_recall = randperm(total);

        for i=1:total-3
            if stims_recall(i) > total/2 && stims_recall(i+1) > total/2 && stims_recall(i+2) > total/2 % three inc in a row
                nr = 3;
                while nr ~= 0 
                    if stims_recall(i+nr) < total/2+1
                        temp = stims_recall(i+2);
                        stims_recall(i+2) = stims_recall(i+nr);
                        stims_recall(i+nr) = temp;
                        nr = 0;
                    else
                        if i<total-3
                            nr = nr + 1;
                            if i + nr > total 
                                ok = 0;
                                break;
                            end
                        end
                    end
                end 
            elseif stims_recall(i) < 41 && stims_recall(i+1) < 41 && stims_recall(i+2) < 41 % three con in a row
                nr = 3;
                while nr ~= 0 
                    if stims_recall(i+nr) > total/2+1
                        temp = stims_recall(i+2);
                        stims_recall(i+2) = stims_recall(i+nr);
                        stims_recall(i+nr) = temp;
                        nr = 0;
                    else
                        nr = nr + 1;
                        if i + nr > total 
                            ok = 0;
                            break;
                        end
                    end
                end 
            end
        end   
    end
    
    % intersperse lures pseudorandomly
    order_lures = randperm(total);
    stim_or_lure = [ones(1,total),ones(1,total)*2];
    order_all = randperm(total*2);
    
    for i=1:total*2-3               
        if stim_or_lure(order_all(i)) == 2 && stim_or_lure(order_all(i+1)) == 2 && stim_or_lure(order_all(i+2)) == 2 % three lures in a row
            nr = 3;
            while nr ~= 0 
                if stim_or_lure(order_all(i+nr)) == 1
                    temp = stim_or_lure(order_all(i+2));
                    stim_or_lure(order_all(i+2)) = stim_or_lure(order_all(i+nr));
                    stim_or_lure(order_all(i+nr)) = temp;
                    nr = 0;
                else
                    nr = nr + 1;
                    if i + nr > total*2 
                        ok = 0;
                        break;
                    end
                end
            end 
        end
    end
    
    % recall array
    cntr_stim = 1;
    cntr_lures = 1;
        
    for i=1:total*2
        % fill array
        if stim_or_lure(order_all(i)) == 1 % stimulus
            if stimuli{stims_recall(cntr_stim),4} == 1 % con1
                stims_rec{i,1} = stimuli{stims_recall(cntr_stim),2}; % description
                stims_rec{i,2} = table2cell(con_stims1((find(strcmp(table2cell(con_stims1(:,2)),cell2mat(stims_rec{i,1})))),4)); % picture name
            elseif stimuli{stims_recall(cntr_stim),4} == 2 % inc1
                stims_rec{i,1} = stimuli{stims_recall(cntr_stim),2};
                stims_rec{i,2} = table2cell(inc_stims1((find(strcmp(table2cell(inc_stims1(:,2)),cell2mat(stims_rec{i,1})))),4));
            elseif stimuli{stims_recall(cntr_stim),4} == 3 % con2                
                stims_rec{i,1} = stimuli{stims_recall(cntr_stim),3};
                stims_rec{i,2} = table2cell(con_stims2((find(strcmp(table2cell(con_stims2(:,2)),cell2mat(stims_rec{i,1})))),4));
            elseif stimuli{stims_recall(cntr_stim),4} == 4 % inc2
                stims_rec{i,1} = stimuli{stims_recall(cntr_stim),3};
                stims_rec{i,2} = table2cell(inc_stims2((find(strcmp(table2cell(inc_stims2(:,2)),cell2mat(stims_rec{i,1})))),4));
            end
            
            % add conditions
            stims_rec{i,3} = stimuli{stims_recall(cntr_stim),4}; % congruency
            stims_rec{i,4} = cell2mat(stims_enc(find(strcmp([stims_enc{:,4}],stims_rec{i,2})),5)); % timing
            cntr_stim = cntr_stim+1;            
            
        else % lure
            stims_rec{i,1} = lures(order_lures(cntr_lures));
            stims_rec{i,2} = {'N/A'};
            stims_rec{i,3} = 0;
            stims_rec{i,4} = 0;
            cntr_lures = cntr_lures+1;
        end
    end    
           
    % write away text files
    fid_enc = fopen(fullfile('subject_files',sprintf('s%i_enc.txt',s)),'w');
    for row=1:total
        fprintf(fid_enc, '%s\t%s\t%i\t%s\t%i\n', cell2mat(stims_enc{row,1}),cell2mat(stims_enc{row,2}),stims_enc{row,3},cell2mat(stims_enc{row,4}),stims_enc{row,5});      
    end 
    
    fid_ret = fopen(fullfile('subject_files',sprintf('s%i_ret.txt',s)),'w');
    for row=1:total
        fprintf(fid_ret, '%s\t%s\t%i\t%s\n', cell2mat(stims_ret{row,1}),cell2mat(stims_ret{row,2}),stims_ret{row,3},cell2mat(stims_ret{row,4}));      
    end
    
    fid_rec = fopen(fullfile('subject_files',sprintf('s%i_rec.txt',s)),'w');
    for row=1:total*2
        fprintf(fid_rec, '%s\t%s\t%i\t%i\n', cell2mat(stims_rec{row,1}),cell2mat(stims_rec{row,2}),stims_rec{row,3},stims_rec{row,4});      
    end  
        
    fclose(fid_enc);
    fclose(fid_ret);
    fclose(fid_rec);
end
    