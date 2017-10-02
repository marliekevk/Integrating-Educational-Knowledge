% Analyze.m, analyzes logfiles from Education Inference experiment
% MvK 2016

subject_amount = 30;
ass_excel = 0;
temp = 1;

% read in associations
[~,~,associations] = xlsread(fullfile('..','stims','ass.xlsx'),1,'A2:C65');
 
% per subject
for s=1:30
    if s~= 5 % there's no data for s5
    
        % preset variables
        con_ABret = [];
        inc_ABret = [];
        con_ABret_RT = [];
        inc_ABret_RT = [];
        desc_not_learned = {};
        old_responses = zeros(1,6);
        new_responses = zeros(1,6);
        pic_desc_con = {};
        pic_desc_inc = {};
        con_FA = 0;
        inc_FA = 0;
        CR_con = 0;
        CR_inc = 0;  

        %% Encoding

        % read in ABencoding logfile: this is for the AB retrieval test
        fid = fopen(fullfile('..','logfiles',sprintf('s%i',s),sprintf('s%i_ABencoding.txt',s))); % read in encoding logfile    

        % read out first four lines (participant name & table headers)
        for i=0:3
            tline = fgetl(fid); 
        end

        % read in rest, determine ABretrieval 
        for i = 1:64
            tline = fgetl(fid); % read out 1 line
            if tline == -1 % end of file
                break;
            end

            % read in variables
            Line = textscan(tline,'%s','delimiter','\t');
            if Line{1}{4} == '1' || Line{1}{4} == '3' % congruent
                if strcmp(Line{1}{2},'Correct')
                    con_ABret = [con_ABret 1];
                elseif strcmp(Line{1}{2},'Incorrect')
                    con_ABret = [con_ABret 0];
                end
                con_ABret_RT = [con_ABret_RT str2num(Line{1}{3})];
            elseif Line{1}{4} == '2' || Line{1}{4} == '4' % incongruent
                if strcmp(Line{1}{2},'Correct')
                    inc_ABret = [inc_ABret 1];
                elseif strcmp(Line{1}{2},'Incorrect')
                    inc_ABret = [inc_ABret 0];
                end
                inc_ABret_RT = [inc_ABret_RT str2num(Line{1}{3})];
            end     
        end % for

        % calculate mean ABret performance and RTs
        con_ABret = mean(con_ABret);
        inc_ABret = mean(inc_ABret);  
        con_ABret_RT = mean(con_ABret_RT);
        inc_ABret_RT = mean(inc_ABret_RT);    

        % read in ACencoding logfile, this is for AC learning
        fid = fopen(fullfile('..','logfiles',sprintf('s%i',s),sprintf('s%i_ACencoding.txt',s))); % read in encoding logfile    

        % read out first four lines (participant name & table headers)
        for i=0:3
            tline = fgetl(fid); 
        end

        % read in rest
        for i = 1:64
            tline = fgetl(fid); % read out 1 line
            if tline == -1 % end of file
                break;
            end

            % read in variables
            Line = textscan(tline,'%s','delimiter','\t');
            encoding(i).word = Line{1}{1};
            encoding(i).metamemory = str2num(Line{1}{2});
            encoding(i).metamemory_RT = str2num(Line{1}{3});
            encoding(i).reactivation = str2num(Line{1}{4});  
            encoding(i).reactivation_RT = str2num(Line{1}{5});
            encoding(i).congruency = str2num(Line{1}{6});
        end % for

        % determine known words per participant and words that have not
        % been responded to
        known_words = [encoding(find([encoding.metamemory]==1)),encoding(find([encoding.metamemory]==0))];
        for j=1:length(known_words)
            % store descriptions related to known words in array
            known_desc(j,:) = [associations(find(strcmp({known_words(j).word},associations(:,1))),2),associations(find(strcmp({known_words(j).word},associations(:,1))),3)];
        end

        % check whether words are not learned during encoding (only for some pp's who had a technical failure)
        cntr = 1;
        if length(encoding) < 64
            for j=1:length(encoding)
                if sum(strcmp(associations(j),{encoding.word}))==0 % word is not learned during encoding
                    desc_not_learned(cntr,1) = associations(j,2);
                    desc_not_learned(cntr,2) = associations(j,3);
                    cntr=cntr+1;
                end
            end
        end

        %% Recall

        % read in recall logfile
        fid = fopen(fullfile('..','logfiles',sprintf('s%i',s),sprintf('s%i_recall.txt',s))); % read in recall logfile    

        % read out first four lines (participant name & table headers)
        for i=0:3
            tline = fgetl(fid); 
        end    

        % read in rest
        cntr = 1; % use counter such that only trials that are learned and trials with unkown words are taken along
        length_rec = 128;
        for i = 1:length_rec
            tline = fgetl(fid); % read out 1 line
            if tline == -1 % end of file
                break;
            end

            Line = textscan(tline,'%s','delimiter','\t');
            description = Line{1}{1};
            recall(cntr).description = description;
            recall(cntr).congruency = str2num(Line{1}{2});

            % determine how Line needs to be read
            if recall(cntr).congruency > 0 % old description
                if find(strcmp(description,known_desc(:))) % word is known, skip
                elseif find(strcmp(description,desc_not_learned(:))) % word is not learned, skip
                else
                    % read in other variables
                    recall(cntr).rec = Line{1}{3};
                    recall(cntr).rec_conf = str2num(Line{1}{4});
                    recall(cntr).rec_RT = str2num(Line{1}{5});

                    if strcmp(recall(cntr).rec,'Hit') % Hit
                        recall(cntr).pic_desc = Line{1}{6};                   
                        recall(cntr).picrec = Line{1}{8};
                        recall(cntr).picrec_conf = str2num(Line{1}{9});
                        recall(cntr).picrec_RT = str2num(Line{1}{10});
                    end

                    % determine reactivation and metamemory index (AC learning) and add to recall
                    % find associated word from associations list
                    ind = find(strcmp(recall(cntr).description,associations)==1); 
                    if ind > length_rec
                        word = associations(ind-length_rec,1);
                    elseif ind <= length_rec
                        word = associations(ind-length_rec/2,1);
                    end

                    % find reactivation and metamemory for this word in encoding struct
                    recall(cntr).metamemory = encoding(find(strcmp(word,{encoding.word}))).metamemory; 
                    recall(cntr).reactivation = encoding(find(strcmp(word,{encoding.word}))).reactivation;

                    % heighten cntr
                    cntr = cntr+1;
                end
            elseif recall(cntr).congruency == 0 % lure 
                if find(strcmp(description,desc_not_learned(:))) > 0 % word is not learned, skip
                else
                    recall(cntr).rec = Line{1}{3};

                    % find associated word from associations list
                    ind = find(strcmp(recall(cntr).description,associations)==1); 
                    if ind > length_rec
                        word = associations(ind-length_rec,1);
                    elseif ind <= length_rec
                        word = associations(ind-length_rec/2,1);
                    end

                    % find congruency value from encoding struct and increase counters
                    if encoding(find(strcmp(word,{encoding.word}))).congruency == 1 || encoding(find(strcmp(word,{encoding.word}))).congruency == 3 %congruent
                         if strcmp(recall(cntr).rec,'FA')
                                con_FA = con_FA + 1;
                         elseif strcmp(recall(cntr).rec,'CR')
                                CR_con = CR_con + 1;
                         end
                    elseif encoding(find(strcmp(word,{encoding.word}))).congruency == 2 || encoding(find(strcmp(word,{encoding.word}))).congruency == 4 %incongruent
                       if strcmp(recall(cntr).rec,'FA')
                            inc_FA = inc_FA + 1;
                       elseif strcmp(recall(cntr).rec,'CR')
                            CR_inc = CR_inc + 1;
                       end
                    end
                end

                % heighten cntr
                cntr = cntr+1;
            end
        end 

        %% Calculate outcomes

        % order array to specify per congruency condition
        [~,index] = sort([recall.congruency]);
        sorted_recall = recall(index); % sort according to congruency
        order_con = [find([sorted_recall.congruency]==1),find([sorted_recall.congruency]==3)];
        con_recall = sorted_recall(order_con);
        order_inc = [find([sorted_recall.congruency]==2),find([sorted_recall.congruency]==4)];
        inc_recall = sorted_recall(order_inc);
        con_FA = con_FA/(con_FA + CR_con);
        inc_FA = inc_FA/(inc_FA + CR_inc);

        % Calculate performance: congruent

        % recognition performance
        con_hits= length(find(strcmp({con_recall.rec}, 'Hit')==1));
        con_misses = length(find(strcmp({con_recall.rec}, 'Miss')==1));
        con_rec = con_hits/(con_hits+con_misses);
        if con_FA > 0
            con_dprime = norminv(con_rec)-norminv(con_FA);
        else
            con_dprime = norminv(con_rec)-norminv(0.5/32);
        end
        
        % determine metamemory and reactivation effects on memory
        order = find([con_recall.metamemory] == 2);
        new_struct = con_recall(order);
        con_met2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        con_met2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([con_recall.metamemory] == 3);
        new_struct = con_recall(order);
        con_met3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        con_met3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([con_recall.reactivation] == 1);
        new_struct = con_recall(order);
        con_reac1 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        con_reac1_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([con_recall.reactivation] == 2);
        new_struct = con_recall(order);
        con_reac2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        con_reac2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([con_recall.reactivation] == 3);
        new_struct = con_recall(order);
        con_reac3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));     
        con_reac3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        
        % calculate confidence and RT
        order = find(strcmp({con_recall.rec}, 'Hit')==1);
        new_struct = con_recall(order); % structure array with only hits, so disregard "no responses" and misses
        con_conf = mean([new_struct.rec_conf]);
        con_RT = mean([new_struct.rec_RT]);

        % generate list for picture descriptions    
        for i=1:length(new_struct)
            pic_desc_con{i,2} = new_struct(i).pic_desc;
            if new_struct(i).congruency == 1
                pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,2)))),1));
                pic_desc_con{i,1} = sprintf('%s%i',pic_name,1);
                pic_desc_con{i,3} = new_struct(i).metamemory;
                pic_desc_con{i,4} = new_struct(i).reactivation;
            elseif new_struct(i).congruency == 3
                pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,3)))),1));
                pic_desc_con{i,1} = sprintf('%s%i',pic_name,2);
                pic_desc_con{i,3} = new_struct(i).metamemory;
                pic_desc_con{i,4} = new_struct(i).reactivation;
            end
        end

        % sort these lists
        if ~isempty(pic_desc_con)
            pic_desc_con = sortrows(pic_desc_con,1);
        end

        % picture recognition
        con_pichits = length(find(strcmp({con_recall.picrec}, 'Hit')==1));
        con_picmisses = length(find(strcmp({con_recall.picrec}, 'Miss')==1));
        con_picrec = con_pichits/(con_pichits+con_picmisses);
        order = find(strcmp({con_recall.picrec}, 'Hit')==1);
        new_struct = con_recall(order);
        con_picconf = mean([new_struct.picrec_conf]);
        con_picRT = mean([new_struct.picrec_RT]); 

        % Calculate performance: Incongruent

        % recognition performance
        inc_hits = length(find(strcmp({inc_recall.rec}, 'Hit')==1));
        inc_misses = length(find(strcmp({inc_recall.rec}, 'Miss')==1));
        inc_rec = inc_hits/(inc_hits+inc_misses);
        if inc_FA > 0
            inc_dprime = norminv(inc_rec)-norminv(inc_FA);
        else
            inc_dprime = norminv(inc_rec)-norminv(0.5/32);
        end
        
        % determine metamemory and reactivation effects on memory
        order = find([inc_recall.metamemory] == 2);
        new_struct = inc_recall(order);
        inc_met2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        inc_met2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([inc_recall.metamemory] == 3);
        new_struct = inc_recall(order);
        inc_met3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        inc_met3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([inc_recall.reactivation] == 1);
        new_struct = inc_recall(order);
        inc_reac1 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        inc_reac1_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([inc_recall.reactivation] == 2);
        new_struct = inc_recall(order);
        inc_reac2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
        inc_reac2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
        order = find([inc_recall.reactivation] == 3);
        new_struct = inc_recall(order);
        inc_reac3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));     
        inc_reac3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));

        % calculate confidence and RT
        order = find(strcmp({inc_recall.rec}, 'Hit')==1);
        new_struct = inc_recall(order); % structure array with only hits, so disregard "no responses" and misses
        inc_conf = mean([new_struct.rec_conf]);
        inc_RT = mean([new_struct.rec_RT]);

        % generate list for picture descriptions    
        for i=1:length(new_struct)
            pic_desc_inc{i,2} = new_struct(i).pic_desc;
            if new_struct(i).congruency == 2
                pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,2)))),1));
                pic_desc_inc{i,1} = sprintf('%s%i',pic_name,2);
                pic_desc_inc{i,3} = new_struct(i).metamemory;
                pic_desc_inc{i,4} = new_struct(i).reactivation;
            elseif new_struct(i).congruency == 4
                pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,3)))),1));
                pic_desc_inc{i,1} = sprintf('%s%i',pic_name,1);
                pic_desc_inc{i,3} = new_struct(i).metamemory;
                pic_desc_inc{i,4} = new_struct(i).reactivation;
            end
        end

        % sort these lists
        if ~isempty(pic_desc_inc)
            pic_desc_inc = sortrows(pic_desc_inc,1);
        end

        % picture recognition
        inc_pichits = length(find(strcmp({inc_recall.picrec}, 'Hit')==1));
        inc_picmisses = length(find(strcmp({inc_recall.picrec}, 'Miss')==1));
        inc_picrec = inc_pichits/(inc_pichits+inc_picmisses);
        order = find(strcmp({inc_recall.picrec}, 'Hit')==1);
        new_struct = inc_recall(order);
        inc_picconf = mean([new_struct.picrec_conf]);
        inc_picRT = mean([new_struct.picrec_RT]); 

        % put responses in matrix
        if con_hits > 9 && inc_hits > 9
        outcomes(s,:) = [s, con_ABret,con_ABret_RT, inc_ABret, inc_ABret_RT, ...
            con_hits, con_rec, con_dprime, con_FA, con_conf, con_RT, con_met2, con_met3, con_reac1, con_reac2, con_reac3, con_met2_tr, con_met3_tr, con_reac1_tr, con_reac2_tr, con_reac3_tr,con_picrec, con_picconf, con_picRT, ...
            inc_hits, inc_rec, inc_dprime, inc_FA, inc_conf, inc_RT, inc_met2, inc_met3, inc_reac1, inc_reac2, inc_reac3, inc_met2_tr, inc_met3_tr, inc_reac1_tr, inc_reac2_tr, inc_reac3_tr ,inc_picrec, inc_picconf, inc_picRT];

            % write descriptions
            % temporary
            if temp == 1
                destination = fullfile('C:','Users','mkn556','Dropbox','Research','Running Projects','Education inference','Experiment2','logfiles',sprintf('s%i',s));
                filename = fullfile(destination,sprintf('pic_desc_s%i.xlsx',s));
                xlsdata_con = xlsread(filename,1,'D1:D32'); 
                xlsdata_inc = xlsread(filename,2,'D1:D32'); 
                col_header={'Filename','Description','Metamemory','Reactivation','Correct?'}; 
                filename = fullfile(destination,sprintf('pic_desc_s%i_withmetamemory.xlsx',s));
                xlswrite(filename,pic_desc_con,1,'A2');
                xlswrite(filename,xlsdata_con,1,'E2');
                xlswrite(filename,col_header,1,'A1');                
                xlswrite(filename,pic_desc_inc,2,'A2');
                xlswrite(filename,xlsdata_inc,2,'E2');
                xlswrite(filename,col_header,2,'A1');
            end
                
            if ass_excel == 1
                destination = fullfile('C:','Users','mkn556','Dropbox','Research','Running Projects','Education inference','Experiment2','logfiles',sprintf('s%i',s));
                filename = fullfile(destination,sprintf('pic_desc_s%i_con_M.xlsx',s));
                col_header={'Filename','Description','Metamemory','Reactivation','Correct?'}; 
                if length(pic_desc_con) > 0
                    xlswrite(filename,pic_desc_con,1','A2');
                    xlswrite(filename,col_header,1,'A1');
                end

                % customize Excel file
                hExcel = actxserver('Excel.Application');
                hWorkbook = hExcel.Workbooks.Open(filename);
                hWorkbook.Worksheets.Item(1).Name = 'congruent';
                hExcel.Cells.Select;
                hExcel.Cells.EntireColumn.AutoFit;
                hWorkbook.Save;
                hWorkbook.Close;
                hExcel.Quit;

                if length(pic_desc_inc) > 0
                    xlswrite(filename,pic_desc_inc,2,'A2');
                    xlswrite(filename,col_header,2,'A1');
                end

                % customize Excel file
                hExcel = actxserver('Excel.Application');
                hWorkbook = hExcel.Workbooks.Open(filename);
                hWorkbook.Worksheets.Item(2).Name = 'incongruent';
                hExcel.Cells.Select;
                hExcel.Cells.EntireColumn.AutoFit;
                hWorkbook.Save;
                hWorkbook.Close;
                hExcel.Quit;

                % copy file so we can get two ratings
                filename2 = fullfile(destination,sprintf('pic_desc_s%i_con_L.xlsx',s));
                copyfile(filename,filename2);
            end
        end

        % clear subject-specific variables
        clearvars -except subject_amount outcomes associations ass_excel temp;
    end
end % for

% delete empty rows and remove NaNs
outcomes(all(outcomes == 0, 2), :) = [];
outcomes(isnan(outcomes)) = -1; % does not solve the problem but at least makes it easier to find the NaNs in other programs

% write to xls
col_header={'s_nr','con_ABret','con_ABret_RT','inc_ABret','inc_ABret_RT','con_hits','con_rec','con_dprime','con_fa','con_conf','con_RT','con_cur2','con_cur3','con_reac1','con_reac2','con_reac3','con_cur2_tr','con_cur3_tr','con_reac1_tr','con_reac2_tr','con_reac3_tr','con_picrec_tr','con_picconf','con_picRT', ...
    'inc_hits','inc_rec','inc_dprime','inc_fa','inc_conf','inc_RT','inc_cur2','inc_cur3','inc_reac1','inc_reac2','inc_reac3','inc_cur2_tr','inc_cur3_tr','inc_reac1_tr','inc_reac2_tr','inc_reac3_tr','inc_picrec','inc_picconf','inc_picRT'};
xlswrite('outcomes.xlsx',col_header,1,'A1');
xlswrite('outcomes.xlsx',outcomes,1,'A2');