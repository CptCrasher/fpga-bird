module displayScore(HEX0[7:0],HEX1[7:0],score,HEX5[7:0],HEX4[7:0],HEX3[7:0]);

output [7:0] HEX0,HEX1,HEX5,HEX4,HEX3;
input [31:0] score;
reg [7:0] disp5,disp4,disp3;
reg [7:0] f,g;
always @(*)begin

	//Display the letters S c r (representing the word score) on hex displays 3, 4, 5
	disp5 = 8'b10010010;//S
	disp4 = 8'b10100111;//c
	disp3 = 8'b00101111;//r

	//Depending on the score, display the tens digit of the score to hex display 1 and the ones digit to hex display 0
	case(score)
		32'd99: begin //f = 9, g = 9
			 f = 8'b10010000; g = 8'b10010000;
		end
		32'd98: begin //f = 9, g = 8
			 f = 8'b10010000; g = 8'b10000000;
		end
		32'd97: begin //f = 9, g = 7
			 f = 8'b10010000; g = 8'b11111000;
		end
		32'd96: begin //f = 9, g = 6
			 f = 8'b10010000; g = 8'b10000010;
		end
		32'd95: begin //f = 9, g = 5
			 f = 8'b10010000; g = 8'b10010010;
		end
		32'd94: begin //f = 9, g = 4
			 f = 8'b10010000; g = 8'b10011001;
		end
		32'd93: begin //f = 9, g = 3
			 f = 8'b10010000; g = 8'b10110000;
		end
		32'd92: begin //f = 9, g = 2
			 f = 8'b10010000; g = 8'b10100100;
		end
		32'd91: begin //f = 9, g = 1
			 f = 8'b10010000; g = 8'b11111001;
		end
		32'd90: begin //f = 9, g = 0
			 f = 8'b10010000; g = 8'b11000000;
		end
		32'd89: begin //f = 8, g = 9
			 f = 8'b10000000; g = 8'b10010000;
		end
		32'd88: begin //f = 8, g = 8
			 f = 8'b10000000; g = 8'b10000000;
		end
		32'd87: begin //f = 8, g = 7
			 f = 8'b10000000; g = 8'b11111000;
		end
		32'd86: begin //f = 8, g = 6
			 f = 8'b10000000; g = 8'b10000010;
		end
		32'd85: begin //f = 8, g = 5
			 f = 8'b10000000; g = 8'b10010010;
		end
		32'd84: begin //f = 8, g = 4
			 f = 8'b10000000; g = 8'b10011001;
		end
		32'd83: begin //f = 8, g = 3
			 f = 8'b10000000; g = 8'b10110000;
		end
		32'd82: begin //f = 8, g = 2
			 f = 8'b10000000; g = 8'b10100100;
		end
		32'd81: begin //f = 8, g = 1
			 f = 8'b10000000; g = 8'b11111001;
		end
		32'd80: begin //f = 8, g = 0
			 f = 8'b10000000; g = 8'b11000000;
		end
		32'd79: begin //f = 7, g = 9
			 f = 8'b11111000; g = 8'b10010000;
		end
		32'd78: begin //f = 7, g = 8
			 f = 8'b11111000; g = 8'b10000000;
		end
		32'd77: begin //f = 7, g = 7
			 f = 8'b11111000; g = 8'b11111000;
		end
		32'd76: begin //f = 7, g = 6
			 f = 8'b11111000; g = 8'b10000010;
		end
		32'd75: begin //f = 7, g = 5
			 f = 8'b11111000; g = 8'b10010010;
		end
		32'd74: begin //f = 7, g = 4
			 f = 8'b11111000; g = 8'b10011001;
		end
		32'd73: begin //f = 7, g = 3
			 f = 8'b11111000; g = 8'b10110000;
		end
		32'd72: begin //f = 7, g = 2
			 f = 8'b11111000; g = 8'b10100100;
		end
		32'd71: begin //f = 7, g = 1
			 f = 8'b11111000; g = 8'b11111001;
		end
		32'd70: begin //f = 7, g = 0
			 f = 8'b11111000; g = 8'b11000000;
		end
		32'd69: begin //f = 6, g = 9
			 f = 8'b10000010; g = 8'b10010000;
		end
		32'd68: begin //f = 6, g = 8
			 f = 8'b10000010; g = 8'b10000000;
		end
		32'd67: begin //f = 6, g = 7
			 f = 8'b10000010; g = 8'b11111000;
		end
		32'd66: begin //f = 6, g = 6
			 f = 8'b10000010; g = 8'b10000010;
		end
		32'd65: begin //f = 6, g = 5
			 f = 8'b10000010; g = 8'b10010010;
		end
		32'd64: begin //f = 6, g = 4
			 f = 8'b10000010; g = 8'b10011001;
		end
		32'd63: begin //f = 6, g = 3
			 f = 8'b10000010; g = 8'b10110000;
		end
		32'd62: begin //f = 6, g = 2
			 f = 8'b10000010; g = 8'b10100100;
		end
		32'd61: begin //f = 6, g = 1
			 f = 8'b10000010; g = 8'b11111001;
		end
		32'd60: begin //f = 6, g = 0
			 f = 8'b10000010; g = 8'b11000000;
		end
		32'd59: begin //f = 5, g = 9
			 f = 8'b10010010; g = 8'b10010000;
		end
		32'd58: begin //f = 5, g = 8
			 f = 8'b10010010; g = 8'b10000000;
		end
		32'd57: begin //f = 5, g = 7
			 f = 8'b10010010; g = 8'b11111000;
		end
		32'd56: begin //f = 5, g = 6
			 f = 8'b10010010; g = 8'b10000010;
		end
		32'd55: begin //f = 5, g = 5
			 f = 8'b10010010; g = 8'b10010010;
		end
		32'd54: begin //f = 5, g = 4
			 f = 8'b10010010; g = 8'b10011001;
		end
		32'd53: begin //f = 5, g = 3
			 f = 8'b10010010; g = 8'b10110000;
		end
		32'd52: begin //f = 5, g = 2
			 f = 8'b10010010; g = 8'b10100100;
		end
		32'd51: begin //f = 5, g = 1
			 f = 8'b10010010; g = 8'b11111001;
		end
		32'd50: begin //f = 5, g = 0
			 f = 8'b10010010; g = 8'b11000000;
		end
		32'd49: begin //f = 4, g = 9
			 f = 8'b10011001; g = 8'b10010000;
		end
		32'd48: begin //f = 4, g = 8
			 f = 8'b10011001; g = 8'b10000000;
		end
		32'd47: begin //f = 4, g = 7
			 f = 8'b10011001; g = 8'b11111000;
		end
		32'd46: begin //f = 4, g = 6
			 f = 8'b10011001; g = 8'b10000010;
		end
		32'd45: begin //f = 4, g = 5
			 f = 8'b10011001; g = 8'b10010010;
		end
		32'd44: begin //f = 4, g = 4
			 f = 8'b10011001; g = 8'b10011001;
		end
		32'd43: begin //f = 4, g = 3
			 f = 8'b10011001; g = 8'b10110000;
		end
		32'd42: begin //f = 4, g = 2
			 f = 8'b10011001; g = 8'b10100100;
		end
		32'd41: begin //f = 4, g = 1
			 f = 8'b10011001; g = 8'b11111001;
		end
		32'd40: begin //f = 4, g = 0
			 f = 8'b10011001; g = 8'b11000000;
		end
		32'd39: begin //f = 3, g = 9
			 f = 8'b10110000; g = 8'b10010000;
		end
		32'd38: begin //f = 3, g = 8
			 f = 8'b10110000; g = 8'b10000000;
		end
		32'd37: begin //f = 3, g = 7
			 f = 8'b10110000; g = 8'b11111000;
		end
		32'd36: begin //f = 3, g = 6
			 f = 8'b10110000; g = 8'b10000010;
		end
		32'd35: begin //f = 3, g = 5
			 f = 8'b10110000; g = 8'b10010010;
		end
		32'd34: begin //f = 3, g = 4
			 f = 8'b10110000; g = 8'b10011001;
		end
		32'd33: begin //f = 3, g = 3
			 f = 8'b10110000; g = 8'b10110000;
		end
		32'd32: begin //f = 3, g = 2
			 f = 8'b10110000; g = 8'b10100100;
		end
		32'd31: begin //f = 3, g = 1
			 f = 8'b10110000; g = 8'b11111001;
		end
		32'd30: begin //f = 3, g = 0
			 f = 8'b10110000; g = 8'b11000000;
		end
		32'd29: begin //f = 2, g = 9
			 f = 8'b10100100; g = 8'b10010000;
		end
		32'd28: begin //f = 2, g = 8
			 f = 8'b10100100; g = 8'b10000000;
		end
		32'd27: begin //f = 2, g = 7
			 f = 8'b10100100; g = 8'b11111000;
		end
		32'd26: begin //f = 2, g = 6
			 f = 8'b10100100; g = 8'b10000010;
		end
		32'd25: begin //f = 2, g = 5
			 f = 8'b10100100; g = 8'b10010010;
		end
		32'd24: begin //f = 2, g = 4
			 f = 8'b10100100; g = 8'b10011001;
		end
		32'd23: begin //f = 2, g = 3
			 f = 8'b10100100; g = 8'b10110000;
		end
		32'd22: begin //f = 2, g = 2
			 f = 8'b10100100; g = 8'b10100100;
		end
		32'd21: begin //f = 2, g = 1
			 f = 8'b10100100; g = 8'b11111001;
		end
		32'd20: begin //f = 2, g = 0
			 f = 8'b10100100; g = 8'b11000000;
		end
		32'd19: begin //f = 1, g = 9
			 f = 8'b11111001; g = 8'b10010000;
		end
		32'd18: begin //f = 1, g = 8
			 f = 8'b11111001; g = 8'b10000000;
		end
		32'd17: begin //f = 1, g = 7
			 f = 8'b11111001; g = 8'b11111000;
		end
		32'd16: begin //f = 1, g = 6
			 f = 8'b11111001; g = 8'b10000010;
		end
		32'd15: begin //f = 1, g = 5
			 f = 8'b11111001; g = 8'b10010010;
		end
		32'd14: begin //f = 1, g = 4
			 f = 8'b11111001; g = 8'b10011001;
		end
		32'd13: begin //f = 1, g = 3
			 f = 8'b11111001; g = 8'b10110000;
		end
		32'd12: begin //f = 1, g = 2
			 f = 8'b11111001; g = 8'b10100100;
		end
		32'd11: begin //f = 1, g = 1
			 f = 8'b11111001; g = 8'b11111001;
		end
		32'd10: begin //f = 1, g = 0
			 f = 8'b11111001; g = 8'b11000000;
		end
		32'd9: begin //f = 0, g = 9
			 f = 8'b11000000; g = 8'b10010000;
		end
		32'd8: begin //f = 0, g = 8
			 f = 8'b11000000; g = 8'b10000000;
		end
		32'd7: begin //f = 0, g = 7
			 f = 8'b11000000; g = 8'b11111000;
		end
		32'd6: begin //f = 0, g = 6
			 f = 8'b11000000; g = 8'b10000010;
		end
		32'd5: begin //f = 0, g = 5
			 f = 8'b11000000; g = 8'b10010010;
		end
		32'd4: begin //f = 0, g = 4
			 f = 8'b11000000; g = 8'b10011001;
		end
		32'd3: begin //f = 0, g = 3
			 f = 8'b11000000; g = 8'b10110000;
		end
		32'd2: begin //f = 0, g = 2
			 f = 8'b11000000; g = 8'b10100100;
		end
		32'd1: begin //f = 0, g = 1
			 f = 8'b11000000; g = 8'b11111001;
		end
		32'd0: begin //f = 0, g = 0
			 f = 8'b11000000; g = 8'b11000000;
		end
	endcase
end


assign HEX1 = f;
assign HEX0 = g;
assign HEX5 = disp5;
assign HEX4 = disp4;
assign HEX3 = disp3;

endmodule