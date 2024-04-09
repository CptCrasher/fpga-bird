module final_proj(clk,KEY[1:0],VGA_VS,VGA_HS,VGA_B[3:0],VGA_G[3:0],VGA_R[3:0],SW0,HEX0,HEX1,HEX5,HEX4,HEX3,ARDUINO[3:0],SW9);

	//Initialize inputs, outputs and regs used throughout module
	input clk,SW0,SW9;
	input [1:0] KEY;
	
	output VGA_VS,VGA_HS;
	output [7:0] HEX0,HEX1,HEX5,HEX4,HEX3;
	output [3:0] VGA_B,VGA_G,VGA_R,ARDUINO;

	reg [3:0] set_r,set_g,set_b;
	
	wire [31:0] x,y;
	wire pixel_clk,refresh_tick,clk_1s,clk_05s;
	
	reg start_state = 1; //State for when player is in title screen (starts the game)
	reg lose_state = 0; //State for when player loses the game
	reg reset_state = 0; //Used as a flag to reset regs

	reg [31:0] score = 32'd0;
	reg reset_pipes = 0;
	
	//Initialize modules used in code
	// Pll used for the VGA monitor's pixel clock (25.175 MHz)
	pll pll_inst(.inclk0(clk), .c0(pixel_clk));
	
	//VGA Controller to drive VGA
	vga_controller vga_controller_inst(pixel_clk,(~KEY[0]),h_sync,v_sync,disp_ena,x[31:0],y[31:0]);
	
	//Clock dividers used for pipe randomization
	ClockDivider_1s(clk,clk_1s);
	ClockDivider_05s(clk,clk_05s);
	
	//displayScore used to display current score onto 7 segment displays as well as the letters 'S c r' (score)
	displayScore(HEX0,HEX1,score,HEX5,HEX4,HEX3);
	
	//Handles breadboard functionalies (turning on LEDs based on state and turns on buzzer when player scores)
	breadboard_controller(clk,ARDUINO[3:0],start_state,lose_state,score,KEY[0]);
	
	assign VGA_HS = h_sync;
	assign VGA_VS = v_sync;
	
	//Everytime the frame ends, refresh tick is enabled allowing for monitor to update at 60Hz for smoothness
	assign refresh_tick = ((x == 481) && (y == 0)) ? 1 : 0; // End of vertical retrace period
	
	reg [31:0] bird_speed = 3;
	reg [31:0] pipe_speed = 2;
	
	reg [31:0] random_pipe_top [0:9];
	reg [31:0] index1 = 0;
	reg [31:0] index2 = 3;

	//Initialize starting states as well as locations pipes can randomly spawn in
	initial begin
		start_state = 1;
		lose_state = 0;
		reset_state = 0;
		
		random_pipe_top[0] = 280;
		random_pipe_top[1] = 300;
		random_pipe_top[2] = 360;
		random_pipe_top[3] = 260;	
		random_pipe_top[4] = 380;
		random_pipe_top[5] = 270;
		random_pipe_top[6] = 230;	
		random_pipe_top[7] = 190;
		random_pipe_top[8] = 170;		
	end
	
	
//Create the bird
	//Moves on the y-axis = y_bird_top is the top of the bird
	reg [31:0] y_bird_top, y_bird_next;	
	parameter x_bird_l = 90;
	parameter x_bird_r = 122; //32 pixels wide
	
	// When inbetween 33 <= x <= 65 and y_bird_top and y_bird_top + 31 pixels, draw bird on monitor
	// Bird is made up of 4 parts - its body, its eye (eye1), its pupil (eye2), and its beak. All move togther with slightly shifted x/y coordinates to generate bird image
	// Wires only are true when lose_state and start_state is absent
	wire bird_bodyOn,bird_eye1On,bird_eye2On,bird_beakOn;	

	assign bird_bodyOn = (((x >= 90 && x < 122) && (y >= y_bird_top && y < (5 + y_bird_top))) ||
								 ((x >= 90 && x < 108) && (y >= y_bird_top && y < (32 + y_bird_top))) ||
								 ((x >= 108 && x < 119) && (y >= (17 + y_bird_top) && y < (32 + y_bird_top))) ||
								 ((x >= 119 && x < 122) && (y >= y_bird_top && y < (32 + y_bird_top)))) && !lose_state && !start_state;

	assign bird_eye1On = ((x >= 112 && x < 119) && (y >= (5 + y_bird_top) && y < (13 + y_bird_top))) && !lose_state && !start_state;

	assign bird_eye2On = (((x >= 108 && x < 112) && (y >= (5 + y_bird_top) && y < (17 + y_bird_top))) ||
												((x >= 108 && x < 119) && (y >= (13 + y_bird_top) && y < (17 + y_bird_top)))) && !lose_state && !start_state;

	assign bird_beakOn = ((x >= 122 && x < 127) && (y >= (9 + y_bird_top) && y < (15 + y_bird_top))) && !lose_state && !start_state;



		
	
	

