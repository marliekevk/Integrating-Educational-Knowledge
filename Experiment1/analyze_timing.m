% Analyze.m, analyzes logfiles from Education Inference experiment
% MvK 2016

subject_amount = 30;
ass_excel = 0;

% read in associations
[~,~,associations] = xlsread(fullfile('..','stims','ass.xlsx'),1,'A2:C81');
 
% per subject
for s=2:31 % there's no data for participant 1
    
    % preset variables
    desc_not_learned = {};
    old_responses = zeros(1,6);
    new_responses = zeros(1,6);
    pic_desc1 = {};
    pic_desc2 = {};
    FA1 = 0;
    FA2 = 0;
    CR1 = 0;
    CR2 = 0;  
    
    %% Encoding
    
   % read in ACencoding logfile, this is for AC learning
    fid = fopen(fullfile('..','logfiles',sprintf('s%i',s),sprintf('s%i_ACencoding.txt',s))); % read in encoding logfile    
    
    % read out first four lines (participant name & table headers)
    for i=0:3
        tline = fgetl(fid); 
    end

    % read in rest
    for i = 1:80
        tline = fgetl(fid); % read out 1 line
        if tline == -1 % end of file
            break;
        end
        
        % read in variables
        Line = textscan(tline,'%s','delimiter','\t');
        encoding(i).word = Line{1}{1};
        encoding(i).curiosity = str2num(Line{1}{2});
        encoding(i).curiosity_RT = str2num(Line{1}{3});
        encoding(i).reactivation = str2num(Line{1}{4});  
        encoding(i).reactivation_RT = str2num(Line{1}{5});     
        encoding(i).timing = str2num(Line{1}{7});
    end % for
    
    % determine known words per participant
    known_words = [encoding(find([encoding.curiosity]==1)),encoding(find([encoding.curiosity]==0))];
    for j=1:length(known_words)
        % store descriptions related to known words in array
        known_desc(j,:) = [associations(find(strcmp({known_words(j).word},associations(:,1))),2),associations(find(strcmp({known_words(j).word},associations(:,1))),3)];
    end
    
    % check whether words are not learned during encoding (only for some pp's who had a technical failure)
    cntr = 1;
    if length(encoding) < 80
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
    for i = 1:160
        tline = fgetl(fid); % read out 1 line
        if tline == -1 % end of file
            break;
        end
        
        Line = textscan(tline,'%s','delimiter','\t');
        description = Line{1}{1};
        recall(cntr).description = description;
        recall(cntr).congruency = str2num(Line{1}{2});        
        recall(cntr).timing = str2num(Line{1}{3});
     
        % determine how Line needs to be read
        if recall(cntr).timing > 0 % old description
            if find(strcmp(description,known_desc(:))) % word is known, skip
            elseif find(strcmp(description,desc_not_learned(:))) % word is not learned, skip
            else
                % read in other variables
                recall(cntr).rec = Line{1}{4};
                recall(cntr).rec_conf = str2num(Line{1}{5});
                recall(cntr).rec_RT = str2num(Line{1}{6});
                
                if strcmp(recall(cntr).rec,'Hit') % Hit
                    recall(cntr).pic_desc = Line{1}{7};                   
                    recall(cntr).picrec = Line{1}{9};
                    recall(cntr).picrec_conf = str2num(Line{1}{10});
                    recall(cntr).picrec_RT = str2num(Line{1}{11});
                end
                    
                % determine reactivation and curiosity index (AC learning) and add to recall
                % find associated word from associations list
                ind = find(strcmp(recall(cntr).description,associations)==1); 
                if ind > 160
                    word = associations(ind-160,1);
                elseif ind <= 160
                    word = associations(ind-80,1);
                end

                % find reactivation and curiosity for this word in encoding struct
                recall(cntr).curiosity = encoding(find(strcmp(word,{encoding.word}))).curiosity; 
                recall(cntr).reactivation = encoding(find(strcmp(word,{encoding.word}))).reactivation;
                
                % heighten cntr
                cntr = cntr+1;
            end
        elseif recall(cntr).timing == 0 % lure 
            if find(strcmp(description,desc_not_learned(:))) > 0 % word is not learned, skip
            else
                recall(cntr).rec = Line{1}{4};
                
                % find associated word from associations list
                ind = find(strcmp(recall(cntr).description,associations)==1); 
                if ind > 160
                    word = associations(ind-160,1);
                elseif ind <= 160
                    word = associations(ind-80,1);
                end

                % find congruency value from encoding struct and increase counters
                if encoding(find(strcmp(word,{encoding.word}))).timing == 1 % timing 1
                    if strcmp(recall(cntr).rec,'FA')
                        FA1 = FA1 + 1;
                    elseif strcmp(recall(cntr).rec,'CR')
                        CR1 = CR1 + 1;
                    end
                elseif encoding(find(strcmp(word,{encoding.word}))).timing == 2 % timing 2
                    if strcmp(recall(cntr).rec,'FA')
                        FA2 = FA2 + 1;
                    elseif strcmp(recall(cntr).rec,'CR')
                        CR2 = CR2 + 1;
                    end
                end
            end

            % heighten cntr
            cntr = cntr+1;
        end
    end 
   
    %% Calculate outcomes
    
    % order array to specify per congruency condition
    [~,index] = sort([recall.timing]);
    sorted_recall = recall(index); % sort according to congruency
    order1 = find([sorted_recall.timing]==1);
    recall1 = sorted_recall(order1);
    order2 = find([sorted_recall.timing]==2);
    recall2 = sorted_recall(order2);
    FA1 = FA1/(FA1 + CR1);
    FA2 = FA2/(FA2 + CR2);
    
    % Calculate performance: congruent
    
    % recognition performance
    hits1= length(find(strcmp({recall1.rec}, 'Hit')==1));
    misses1 = length(find(strcmp({recall1.rec}, 'Miss')==1));
    rec1 = hits1/(hits1+misses1);
    if FA1 > 0
        dprime1 = norminv(rec1)-norminv(FA1);
    else
        dprime1 = norminv(rec1)-norminv(0.5/40);
    end

    % determine curiosity and reactivation effects on memory
    order = find([recall1.curiosity] == 2);
    new_struct = recall1(order);
    cur1_2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    cur1_2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall1.curiosity] == 3);
    new_struct = recall1(order);
    cur1_3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    cur1_3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall1.reactivation] == 1);
    new_struct = recall1(order);
    reac1_1 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    reac1_1_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall1.reactivation] == 2);
    new_struct = recall1(order);
    reac1_2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    reac1_2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall1.reactivation] == 3);
    new_struct = recall1(order);
    reac1_3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));     
    reac1_3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    
    % calculate confidence and RT
    order = find(strcmp({recall1.rec}, 'Hit')==1);
    new_struct = recall1(order); % structure array with only hits, so disregard "no responses" and misses
    conf1 = mean([new_struct.rec_conf]);
    RT1 = mean([new_struct.rec_RT]);
    
    % generate list for picture descriptions    
    for i=1:length(new_struct)
        pic_desc1{i,2} = new_struct(i).pic_desc;
        if new_struct(i).congruency == 1
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,2)))),1));
            pic_desc1{i,1} = sprintf('%s%i',pic_name,1);
        elseif new_struct(i).congruency == 2
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,2)))),1));
            pic_desc1{i,1} = sprintf('%s%i',pic_name,2);    
        elseif new_struct(i).congruency == 3
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,3)))),1));
            pic_desc1{i,1} = sprintf('%s%i',pic_name,2);      
        elseif new_struct(i).congruency == 4
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,3)))),1));
            pic_desc1{i,1} = sprintf('%s%i',pic_name,1);   
        end
        pic_desc1{i,3} = new_struct(i).curiosity;
        pic_desc1{i,4} = new_struct(i).reactivation;
    end
      
    % sort these lists
    if ~isempty(pic_desc1)
        pic_desc1 = sortrows(pic_desc1,1);
    end

    % picture recognition
    pichits1 = length(find(strcmp({recall1.picrec}, 'Hit')==1));
    picmisses1 = length(find(strcmp({recall1.picrec}, 'Miss')==1));
    picrec1 = pichits1/(pichits1+picmisses1);
    order = find(strcmp({recall1.picrec}, 'Hit')==1);
    new_struct = recall1(order);
    picconf1 = mean([new_struct.picrec_conf]);
    picRT1 = mean([new_struct.picrec_RT]); 
    
    % Calculate performance: Incongruent
    
    % recognition performance
    hits2 = length(find(strcmp({recall2.rec}, 'Hit')==1));
    misses2 = length(find(strcmp({recall2.rec}, 'Miss')==1));
    rec2 = hits2/(hits2+misses2);
    if FA2 > 0
        dprime2 = norminv(rec2)-norminv(FA2);
    else
        dprime2 = norminv(rec2)-norminv(0.5/40);
    end
    
    % determine curiosity and reactivation effects on memory
    order = find([recall2.curiosity] == 2);
    new_struct = recall2(order);
    cur2_2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    cur2_2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall2.curiosity] == 3);
    new_struct = recall2(order);
    cur2_3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    cur2_3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall2.reactivation] == 1);
    new_struct = recall2(order);
    reac2_1 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    reac2_1_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall2.reactivation] == 2);
    new_struct = recall2(order);
    reac2_2 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));
    reac2_2_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    order = find([recall2.reactivation] == 3);
    new_struct = recall2(order);
    reac2_3 = length(find(strcmp({new_struct.rec}, 'Hit')==1))/(length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1)));     
	reac2_3_tr = length(find(strcmp({new_struct.rec}, 'Hit')==1))+ length(find(strcmp({new_struct.rec}, 'Miss')==1));
    
    % calculate confidence and RT
    order = find(strcmp({recall2.rec}, 'Hit')==1);
    new_struct = recall2(order); % structure array with only hits, so disregard "no responses" and misses
    conf2 = mean([new_struct.rec_conf]);
    RT2 = mean([new_struct.rec_RT]);
    
    % generate list for picture descriptions    
    for i=1:length(new_struct)
        pic_desc2{i,2} = new_struct(i).pic_desc;
        if new_struct(i).congruency == 1
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,2)))),1));
            pic_desc2{i,1} = sprintf('%s%i',pic_name,1);
        elseif new_struct(i).congruency == 2
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,2)))),1));
            pic_desc2{i,1} = sprintf('%s%i',pic_name,2);    
        elseif new_struct(i).congruency == 3
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,3)))),1));
            pic_desc2{i,1} = sprintf('%s%i',pic_name,2);      
        elseif new_struct(i).congruency == 4
            pic_name = char(associations((find(strcmp({new_struct(i).description},associations(:,3)))),1));
            pic_desc2{i,1} = sprintf('%s%i',pic_name,1);   
        end
        pic_desc2{i,3} = new_struct(i).curiosity;
        pic_desc2{i,4} = new_struct(i).reactivation;
    end
    
    % sort these lists
    if ~isempty(pic_desc2)
        pic_desc2 = sortrows(pic_desc2,1);
    end
    
    % picture recognition
    pichits2 = length(find(strcmp({recall2.picrec}, 'Hit')==1));
    picmisses2 = length(find(strcmp({recall2.picrec}, 'Miss')==1));
    picrec2 = pichits2/(pichits2+picmisses2);
    order = find(strcmp({recall2.picrec}, 'Hit')==1);
    new_struct = recall2(order);
    picconf2 = mean([new_struct.picrec_conf]);
    picRT2 = mean([new_struct.picrec_RT]); 
    
    % put responses in matrix
    if hits1 > 9 && hits2 > 9
        outcomes(s,:) = [s, hits1, rec1, dprime1, FA1, conf1, RT1, cur1_2, cur1_3, reac1_1, reac1_2, reac1_3, cur1_2_tr, cur1_3_tr, reac1_1_tr, reac1_2_tr, reac1_3_tr, picrec1, picconf1, picRT1, ...
            hits2, rec2, dprime2, FA2, conf2, RT2, cur2_2, cur2_3, reac2_1, reac2_2, reac2_3, cur2_2_tr, cur2_3_tr, reac2_1_tr, reac2_2_tr, reac2_3_tr, picrec2, picconf2, picRT2];
        
        % write descriptions
        if ass_excel == 1
            destination = fullfile('C:','Users','mkn556','Dropbox','Research','Running Projects','Education inference','Experiment1','logfiles',sprintf('s%i',s));
            filename = fullfile(destination,sprintf('pic_desc_s%i_timing.xlsx',s));
            col_header={'Filename','Description','Curiosity','Reactivation','Correct?'}; 
            if length(pic_desc1) > 0
                xlswrite(filename,pic_desc1,1,'A2');
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

            if length(pic_desc2) > 0
                xlswrite(filename,pic_desc2,2,'A2');
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
        end
    end
         
    % clear subject-specific variables
    clearvars -except subject_amount outcomes associations ass_excel;
end % for

% % delete empty rows
outcomes(all(outcomes == 0, 2), :) = [];
outcomes(isnan(outcomes)) = -1; % does not solve the problem but at least makes it easier to find the NaNs in other programs
% % write to xls
col_header={'s_nr','hits1','rec1','dprime1','fa1','conf1','RT1','cur1_2','cur1_3','reac1_1','reac1_2','reac1_3','cur1_2_tr','cur1_3_tr','reac1_1_tr','reac1_2_tr','reac1_3_tr','picrec1','picconf1','picRT1', ...
    'hits2','rec2','dprime2','fa2','conf2','RT2','cur2_2','cur2_3','reac2_1','reac2_2','reac2_3','cur2_2_tr','cur2_3_tr','reac2_1_tr','reac2_2_tr','reac2_3_tr','picrec2','picconf2','picRT2'};
xlswrite('outcomes_timing.xlsx',col_header,1,'A1');
xlswrite('outcomes_timing.xlsx',outcomes,1,'A2');