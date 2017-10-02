#--------------------------------------------------------------------
#Header part
#--------------------------------------------------------------------

response_matching = simple_matching;
scenario= "encoding";
no_logfile = false;
           
#Response buttons
active_buttons = 4;					#use 1 response button
button_codes = 1,2,3,4;				#which are defined in the "settings">"response">"decives">"active buttons"
response_logging = log_active;


#Other settings
default_font_size = 18;
default_font = "Arial";
default_text_color = 0,0,0;
default_background_color = 255,255,255;
screen_width = 1024;
screen_height = 768;
screen_bit_depth = 32;

#--------------------------------------------------------------------
#SDL part
#--------------------------------------------------------------------

begin;

# Text array with instructions
array {

	text {
		caption = "Welkom bij dit experiment!
		
Lees eerst de instructies op het papier.

Druk op enter om met de oefensessie te beginnen."; } txt1;

	text {
		caption = "Dit was de oefensessie.

Als je nog vragen hebt kan je die nu stellen.

Druk op enter om met het experiment te beginnen"; } txt2;
	
	text {
		caption = "Einde van deze taak!";
	} txt3;
	
} txt_array;

# Instruction trial
trial {
	trial_duration = forever;
	trial_type = specific_response;
		terminator_button = 4;
		picture {
			text {
				caption = " ";
			};
		x = 0; y = 0;
		} txt;
} txt_trial;	

# AB-learn trial (word + picture)
trial {
	trial_duration = 3000;
	trial_type = fixed;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 30; } wordAB1; x = 0; y = 200;
				bitmap { filename = "default.jpg"; } pic; x = 0; y = -50; 
			}; 
	} ABlearn_event;
} ABlearn_trial;

# AB-retrieval trial (word + 2 pictures)
trial {
	trial_duration = 3000;
	trial_type = specific_response;
	terminator_button = 1,2;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 30;} wordAB2; x = 0; y = 200;
				bitmap { filename = "default.jpg"; } pic1; x = -200; y = -50; 
				bitmap { filename = "default.jpg"; } pic2; x = 200; y = -50; 
			}; 
		response_active = true;
	} retrieval_event;
} retrieval_trial;

# AC-learn trial (word + description)
trial {
	trial_duration = 4000;
	trial_type = fixed;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 30;} wordAC; x = 0; y = 100;
				text { caption = " "; font_size = 30; font_color = 0, 0, 255;} desc; x = 0; y = -50; 
			}; 
	} AClearn_event;
} AClearn_trial;

# Question trial
trial {
	trial_duration = 4000;
	trial_type = first_response;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 24;} quest; x = 0; y = 200;
				text { caption = " "; font_size = 24;} answer; x = 0; y = 0; 
			}; 
		response_active = true;
	} quest_event;
} quest_trial;

# Cue trial
trial {
	trial_duration = 2000;
		stimulus_event {
		picture {
			text { caption = " "; font_size = 30; } cue;
			x = 0; y = 0;
		} ;
	} ;
} cue_trial;

# Wait trial
trial {
	trial_duration = 1000;
		stimulus_event {
		picture {
			text { caption = "+"; font_size = 50; } cross;
			x = 0; y = 0;
		} text_cross;
		code = "text_cross";	
	} wait_event;
} wait_trial;

#--------------------------------------------------------------------
#PCL part - Main program
#--------------------------------------------------------------------

begin_pcl;

# standard variables
int counter = 0;
int i;
int j;
int total = 80;
int reaction_time = 0;
int button = 0;
int rand_pos = 0;
string pic_name = "";
string full_String = "";
array <string> sub_String[3];
array <string> AB_enc_prac[2][3] = {{"Spiritueel","Psychologie","Ontwikkeling"},{"practice1.jpg", "practice2.jpg", "practice3.jpg"}};
array <string> AB_ret_prac[2][3] = {{"Psychologie","Ontwikkeling","Spiritueel"},{"practice2.jpg", "practice3.jpg", "practice1.jpg"}};
array <string> AC_prac[2][3] = {{"Spiritueel","Psychologie","Ontwikkeling"},{"Persoonlijke innerlijke ervaring", "Academische discipline", "Geleidelijke verandering"}};
array <string> lures_prac[3] = {"practice3.jpg","practice1.jpg","practice2.jpg"};
array <string> AB_enc_stimuli[total][3];
array <string> AB_ret_stimuli[total][3];
array <string> AC_stimuli[total][4];
input_file AB_enc_stims = new input_file;
input_file AB_ret_stims = new input_file;
stimulus_data last_response;

# logfiles, lures, and association txt-files
preset string Subject;									# ask for subject name/code to put in logfile
output_file ofile1 = new output_file; 				# text file with specifics about encoding
ofile1.open_append (Subject +  "_ABencoding.txt");# name of logfile
ofile1.print(Subject + "\n");
ofile1.print(date_time() + "\n\n");
output_file ofile2 = new output_file; 				# text file with specifics about encoding
ofile2.open_append (Subject +  "_ACencoding.txt");# name of logfile
ofile2.print(Subject + "\n");
ofile2.print(date_time() + "\n\n");