//Create the pipes
	// Wires only are true when lose_state and start_state is absent
	// Determine a gap the user can pass through, fill the upper and lower portion of this gap with a solid color to emulate a 'pipe' object
	// Will have two pipes that spawn one after another
	// Gap user can pass through is randomized using random_pipe_top[] at a random index1/index2
	// When a pipe is on the screen, move it right (subtract pipespeed from its left x boundry (x_pipe_l)). When the pipe reaches the left side of the screen,
	//   move it back to the right side of the screen so it slide across the screen again - do this for both pipes, pipes are seperated by offsetting their initial x boundry
	reg [31:0] pipe_slot_top1,pipe_slot_top2;
	wire pipe_on_1,pipe_on_2;
	
	reg [31:0] x_pipe1_l,x_pipe1_next;
	reg [31:0] x_pipe2_l,x_pipe2_next;

	reg point_added1,point_added2;
	
	
	always @(posedge pixel_clk) begin
		if(!lose_state) begin
			x_pipe1_next = x_pipe1_l;
			x_pipe2_next = x_pipe2_l;

			if(refresh_tick)begin
			//While on the screen, slide the pipe to the right (by subtracting pipe speed)
				if((x_pipe1_l + 50) >= 10)begin
					x_pipe1_next = x_pipe1_l - pipe_speed;	
					point_added1 = 0;
				end else begin
					//Add a single point when the pipe reaches the left side of the screen (use a flag to ensure only one point is added each time) 
					if(!point_added1) begin
						score <= score + 1;
						point_added1 = 1;
					end	
					//When the pipe reaches the left side of the scren (x_pipe_l >= 10), change the position the user can fly through and reset its x coordinate
					pipe_slot_top1 = random_pipe_top[index1];
					x_pipe1_next = 700;
				end
				
				if((x_pipe2_l + 50) >= 10)begin
					x_pipe2_next = x_pipe2_l - pipe_speed;
						point_added2 = 0;					
				end else begin
					if(!point_added2) begin
						score <= score + 1;
						point_added2 = 1;						
					end									
					pipe_slot_top2 = random_pipe_top[index2];
					x_pipe2_next = 700;
				end
				
				
			end
			
			//If the reset is detected, reset players score
			if(reset_state)
				score <= 0;
		end	
	end
	
	//Draw both pipes on the screen based on their x_pipe_l and pipe_slot_top boundries
	assign pipe_on_1 = ((x_pipe1_l <= x) && (x <= (x_pipe1_l + 50)) && ((1 <= y) && (y <= pipe_slot_top1) || ((pipe_slot_top1 + 110) <= y) && (y <= 479)) && !(lose_state)) && !start_state;
	assign pipe_on_2 = ((x_pipe2_l <= x) && (x <= (x_pipe2_l + 50)) && ((1 <= y) && (y <= pipe_slot_top2) || ((pipe_slot_top2 + 110) <= y) && (y <= 479))&& !(lose_state)) && !start_state;
	
	//Detect if bird (player) touches a pipe by determining if the player (bird) intersects into any of the pipe boundries
	//If it does collide, set the lose state to present
	always @(*) begin
		if(((x_pipe1_l) <= x_bird_l) && (x_bird_r <= x_pipe1_l + 50) && !(x_pipe1_l <= 10))begin
			if((!(pipe_slot_top1 <= (y_bird_top-10)) || !((y_bird_top+25) <= pipe_slot_top1 + 110))) begin
				lose_state <= 1;	
			end	
		end
		
		if(((x_pipe2_l) <= x_bird_l) && (x_bird_r <= x_pipe2_l + 50) && !(x_pipe2_l <= 10))begin
			if((!(pipe_slot_top2 <= (y_bird_top-10)) || !((y_bird_top+25) <= pipe_slot_top2 + 110))) begin
				lose_state <= 1;	
			end	
		end
		
		//If reset is detected, change the lose state back to absent
		if(reset_state)
			lose_state <= 0;
		
	end
	
	//Handle states of the game
	always @(posedge clk) begin
		//Reset regs and enter start state when reset is detected
		if(~KEY[0])begin
			//Reset the top of the bird to y = 200
			y_bird_top <= 200;
			x_pipe1_l <= 1200;
			x_pipe2_l <= 1540;
			reset_state <= 1;
			start_state <= 1;
		end else begin
			//Enter the 'in_progress' state when KEY1 is detected whilst in the lose_state/start_state - this starts the game
			if(lose_state || start_state)begin
				if(~KEY[1])begin
					start_state <= 0;
					reset_state <= 1;
					y_bird_top <= 200;
					x_pipe1_l <= 1200;
					x_pipe2_l <= 1540;
				end
			end else if(reset_pipes) begin
					x_pipe1_l <= 1200;
					x_pipe2_l <= 1540;
			end else begin
			//Update the positions of the bird and pipes continuously 
				y_bird_top <= y_bird_next;
				x_pipe1_l <= x_pipe1_next;		
				x_pipe2_l <= x_pipe2_next;
				
				//Reset reset state when its present
				if(reset_state)
					reset_state <= 0;
			end
		end	
	end
	
	//Adjust game speed based on player's score
	//pipe_speed is a delta being subtracted from the pipes
	always @(posedge pixel_clk) begin
		//Reset speed when game is reset
		if(~KEY[0]) begin
			pipe_speed <= 2;
		end else if(refresh_tick)begin
			if(score < 10) begin
				pipe_speed <= 2;		
			end else if(score >= 10 && score < 20) begin
				pipe_speed <= 3;
			end else if(score >= 20 && score < 30) begin
				pipe_speed <= 4;
			end else if(score >=30) begin
				pipe_speed <= 5;
			end
		end
	end
	
	//Handle inputs to move the bird up and down
	//Depending on the state of SW0, pressing KEY1 will cause the bird to go either up or down by adding/subracting 'bird_speed' 
	//   to its y boundry (y_bird_top). Also set up edge detection to ensure bird doesn't fly out of the screen
	always @(*) begin
		y_bird_next = y_bird_top;
		if(refresh_tick)begin
			if(SW0 & (y_bird_top > bird_speed)) begin
				if(~KEY[1] && !lose_state)
					y_bird_next = y_bird_top - bird_speed;
			 end else if(~SW0 & (y_bird_top+32) < ((479 - bird_speed))) begin
				if(~KEY[1] && !lose_state )
					y_bird_next = y_bird_top + bird_speed;
			end		
		end
	end

	//Index1 is always incrementing based on clk_1s's and also increments whenever a player presses the movement button (KEY[1]). Allows for
	//   randomness in the game
	always @(posedge clk_1s)begin
		if(index1 > 9) 
			index1 <= 0;
		else	
			index1 <= index1 + 1;
		if(!KEY[1]) begin
			if(index1 >= 8)
				index1 <= 0;
			else
				index1 <= index1 + 1;
		end
	end
	//Index2 is always incrementing based on clk_05s's and also increments whenever a player presses the movement button (KEY[1]). Allows for
	//   randomness in the game	
	always @(posedge clk_05s)begin
		if(index2 > 9) 
			index2 <= 0;
		else	
			index2 <= index2 + 1;
		if(!KEY[1]) begin
			if(index2 >= 7)
				index2 <= 0;
			else
				index2 <= index2 + 2;
		end
	end	
	
