`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module serial_tx #(
        parameter CLK_PER_BIT = 5208 
    )(
        input clk,
        input rst,
        output tx,
        input [7:0] data,
        input send
    );

    // clog2 is 'ceiling of log base 2' which gives you the number of bits needed to store a value
    parameter CTR_SIZE = $clog2(CLK_PER_BIT);

    localparam STATE_SIZE = 2;
    localparam IDLE 	  = 2'd0,
			   START_BIT  = 2'd1,
			   DATA 	  = 2'd2,
			   STOP_BIT   = 2'd3;

    reg [CTR_SIZE-1:0] ctr_d, ctr_q;
    reg [2:0] bit_ctr_d, bit_ctr_q;
    reg [7:0] data_d, data_q;
    reg [STATE_SIZE-1:0] state_d, state_q = IDLE;
    reg tx_d, tx_q;
    assign tx = tx_q;

    always @(*) begin
        ctr_d = ctr_q;
        bit_ctr_d = bit_ctr_q;
        data_d = data_q;
        state_d = state_q;

        case (state_q)
            IDLE: begin
                    tx_d = 1'b1;
                    bit_ctr_d = 3'b0;
                    ctr_d = 1'b0;
                    if (send) begin
                        data_d = data;
                        state_d = START_BIT;
                    end
            end

            START_BIT: begin
                ctr_d = ctr_q + 1'b1;
                tx_d = 1'b0;
                if (ctr_q == CLK_PER_BIT - 1) begin
                    ctr_d = 1'b0;
                    state_d = DATA;
                end
            end

            DATA: begin
                tx_d = data_q[bit_ctr_q];
                ctr_d = ctr_q + 1'b1;
                if (ctr_q == CLK_PER_BIT - 1) begin
                    ctr_d = 1'b0;
                    bit_ctr_d = bit_ctr_q + 1'b1;
                    if (bit_ctr_q == 7) begin
                        state_d = STOP_BIT;
                    end
                end
            end

            STOP_BIT: begin
                tx_d = 1'b1;
                ctr_d = ctr_q + 1'b1;
                if (ctr_q == CLK_PER_BIT - 1) begin
                    state_d = IDLE;
                end
            end
            default: begin
                state_d = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state_q <= IDLE;
            tx_q <= 1'b1;
        end else begin
            state_q <= state_d;
            tx_q <= tx_d;
        end

        data_q <= data_d;
        bit_ctr_q <= bit_ctr_d;
        ctr_q <= ctr_d;
    end

endmodule