# load stimulus set
AB_enc_stims.open("subject_files/" + Subject + "_enc.txt");
AB_ret_stims.open("subject_files/" + Subject + "_ret.txt");

counter = 0;
loop until
   AB_enc_stims.end_of_file()
begin
	counter = counter + 1;
	full_String = AB_enc_stims.get_line();
	full_String.split("\t",sub_String);	
   AB_enc_stimuli[counter][1] = sub_String[1]; # word	
   AB_enc_stimuli[counter][2] = sub_String[4]; # picture
   AC_stimuli[counter][1] = sub_String[1]; # word	
   AC_stimuli[counter][2] = sub_String[2]; # description
   AC_stimuli[counter][3] = sub_String[3]; # congruency condition	
end;  

counter = 0;
loop until
   AB_ret_stims.end_of_file()
begin
	counter = counter + 1;
	full_String = AB_ret_stims.get_line();
	full_String.split("\t",sub_String);	
   AB_ret_stimuli[counter][1] = sub_String[1]; # word	
   AB_ret_stimuli[counter][2] = sub_String[4]; # picture
   AB_ret_stimuli[counter][3] = sub_String[3]; # condition
end;

# present instructions
txt.set_part(1,txt1);
txt_trial.present();

##################
# Practice trial #
##################

# briefly present cue
cue.set_caption("Leren eerste ronde");
cue.redraw();
cue_trial.present();

loop j = 1 until j > 3 begin # one block
	wordAB1.set_caption(AB_enc_prac[1][j]);
	wordAB1.redraw();
	pic.unload();		
	pic_name = "pictures/practice/" + AB_enc_prac[2][j];
	pic.set_filename(pic_name);
	pic.load();

	# present trial + fixation	
	ABlearn_trial.present();
	wait_trial.present();
	j = j + 1;
end;

# Briefly present cue
cue.set_caption("Herinneren\n\n(antwoorden met 1 en 2)");	
cue.redraw();
cue_trial.present();	

# AB-retrieval
loop j = 1 until j > 3 begin # one block		
	# AB-retrieval
	wordAB2.set_caption(AB_ret_prac[1][j]);
	wordAB2.redraw();
	
	# determine place of stimulus and lure
	rand_pos = random(1,2);
	pic1.unload();
	pic2.unload();
	
	if rand_pos == 1 then # stimulus is on left
		pic_name = "pictures/practice/" + AB_ret_prac[2][j];
		pic1.set_filename(pic_name);
		pic_name = "pictures/practice/" + lures_prac[j];
		pic2.set_filename(pic_name);
	else # stimulus is on right
		pic_name = "pictures/practice/" + lures_prac[j];
		pic1.set_filename(pic_name);
		pic_name = "pictures/practice/" + AB_ret_prac[2][j];
		pic2.set_filename(pic_name);		
	end;
	
	# load pics
	pic1.load();
	pic2.load();
		
	# present trial
	retrieval_trial.present();	
	
	# present fixation trial
	wait_trial.present();
	j = j + 1;
end;

# Briefly present cue
cue.set_caption("Leren tweede ronde\n\n(antwoorden met 1,2 en 3)");
cue.redraw();
cue_trial.present();	

# AC-learning + questions
loop j = 1 until j > 3 begin # one block
	AClearn_trial.set_duration(4000);
	wordAC.set_caption(AC_prac[1][j]);
	wordAC.redraw();
	desc.set_caption(AC_prac[2][j]);
	desc.redraw();
	AClearn_trial.present();			

	# questions
	quest.set_caption(" ");
	quest.redraw();
	answer.set_caption("1. Kende het woord al\n2. Wel onthouden\n 3. Niet onthouden");
	answer.redraw();
	quest_trial.present();
	
	wait_trial.present();
	
	quest.set_caption("Plaatje?");
	quest.redraw();
	answer.set_caption("1. Sterk\n2. Beetje\n 3. Geen");
	answer.redraw();
	quest_trial.present();
	
	wait_trial.present();
	j = j + 1;
end;

# Wait trial
wait_trial.present();

# End of practice session, final time to ask questions
txt.set_part(1,txt2);
txt_trial.present();

####################
# Encoding session #
####################

ofile1.print("Word\tResponse\tRT\tCongruency condition\n"); 
ofile2.print("Word\tCuriosity\tRT\tReactivation\tRT\tCongruency condition\n"); 

