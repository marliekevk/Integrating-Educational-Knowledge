#--------------------------------------------------------------------
#Header part
#--------------------------------------------------------------------

response_matching = simple_matching;
scenario= "math";
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
		caption = "Je zult nu een kort rekentaakje doen
Je moet steeds terugtellen van een bepaald getal
met een bepaalde stap.
Bijvoorbeeld terugtellen van 10 met stap 2, maar dan wat moeilijker.
Na 10 seconden wordt je gevraagd waar je bent gekomen met terugtellen.
Tik je antwoord in en druk op enter,
je zal dan de volgende taak te zien krijgen.

Succes!"; } txt1;

	text {
		caption = "Einde van deze taak!";
	} txt2;
	
} txt_array;

# Instruction trial
trial {
	trial_duration = forever;
	trial_type = correct_response;
		picture {
			text {
				caption = " ";
			};
		x = 0; y = 0;
		} txt;
	target_button = 4;
} txt_trial;	

# Math trial
trial {
	trial_duration = 10000;
	trial_type = fixed;
	stimulus_event {
			picture {
				text { caption = " "; font_size = 30; } instruction; x = 0; y = 200;
				text { caption = " "; font_size = 30; } answer; x = 0; y = 0;
			} math_pic; 
		response_active = true;
	} ;
} math_trial;

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

array <string> counts[6] = {"Tel terug van 89 met 6","Tel terug van 67 met 4","Tel terug van 95 met 7","Tel terug van 71 met 3","Tel terug van 58 met 5","Tel terug van 43 met 8"};
string input = "";
stimulus_data last_response;

# logfile
output_file ofile1 = new output_file;
preset string Subject;		
ofile1.open_append (Subject +  "_math.txt");
ofile1.print(Subject + "\n");
ofile1.print(date_time() + "\n\n");
ofile1.print("Trial\tAnswer\tRT\n\n");
txt.set_part(1,txt1);
txt_trial.present();

# begin counting
loop int i=1 until i>6 begin;
	instruction.set_caption(counts[i]);
	instruction.set_font_color(0,0,0);
	instruction.redraw();
	answer.set_caption(" ");
	answer.redraw();
	math_trial.set_duration(10000);
	math_trial.present();
	instruction.set_caption("Antwoord?");
	instruction.set_font_color(255,0,0);
	instruction.redraw();
	input = system_keyboard.get_input(math_pic,answer);
	answer.set_caption(input);
	math_trial.set_duration(500);
	math_trial.present();
	
	# log response
	last_response = stimulus_manager.last_stimulus_data();
	ofile1.print(string(i) + "\t" + input + "\t" + string(last_response.reaction_time()) + "\n");

	i = i+1;
end;

txt.set_part(1,txt2);
txt_trial.present();

ofile1.print("\nEnd of experiment at " + date_time());