#--------------------------------------------------------------------
#Header part
#--------------------------------------------------------------------

response_matching = simple_matching;
scenario= "recall";
no_logfile = false;
           
#Response buttons
active_buttons = 7; # use 1 response button
button_codes = 1,2,3,4,5,6,7;	# which are defined in the "settings">"response">"decives">"active buttons"
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

Druk op enter voor de oefensessie"; } txt1;

	text {
		caption = "Dit was de oefensessie.

Als je nog vragen hebt kan je die nu stellen.

Druk op enter om met het experiment te beginnen"; } txt2;
	
	text {
		caption = "Einde van dit experiment!";
	} txt3;
	
} txt_array;

# Instruction trial
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 7;
		picture {
			text {
				caption = " ";
			};
		x = 0; y = 0;
		} txt;
} txt_trial;	

# Recognition trial
trial {
	trial_duration = 4000;
	trial_type = first_response;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 30; } desc1; x = 0; y = 100;
				bitmap { filename = "conf_lr.bmp"; } pic; x = 0; y = -100; 
				text { caption = "Ja                                         Nee"; font_size = 30; } yesno; x = 0; y = -200;
			}; 
		response_active = true;
	} rec_event;
} rec_trial;

# Picture generation trial
trial {
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 1;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 30;} desc2; x = 0; y = 200;
				text { caption = " "; font_size = 30;} answer; x = 0; y = 0;
			} text_pic; 
		response_active = true;
	} picgen_event;
} picgen_trial;

# Picture recognition trial
trial {
	trial_duration = 3000;
	trial_type = first_response;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 30;} desc3; x = 0; y = 200;
				bitmap { filename = "default.jpg"; } pic1; x = -200; y = 0; 
				bitmap { filename = "default.jpg"; } pic2; x = 200; y = 0; 
				bitmap { filename = "conf_lr.bmp"; } pic3; x = 0; y = -300; 
			}; 
		response_active = true;
	} picrec_event;
} picrec_trial;

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
int counter_lures = 1;
int i;
int j;
int total = 128;
string input = "";
int reaction_time = 0;
int button = 0;
int rand_pos = 0;
int remaining_time = 0;
string pic_name = "";
string full_String = "";
string new_filename = "";
array <string> sub_String[3];
array <string> BC_rec_prac[2][5] = {{"Persoonlijke innerlijke ervaring","Structureel model van de psyche","Academische discipline","Vervormd beeld van lichaam","Geleidelijke verandering"},{"practice1.jpg","practice4.jpg","practice2.jpg", "practice5.jpg","practice3.jpg"}};
array <string> lures_prac[3] = {"practice3.jpg","practice1.jpg","practice2.jpg"};
array <string> BC_rec_stimuli[total][4];
array <string> lure_pics[total/2];
array <string> lure_pics2[total/2];
input_file BC_rec_stims = new input_file;
stimulus_data last_response;

# logfiles, lures, and association txt-files
preset string Subject;									# ask for subject name/code to put in logfile
output_file ofile1 = new output_file; 				# text file with specifics about encoding
ofile1.open_append (Subject +  "_recall.txt");# name of logfile
ofile1.print(Subject + "\n");
ofile1.print(date_time() + "\n\n");

# load stimulus set
BC_rec_stims.open("subject_files/" + Subject + "_rec.txt");

loop until
   BC_rec_stims.end_of_file()
begin
	counter = counter + 1;
	full_String = BC_rec_stims.get_line();
	full_String.split("\t",sub_String);	
   BC_rec_stimuli[counter][1] = sub_String[1]; # description
   BC_rec_stimuli[counter][2] = sub_String[2]; # picture
   BC_rec_stimuli[counter][3] = sub_String[3]; # congruency condition
	if sub_String[2] != "N/A" then
		lure_pics[counter_lures] = sub_String[2];
		counter_lures = counter_lures + 1;
	end;
end;  

# randomize lure_pics such that positions never overlap
int diff = 0;
counter = 0;
lure_pics2 = lure_pics;
lure_pics2.shuffle();

loop until diff == total/2 begin 
	counter = counter + 1;
	if lure_pics2[counter] != lure_pics[counter] then # if not the same, heighten diff
		diff = diff + 1;
	end;
	
	if counter == total/2 && diff != total/2 then # in this case there is one or more overlapping
		lure_pics2.shuffle();
		counter = 0;
		diff = 0;
	end;	
end;	

lure_pics = lure_pics2;

# present instructions
txt.set_part(1,txt1);
txt_trial.present();

##################
# Practice trial #
##################