loop i = 1 until i > 8	begin # 8 blocks
	
	array <string> lure_pics[8]; # create an array for lures
	
	# Briefly present cues
	cue.set_caption("Set " + string(i));
	cue.redraw();
	cue_trial.present();	
	cue.set_caption("Leren eerste ronde");
	cue.redraw();
	cue_trial.present();
	
	# AB-learning
	loop j = 1 until j > 8 begin # one block
		wordAB1.set_caption(AB_enc_stimuli[(i-1)*8+j][1]);
		wordAB1.redraw();
		pic.unload();		
		pic_name = "pictures/adapted/" + AB_enc_stimuli[(i-1)*8+j][2];
		lure_pics[j] = AB_enc_stimuli[(i-1)*8+j][2];
		pic.set_filename(pic_name);
		pic.load();

		# present trial + fixation	
		ABlearn_trial.present();
		wait_trial.present();
		j = j + 1;
	end;
	
	# randomize lure_pics such that positions never overlap
	int diff = 0;
	counter = 0;

	loop until diff == 8 begin 
		counter = counter + 1;
		
		if lure_pics[counter] != AB_ret_stimuli[(i-1)*8+counter][2] then
			diff = diff + 1;
		end;
		
		if counter == 8 && diff != 8 then
			lure_pics.shuffle();
			counter = 0;
			diff = 0;
		end;	
	end;	
	
	# Briefly present cue
	cue.set_caption("Herinneren\n\n(antwoorden met 1 en 2)");	
	cue.redraw();
	cue_trial.present();	
	
	# AB-retrieval
	loop j = 1 until j > 8 begin # one block		
		# AB-retrieval
		wordAB2.set_caption(AB_ret_stimuli[(i-1)*8+j][1]);
		wordAB2.redraw();
		
		# determine place of stimulus and lure
		rand_pos = random(1,2);
		pic1.unload();
		pic2.unload();
		
		if rand_pos == 1 then # stimulus is on left
			pic_name = "pictures/adapted/" + AB_ret_stimuli[(i-1)*8+j][2];
			pic1.set_filename(pic_name);
			pic_name = "pictures/adapted/" + lure_pics[j];
			pic2.set_filename(pic_name);
		else # stimulus is on right
			pic_name = "pictures/adapted/" + lure_pics[j];
			pic1.set_filename(pic_name);
			pic_name = "pictures/adapted/" + AB_ret_stimuli[(i-1)*8+j][2];
			pic2.set_filename(pic_name);		
		end;
		
		# load pics
		pic1.load();
		pic2.load();
			
		# present trial
		retrieval_trial.present();	

		# log button press + reaction time
		last_response = stimulus_manager.last_stimulus_data();
		
		# print variables to own logfile
		ofile1.print(AB_ret_stimuli[(i-1)*8+j][1] + "\t"); # word		
		# determine hit or miss
		if rand_pos == last_response.button() then
			ofile1.print("Correct\t");
		elseif last_response.button() == 0 || last_response.button() > 2 then
			ofile1.print("No response\t");
		else
			ofile1.print("Incorrect\t");
		end;		
		ofile1.print(string(last_response.reaction_time()) + "\t" + AB_ret_stimuli[(i-1)*8+j][3] + "\n"); # RT + condition
		
		# present fixation trial
		wait_trial.present();
		j = j + 1;
	end;

	# Briefly present cue
	cue.set_caption("Leren tweede ronde\n\n(antwoorden met 1,2 en 3)");
	cue.redraw();
	cue_trial.present();	
	
	# AC-learning + questions
	loop j = 1 until j > 8 begin # one block
		AClearn_trial.set_duration(4000);
		wordAC.set_caption(AC_stimuli[(i-1)*8+j][1]);
		wordAC.redraw();
		desc.set_caption(AC_stimuli[(i-1)*8+j][2]);
		desc.redraw();
		AClearn_trial.present();
						
		# questions
		quest.set_caption(" ");
		quest.redraw();
		answer.set_caption("1. Kende het woord al\n2. Wel onthouden\n 3. Niet onthouden");
		answer.redraw();
		quest_trial.present();
		
		last_response = stimulus_manager.last_stimulus_data();
		ofile2.print(AC_stimuli[(i-1)*8+j][1] + "\t" + string(last_response.button()) + "\t" + string(last_response.reaction_time()) + "\t"); # word + button + RT
		
		wait_trial.present();
		
		quest.set_caption("Plaatje?");
		quest.redraw();
		answer.set_caption("1. Sterk\n2. Beetje\n 3. Geen");
		answer.redraw();
		quest_trial.present();
		
		last_response = stimulus_manager.last_stimulus_data();
		ofile2.print(string(last_response.button()) + "\t" + string(last_response.reaction_time()) + "\t" + AC_stimuli[(i-1)*8+j][3] + "\n"); # button + RT + congruency condition
		
		wait_trial.present();
		j = j + 1;
	end;
	
	# Wait trial
	wait_trial.present();

	i = i + 1;
end;

# End experiment
txt.set_part(1,txt3);
txt_trial.present();

ofile1.print("\nEnd of experiment at " + date_time());