//Setting up display for start screen - wires only are true when start_state is present	
	wire display_F, display_P, display_G, display_A;

	//Displaying the letters F P G A side by side
	assign display_F = ((((x >= 250 && x < 260) && (y >= 60 && y < 220)) ||
							 ((x >= 250 && x < 280) && (y >= 60 && y < 70)) ||
							 ((x >= 250 && x < 280) && (y >= 110 && y < 120)))) && start_state;

	assign display_P = (((x >= 290 && x < 300) && (y >= 60 && y < 220)) ||
							 ((x >= 290 && x < 320) && (y >= 60 && y < 70)) ||
							 ((x >= 290 && x < 320) && (y >= 110 && y < 120)) ||
							 ((x >= 310 && x < 320) && (y >= 60 && y < 110))) && start_state;
							  
	assign display_G = (((x >= 330 && x < 340) && (y >= 60 && y < 220)) || 
							 ((x >= 340 && x < 360) && (y >= 210 && y < 220)) || 
							 ((x >= 350 && x < 360) && (y >= 160 && y < 220)) || 
							 ((x >= 345 && x < 360) && (y >= 160 && y < 170)) || 
							 ((x >= 330 && x < 360) && (y >= 60 && y < 70))) && start_state;

	assign display_A = (((x >= 370 && x < 380) && (y >= 60 && y < 220)) ||
							 ((x >= 370 && x < 400) && (y >= 60 && y < 70)) ||
							 ((x >= 390 && x < 400) && (y >= 60 && y < 220)) ||
							 ((x >= 370 && x < 400) && (y >= 160 && y < 170))) && start_state;

							 
	//Displaying the letters B I R D side by side under F P G A
	wire display_B,display_I,display_R,display_D;						 
	assign display_B = (((x >= 250 && x < 260) && (y >= 250 && y < 410)) ||
							 ((x >= 250 && x < 280) && (y >= 400 && y < 410)) ||
							 ((x >= 270 && x < 280) && (y >= 320 && y < 410)) ||
							 ((x >= 250 && x < 280) && (y >= 320 && y < 330)) ||
							 ((x >= 250 && x < 275) && (y >= 250 && y < 260)) ||
							 ((x >= 265 && x < 275) && (y >= 250 && y < 320))) && start_state;

	assign display_I = (((x >= 300 && x < 310) && (y >= 250 && y < 410)) ||
							 ((x >= 290 && x < 320) && (y >= 250 && y < 260)) ||
							 ((x >= 290 && x < 320) && (y >= 400 && y < 410))) && start_state;

	assign display_R = (((x >= 330 && x < 340) && (y >= 250 && y < 410)) ||
							 ((x >= 350 && x < 360) && (y >= 320 && y < 410)) ||
							 ((x >= 330 && x < 360) && (y >= 320 && y < 330)) ||
							 ((x >= 330 && x < 355) && (y >= 250 && y < 260)) || 
							 ((x >= 345 && x < 355) && (y >= 250 && y < 320))) && start_state;            
							  
	assign display_D = (((x >= 375 && x < 385) && (y >= 250 && y < 410)) || 
							 ((x >= 370 && x < 395) && (y >= 250 && y < 260)) || 
							 ((x >= 370 && x < 395) && (y >= 400 && y < 410)) ||
							 ((x >= 390 && x < 400) && (y >= 250 && y < 410))) && start_state;				
	
	//Display two pipes and bird parts on start screen	
	wire display_startPipe_1,display_startPipe_2;
	wire display_startBird_body,display_startBird_eye1,display_startBird_eye2,display_startBird_beak;	

	assign display_startPipe_1	= ((x >= 40 && x < 90) && (y >= 340  && y < 479)) && start_state;
	assign display_startPipe_2	= ((x >= 560 && x < 610) && (y >= 1  && y < 60)) && start_state;	
		
	assign display_startBird_body = (((x >= 90 && x < 122) && (y >= 170 && y < 175)) ||
											  ((x >= 90 && x < 108) && (y >= 170 && y < 202)) ||
											  ((x >= 108 && x < 119) && (y >= 187 && y < 202)) ||
											  ((x >= 119 && x < 122) && (y >= 170 && y < 202))) && start_state;

	assign display_startBird_eye1 = ((x >= 112 && x < 119) && (y >= 175 && y < 183)) && start_state;

	assign display_startBird_eye2 = (((x >= 108 && x < 112) && (y >= 175 && y < 187)) ||
												((x >= 108 && x < 119) && (y >= 183 && y < 187))) && start_state;

	assign display_startBird_beak = ((x >= 122 && x < 127) && (y >= 179 && y < 185)) && start_state;