counter_lures = 1; 

loop i = 1 until i > 5	begin
	# recognition trial
	rec_trial.set_duration(4000);
	rec_trial.set_type(first_response);
	remaining_time = 0;
	desc1.set_caption(BC_rec_prac[1][i]);
	desc1.redraw();
	pic.set_filename("conf_lr.bmp");
	pic.load();
	rec_trial.present();
	
	# log button press + reaction time
	last_response = stimulus_manager.last_stimulus_data();
	remaining_time = 4000 - last_response.reaction_time();
	rec_trial.set_duration(remaining_time);
	rec_trial.set_type(fixed);

	# rewrite screen after button press
	if last_response.button() < 7 && last_response.button() > 0 then
		new_filename = "conf" + string(last_response.button()) + "_lr.bmp";
		pic.set_filename(new_filename);
		pic.load();
		rec_trial.present();
	elseif last_response.button() == 7 then
		rec_trial.set_duration(remaining_time);
		rec_trial.present();	
	end;
	
	# only proceed if description was old and correctly answered, otherwise go to next stimulus
	if i == 1 || i == 3 || i == 5 && last_response.button() < 4 && last_response.button() > 0 then
		
		# picture generation
		answer.set_font_color(0,0,0);
		desc2.set_caption(BC_rec_prac[1][i] + "\n\n\n\nPlaatje: ");
		desc2.redraw();
		input = system_keyboard.get_input(text_pic,answer);
		answer.set_caption(input);
		answer.set_caption("Handen terug op 1-6, druk op 1");
		answer.set_font_color(255,0,0);
		answer.redraw();
		system_keyboard.clear_keypresses(); 
		picgen_trial.present();
				
		# picture recognition	
		picrec_trial.set_duration(3000);
		picrec_trial.set_type(first_response);
		desc3.set_caption(BC_rec_prac[1][i]);
		desc3.redraw();
		pic3.set_filename("conf_lr.bmp");
		pic3.load();
		rand_pos = random(1,2);
		if rand_pos == 1 then
			pic1.set_filename("pictures/practice/" + BC_rec_prac[2][i]);
			pic2.set_filename("pictures/practice/" + lures_prac[counter_lures]);
		else
			pic2.set_filename("pictures/practice/" + BC_rec_prac[2][i]);
			pic1.set_filename("pictures/practice/" + lures_prac[counter_lures]);
		end;	
		pic1.load();
		pic2.load();
			
		picrec_trial.present();	
		
		# rewrite screen after button press
		last_response = stimulus_manager.last_stimulus_data();
		remaining_time = 3000 - last_response.reaction_time();
		picrec_trial.set_duration(remaining_time);
		picrec_trial.set_type(fixed);
		if last_response.button() < 7 && last_response.button() > 0 then
			new_filename = "conf" + string(last_response.button()) + "_lr.bmp";
			pic3.set_filename(new_filename);
			pic3.load();
			picrec_trial.present();
		elseif last_response.button() == 7 then
			picrec_trial.set_duration(remaining_time);
			picrec_trial.present();	
		end;
	else	
		# add two extra seconds wait time
		wait_trial.present();
		wait_trial.present();
	end;
	
	# heighten counter_lures
	if i == 1 || i == 3 || i == 5 then
		counter_lures = counter_lures + 1;
	end;
		
	wait_trial.present();
	i = i + 1;
end;

# End of practice session, final time to ask questions
txt.set_part(1,txt2);
txt_trial.present();

##################
# Recall session #
##################

ofile1.print("Description\tCongruency\tRecognition\tConfidence\tRT\tPicture description\tRT\tPicture recognition\tConfidence\tRT\n");
counter_lures = 1; 

