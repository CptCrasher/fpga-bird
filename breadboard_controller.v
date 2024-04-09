module breadboard_controller(clk,ARDUINO[3:0],start_state,lose_state,score,KEY0);

//Initialize inputs, outputs, wires and regs used in module
output [3:0] ARDUINO;
input [31:0] score;
input clk,start_state,lose_state,KEY0;

wire cout;
ClockDivider(clk,cout);

reg red_led,green_led,blue_led;
reg buzzer;

//Setting up two different periods for the notes G4 and C5 for the passive buzzer to be toggled at
    reg [31:0] counter_G4 = 32'd0;
    reg [31:0] half_period_reg_G4;
    reg toggle_G4;

	 reg [31:0] counter_C5 = 32'd0;
    reg [31:0] half_period_reg_C5;
    reg toggle_C5;
    
	 initial begin
        half_period_reg_G4 = ((50000000 / 392) /2); //  half period for G4 (392 Hz) with 50 MHz clock
        half_period_reg_C5 = ((50000000 / 523) /2); //  half period for C5 (523 Hz) with 50 MHz clock
        toggle_G4 = 1'b0; // Start with G4
        toggle_C5 = 1'b0; // Start with C5
    end
	 
		 //Toggle 'toggle_C5' at C5 half period
		 always @(posedge clk) begin
			  if (counter_C5 == half_period_reg_C5 - 1) begin
					counter_C5 <= 32'd0;
					toggle_C5 <= ~toggle_C5;
			  end else begin
					counter_C5 <= counter_C5 + 1;
			  end
		 end	 

		 //Toggle 'toggle_G4' at G4 half period
       always @(posedge clk) begin
        if (counter_G4 == half_period_reg_G4 - 1) begin
            counter_G4 <= 32'd0;
            toggle_G4 <= ~toggle_G4;
        end else begin
            counter_G4 <= counter_G4 + 1;
        end
    end
	 
	reg [31:0] score_prev = 0;	
	reg [31:0] counter = 0;
	
	//Whenever the score changes, play the buzzer for a set amount of time (runs at a 0.125 clock speed)
	always @(posedge cout) begin
		if(~KEY0)begin
			buzzer <= 0;
			counter <= 0;
			score_prev = 0;
		end else	if(!start_state || !lose_state) begin
			//Turn buzzer on, begin counting for 0.25 seconds (change the number 2 to increase/decrease time)
			if(score != score_prev && score != 0) begin
				buzzer <= 1;
				counter <= counter + 1;
				if(counter >= 2) begin // When counter becomes >= 2, (total of 0.25s) turn the buzzer off as 0.25s went by and reset counter
					score_prev = score;
					buzzer <= 0;
					counter <= 0;
				end
			end
		end
	end

	//Depending on the present state, turn the associated LED on
	always @(start_state,lose_state,KEY0) begin
		if(~KEY0)begin
			blue_led <= 0;
			green_led <= 0;
			red_led <= 0;
		end else begin
			if(start_state) begin
				blue_led <= 1;
				green_led <= 0;
				red_led <= 0;
			end else if(lose_state) begin
				blue_led <= 0;
				green_led <= 0;
				red_led <= 1;
			end else if(!lose_state && !start_state) begin
				blue_led <= 0;
				green_led <= 1;
				red_led <= 0;
			end
		end	
	end
	
assign ARDUINO[0] = buzzer;	
assign ARDUINO[1] = red_led;
assign ARDUINO[2] = green_led;
assign ARDUINO[3] = blue_led;	
endmodule

//Clock divider that toggles cout at a rate of 0.125s
module ClockDivider(cin,cout);
	//Based on (corrected) code from fpga4student.com
	input cin;
	output reg cout;
	reg[31:0] count;
	parameter D = 32'd3125000;//Toggle once counter reaches 0.125s
	always @(posedge cin)
	begin
		count <= count + 32'd1;
		if (count >= (D-1)) begin
			cout <= ~cout;
			count <= 32'd0;
		end
	end
endmodule