//Display LOSE screen - wires only are true when lose_state is present
	wire display_L,display_O,display_S,display_E;

	// Displaying the letters L O S E side by side
	assign display_L = ((x >= 240 && x < 250) && (y >= 150 && y < 310) ||
							  (x >= 240 && x < 250) && (y >= 270 && y < 280) ||
							  (x >= 240 && x < 260) && (y >= 300 && y < 310)) && lose_state;

	assign display_O = ((x >= 270 && x < 280) && (y >= 150 && y < 310) ||
							  (x >= 280 && x < 300) && (y >= 150 && y < 160) ||
							  (x >= 280 && x < 300) && (y >= 300 && y < 310) ||
							  (x >= 290 && x < 300) && (y >= 160 && y < 300)) && lose_state;

	assign display_S = (((x >= 310) && (x < 340) && (y >= 150) && (y < 160)) ||
								((x >= 310) && (x < 320) && (y >= 150) && (y < 230)) ||
								((x >= 310) && (x < 340) && (y >= 230) && (y < 240)) ||
								((x >= 330) && (x < 340) && (y >= 240) && (y < 310)) ||
								((x >= 310) && (x < 340) && (y >= 300) && (y < 310))) && lose_state;

	assign display_E = (((x >= 350) && (x < 360) && (y >= 150) && (y < 310)) ||
								((x >= 350) && (x < 380) && (y >= 150) && (y < 160)) || 
								((x >= 350) && (x < 370) && (y >= 230) && (y < 240)) ||
								((x >= 350) && (x < 380) && (y >= 300) && (y < 310))) && lose_state;
									  
	
	//Assign color to the VGA monitor based on whatever wire is set to true
	// When SW9 is flipped up, change the color (monochrome filter)
		always @(posedge pixel_clk) begin
			 if (~disp_ena) begin
				  set_r = 4'h0; // black
				  set_g = 4'h0;
				  set_b = 4'h0;
			 end else begin
				  if (display_F || display_P || display_G || display_A) begin
						if (!SW9) begin
							 set_r = 4'h7; // purple
							 set_g = 4'h0;
							 set_b = 4'hF;
						end else begin
							 set_r = 4'h4; // dark grey
							 set_g = 4'h4;
							 set_b = 4'h4;
						end
				  end else if (display_B || display_I || display_R || display_D) begin
						if (!SW9) begin
							 set_r = 4'hF; // orange
							 set_g = 4'h7;
							 set_b = 4'h0;
						end else begin
							 set_r = 4'h8; // grey
							 set_g = 4'h8;
							 set_b = 4'h8;
						end
				  end else if (display_startPipe_1 || display_startPipe_2) begin
						if (!SW9) begin
							 set_r = 4'h0; // green
							 set_g = 4'h7;
							 set_b = 4'h0;
						end else begin
							 set_r = 4'h4; // dark grey
							 set_g = 4'h4;
							 set_b = 4'h4;
						end
				  end else if (display_startBird_body || bird_bodyOn) begin
						if (!SW9) begin
							 set_r = 4'hF; // orange
							 set_g = 4'h7;
							 set_b = 4'h0;
						end else begin
							 set_r = 4'h8; // grey
							 set_g = 4'h8;
							 set_b = 4'h8;
						end
				  end else if (display_startBird_eye1 || bird_eye1On) begin
						if (!SW9) begin
							 set_r = 4'hF; // white
							 set_g = 4'hF;
							 set_b = 4'hF;
						end else begin
							 set_r = 4'hF; // white
							 set_g = 4'hF;
							 set_b = 4'hF;
						end
				  end else if (display_startBird_eye2 || bird_eye2On) begin
						if (!SW9) begin
							 set_r = 4'h0; // black
							 set_g = 4'h0;
							 set_b = 4'h0;
						end else begin
							 set_r = 4'h0; // black
							 set_g = 4'h0;
							 set_b = 4'h0;
						end
				  end else if (display_startBird_beak || bird_beakOn) begin
						if (!SW9) begin
							 set_r = 4'hF; // yellow
							 set_g = 4'hF;
							 set_b = 4'h0;
						end else begin
							 set_r = 4'h9; // grey
							 set_g = 4'h9;
							 set_b = 4'h9;
						end
				  end else if (display_L || display_O || display_S || display_E) begin
						if (!SW9) begin
							 set_r = 4'hF; // red
							 set_g = 4'h0;
							 set_b = 4'h0;
						end else begin
							 set_r = 4'h8; // grey
							 set_g = 4'h8;
							 set_b = 4'h8;
						end
				  end else if (pipe_on_1) begin
						if (!SW9) begin
							 if (pipe_speed <= 2) begin
								  set_r = 4'h0; // green
								  set_g = 4'h9;
								  set_b = 4'h0;
							 end else if (pipe_speed == 3) begin
								  set_r = 4'h6; // purple
								  set_g = 4'h0;
								  set_b = 4'hF;                    
							 end else if (pipe_speed == 4) begin
								  set_r = 4'hB; // red
								  set_g = 4'h0;
								  set_b = 4'h0;                    
							 end else if (pipe_speed == 5) begin
								  set_r = 4'h0; // cyan
								  set_g = 4'h9;
								  set_b = 4'hF;                    
							 end
						end else begin
							 set_r = 4'h4; // dark grey
							 set_g = 4'h4;
							 set_b = 4'h4;                
						end
				  end else if (pipe_on_2) begin
						if (!SW9) begin
							 if (pipe_speed <= 2) begin
								  set_r = 4'h0; // green
								  set_g = 4'h9;
								  set_b = 4'h0;
							 end else if (pipe_speed == 3) begin
								  set_r = 4'hB; // purple
								  set_g = 4'h0;
								  set_b = 4'hF;                    
							 end else if (pipe_speed == 4) begin
								  set_r = 4'h8; // red
								  set_g = 4'h0;
								  set_b = 4'h0;                    
							 end else if (pipe_speed == 5) begin
								  set_r = 4'h0; // cyan
								  set_g = 4'hE;
								  set_b = 4'h0;                    
							 end
						end else begin
							 set_r = 4'h4; // dark grey
							 set_g = 4'h4;
							 set_b = 4'h4;
						end
				  end else begin
						if(~SW9) begin  
							 if(lose_state) begin
								  set_r = 4'h0; // black background
								  set_g = 4'h0;
								  set_b = 4'h0;                    
							 end else if(!lose_state && pipe_speed <=2) begin
								  set_r = 4'h5; // sky background
								  set_g = 4'h9;
								  set_b = 4'hF;                    
							 end else if(!lose_state && pipe_speed <=3) begin
								  set_r = 4'h8; // sky background
								  set_g = 4'h8;
								  set_b = 4'hF;                    
							 end else if(!lose_state && pipe_speed <=4) begin
								  set_r = 4'hD; // sky background
								  set_g = 4'hA;
								  set_b = 4'hF;                    
							 end else if(!lose_state && pipe_speed <=5) begin
								  set_r = 4'hF; // sky background
								  set_g = 4'h8;
								  set_b = 4'h8;                    
							 end else begin
								  set_r = 4'h5; // black background
								  set_g = 4'h9;
								  set_b = 4'hF;
							 end
						end else begin
							 set_r = 4'hF; // white
							 set_g = 4'hF;
							 set_b = 4'hF;              
						end
				  end
			 end
		end
		
	assign VGA_R = set_r;
	assign VGA_G = set_g;
	assign VGA_B = set_b;
	
endmodule

//Clock divider that toggles cout at a rate of 1s (Clock of 2s)
module ClockDivider_1s(cin,cout);
	//Based on (corrected) code from fpga4student.com
	input cin;
	output reg cout;
	reg[31:0] count;
	parameter D = 32'd50000000;//Toggle once counter reaches 0.5s
	always @(posedge cin)
	begin
		count <= count + 32'd1;
		if (count >= (D-1)) begin
			cout <= ~cout;
			count <= 32'd0;
		end
	end
endmodule

//Clock divider that toggles cout at a rate of 0.75s (Clock of 1.5s)
module ClockDivider_05s(cin,cout);
	//Based on (corrected) code from fpga4student.com
	input cin;
	output reg cout;
	reg[31:0] count;
	parameter D = 32'd75000000;//Toggle once counter reaches 0.75s
	always @(posedge cin)
	begin
		count <= count + 32'd1;
		if (count >= (D-1)) begin
			cout <= ~cout;
			count <= 32'd0;
		end
	end
endmodule