loop i = 1 until i > total	begin
	# recognition trial
	rec_trial.set_duration(4000);
	rec_trial.set_type(first_response);
	remaining_time = 0;
	desc1.set_caption(BC_rec_stimuli[i][1]);
	desc1.redraw();
	pic.set_filename("conf_lr.bmp");
	pic.load();
	rec_trial.present();
	
	# log button press + reaction time
	last_response = stimulus_manager.last_stimulus_data();
	remaining_time = 4000 - last_response.reaction_time();
	ofile1.print(BC_rec_stimuli[i][1] + "\t" + BC_rec_stimuli[i][3] + "\t");
	if BC_rec_stimuli[i][2] != "N/A" then # stimulus
		if last_response.button() < 4 && last_response.button() > 0 then # hit
			ofile1.print("Hit\t");
		elseif last_response.button() > 3 && last_response.button() < 7 then # miss
			ofile1.print("Miss\t");
		else
			ofile1.print("No response\t");
		end;
	else # lure
		if last_response.button() < 4 && last_response.button() > 0 then # FA
			ofile1.print("FA\t");
		elseif last_response.button() > 3 && last_response.button() < 7 then # CR
			ofile1.print("CR\t");	
		else
			ofile1.print("No response\t")	
		end;	
	end;
	ofile1.print(string(last_response.button()) + "\t" + string(last_response.reaction_time()) + "\t");
	
	rec_trial.set_duration(remaining_time);
	rec_trial.set_type(fixed);
	# rewrite screen after button press
	if last_response.button() < 7 && last_response.button() > 0 then
		new_filename = "conf" + string(last_response.button()) + "_lr.bmp";
		pic.set_filename(new_filename);
		pic.load();
		rec_trial.present();
	elseif last_response.button() == 7 then
		rec_trial.set_duration(remaining_time);
		rec_trial.present();	
	end;
	
	# only proceed if description was old and correctly answered, otherwise go to next stimulus
	if BC_rec_stimuli[i][2] != "N/A" && last_response.button() < 4 && last_response.button() > 0 then
		
		# picture generation
		answer.set_font_color(0,0,0);
		desc2.set_caption(BC_rec_stimuli[i][1] + "\n\n\n\nPlaatje: ");
		desc2.redraw();
		input = system_keyboard.get_input(text_pic,answer);
		answer.set_caption(input);
		answer.set_caption("Handen terug op 1-6, druk op 1");
		answer.set_font_color(255,0,0);
		answer.redraw();
		system_keyboard.clear_keypresses(); 
		picgen_trial.present();
		
		# log button press + reaction time
		last_response = stimulus_manager.last_stimulus_data();
		ofile1.print(input + "\t" + string(last_response.reaction_time()) + "\t");
				
		# picture recognition	
		picrec_trial.set_duration(3000);
		picrec_trial.set_type(first_response);
		desc3.set_caption(BC_rec_stimuli[i][1]);
		desc3.redraw();
		pic3.set_filename("conf_lr.bmp");
		pic3.load();
		rand_pos = random(1,2);
		if rand_pos == 1 then
			pic1.set_filename("pictures/adapted/" + BC_rec_stimuli[i][2]);
			pic2.set_filename("pictures/adapted/" + lure_pics[counter_lures]);
		else
			pic2.set_filename("pictures/adapted/" + BC_rec_stimuli[i][2]);
			pic1.set_filename("pictures/adapted/" + lure_pics[counter_lures]);
		end;	

		pic1.load();
		pic2.load();
			
		picrec_trial.present();	
		
		# log button press + reaction time
		last_response = stimulus_manager.last_stimulus_data();
		if rand_pos == 1 then
			if last_response.button() < 4 && last_response.button() > 0 then # hit
				ofile1.print("Hit\t");
			elseif last_response.button() > 3 && last_response.button() < 7 then # miss
				ofile1.print("Miss\t");
			else
				ofile1.print("No response\t");
			end;
		elseif rand_pos == 2 then
			if last_response.button() < 4 && last_response.button() > 0 then # FA
				ofile1.print("Miss\t");
			elseif last_response.button() > 3 && last_response.button() < 7 then # CR
				ofile1.print("Hit\t");
			else
				ofile1.print("No response\t");
			end;
		end;	
		ofile1.print(string(last_response.button()) + "\t" + string(last_response.reaction_time()) + "\n");	
		
		# rewrite screen after button press
		remaining_time = 3000 - last_response.reaction_time();
		picrec_trial.set_duration(remaining_time);
		picrec_trial.set_type(fixed);
		if last_response.button() < 7 && last_response.button() > 0 then
			new_filename = "conf" + string(last_response.button()) + "_lr.bmp";
			pic3.set_filename(new_filename);
			pic3.load();
			picrec_trial.present();
		elseif last_response.button() == 7 then
			picrec_trial.set_duration(remaining_time);
			picrec_trial.present();	
		end;
	else
		ofile1.print("\n");
		# add two extra seconds wait time
		wait_trial.present();
		wait_trial.present();
	end;
		
	# heighten counter_lures
	if BC_rec_stimuli[i][2] != "N/A" then
		counter_lures = counter_lures + 1;
	end;	
		
	wait_trial.present();
	i = i + 1;
end;
	
# End experiment
txt.set_part(1,txt3);
txt_trial.present();

ofile1.print("Counter_lures = " + string(counter_lures) + "\n");
ofile1.print("\nEnd of experiment at " + date_time());