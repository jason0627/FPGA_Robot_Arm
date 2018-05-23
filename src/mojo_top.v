module mojo_top(
    input clk,              	// 50MHz clock input
    input rst_n,			// Input from reset button (active low)
    input cclk,			// cclk input from AVR, high when AVR is ready
    output[7:0]led,			// Outputs to the 8 onboard LEDs
    
    input button,
    input uart_rx,
    output uart_tx,
    output pwmSignal_1,
    output pwmSignal_2,    
    output pwmSignal_3,
    output pwmSignal_4    
    );
wire [7:0] uart_data;
wire rst = ~rst_n; // make reset active high
reg [7:0] motor;
reg new_data;

wire [7:0] value_1, value_2, value_3, value_4;

// ------------------------- 
position my_position (
	.clk(clk),
	.rst(rst),
	.action(motor),        // 1. UART로 입력된 서보모터의 동작정의 값을 받아서	
	.location_1(value_1),  // 2. 서보모터 위치값을 결정하기 위한 position 값 4개을 출력하고
	.location_2(value_2),
	.location_3(value_3),
	.location_4(value_4),	
	.ledOut(led)           // 3. LED 출력값을 내보냄
);

servo my_servo_1 (
    .clk(clk),
    .rst(rst),
    .position(value_1),     // 1. position 값을 받아서  
    .pwm_out(pwmSignal_1)   // 2. 실제 전기적 pwm 신호를 각 port로 내보냄
);

servo my_servo_2 (
    .clk(clk),
    .rst(rst),
    .position(value_2),       
    .pwm_out(pwmSignal_2)  
);

servo my_servo_3 (
    .clk(clk),
    .rst(rst),
    .position(value_3),      
    .pwm_out(pwmSignal_3)  
);

servo my_servo_4 (
    .clk(clk),
    .rst(rst),
    .position(value_4),      
    .pwm_out(pwmSignal_4)  
);
// ----------------------------------------------------

serial_rx my_serial_rx (
	.clk(clk),
	.rst(rst),
	.rx(uart_rx),
	.data(uart_data),
	.new_data(uart_new)
);

always @(*) begin
	if(uart_new) motor = uart_data;
end

serial_tx my_serial_tx (
	.clk(clk),
	.rst(rst),
	.tx(uart_tx),
	.data(8'b0010_1110),    // 0x2E == . 출력
	.send(~button)          
);

endmodule


