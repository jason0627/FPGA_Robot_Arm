`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module position(
	input clk,
	input rst,
	input [7:0] action,
	output [7:0] location_1,
	output [7:0] location_2,
	output [7:0] location_3,
	output [7:0] location_4,	
	output [7:0] ledOut
    );
    
assign ledOut[7:0] = led_indicate[7:0];
reg [7:0] led_indicate;
reg [26:0] ctr_d, ctr_q;    

reg [7:0] servo_pos_1_d, servo_pos_1_q;
reg [7:0] servo_pos_2_d, servo_pos_2_q;
reg [7:0] servo_pos_3_d, servo_pos_3_q;
reg [7:0] servo_pos_4_d, servo_pos_4_q;

assign location_1 = servo_pos_1_q;
assign location_2 = servo_pos_2_q;
assign location_3 = servo_pos_3_q;
assign location_4 = servo_pos_4_q;

localparam  MOTOR1_FWD = 8'b0011_0001,
 		    MOTOR1_REV = 8'b0011_0010,
		    MOTOR2_FWD = 8'b0011_0011,
 		    MOTOR2_REV = 8'b0011_0100,		    
		    MOTOR3_FWD = 8'b0011_0101,
 		    MOTOR3_REV = 8'b0011_0110,
		    MOTOR4_FWD = 8'b0011_0111,
 		    MOTOR4_REV = 8'b0011_1000,		    
		    MOTOR_IDLE = 8'b0011_0000;		  

always @(posedge ctr_q[18]) begin
	case(action)
		MOTOR_IDLE : begin
		led_indicate = MOTOR_IDLE;
		servo_pos_1_d = servo_pos_1_q;
		servo_pos_2_d = servo_pos_2_q;
		servo_pos_3_d = servo_pos_3_q;
		servo_pos_4_d = servo_pos_4_q;		
		end
		
		MOTOR1_FWD : begin
		led_indicate = MOTOR1_FWD;
		if (servo_pos_1_q == 8'd255) servo_pos_1_d = 8'd255;
		else servo_pos_1_d = servo_pos_1_q + 1;
		end

		MOTOR1_REV : begin
		led_indicate = MOTOR1_REV;
		if (servo_pos_1_q == 8'd1) servo_pos_1_d = 8'd1;
		else servo_pos_1_d = servo_pos_1_q - 1;
		end

		MOTOR2_FWD : begin             // Keypad #3
		led_indicate = MOTOR2_FWD;
		if (servo_pos_2_q == 8'd200) servo_pos_2_d = 8'd200;
		else servo_pos_2_d = servo_pos_2_q + 1;
		end

		MOTOR2_REV : begin             // Keypad #4 
		led_indicate = MOTOR2_REV;
		if (servo_pos_2_q == 8'd35) servo_pos_2_d = 8'd35;
		else servo_pos_2_d = servo_pos_2_q - 1;
		end		

		MOTOR3_FWD : begin             // Keypad #5
		led_indicate = MOTOR1_FWD;
		if (servo_pos_3_q == 8'd180) servo_pos_3_d = 8'd180;
		else servo_pos_3_d = servo_pos_3_q + 1;
		end

		MOTOR3_REV : begin             // Keypad #6
		led_indicate = MOTOR1_REV;
		if (servo_pos_3_q == 8'd70) servo_pos_3_d = 8'd70;
		else servo_pos_3_d = servo_pos_3_q - 1;
		end

		MOTOR4_FWD : begin            
		led_indicate = MOTOR2_FWD;
		if (servo_pos_4_q == 8'd190) servo_pos_4_d = 8'd190;
		else servo_pos_4_d = servo_pos_4_q + 1;
		end

		MOTOR4_REV : begin            
		led_indicate = MOTOR2_REV;
		if (servo_pos_4_q == 8'd120) servo_pos_4_d = 8'd120;
		else servo_pos_4_d = servo_pos_4_q - 1;
		end
		
		default : begin
		led_indicate = MOTOR_IDLE;	
		servo_pos_1_d = 8'd128;
		servo_pos_2_d = 8'd128;
		servo_pos_3_d = 8'd128;
		servo_pos_4_d = 8'd128;		
		end
	endcase
end

/////////////////////////////////////////////////////
always @(ctr_q) begin
	ctr_d = ctr_q + 1;
end
always @(posedge clk) begin
	if (rst) ctr_q <= 27'b0;
	else ctr_q <= ctr_d;
     servo_pos_1_q <= servo_pos_1_d;
     servo_pos_2_q <= servo_pos_2_d;
     servo_pos_3_q <= servo_pos_3_d;	
     servo_pos_4_q <= servo_pos_4_d;		
end
/////////////////////////////////////////////////////
endmodule
