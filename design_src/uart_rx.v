`timescale 1ns / 1ps

module uart_rx#(
    parameter NB_DATA = 8,
    parameter N_TICKS = 16
)
(
    input wire i_clk,
    input wire i_reset,
    input wire i_rx,
    input wire i_tick,
    output reg o_rx_done,
    output wire [NB_DATA-1:0] o_dout
);

//FSM stages
localparam [1:0] IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

//Signal declaration
reg [1:0] state, state_next; 
reg [3:0] s, s_next;                                    //ticks count
reg [2:0] n, n_next;                                    //bits count
reg [NB_DATA-1:0] received_byte, received_byte_next;

//Finite State Machine with DATA (state and DATA registers)
always @(posedge i_clk) begin
    if (i_reset) begin
        state <= IDLE;
        s <= 0;
        n <= 0;
        received_byte <= 0;
    end
    else begin
        state <= state_next;
        s <= s_next;
        n <= n_next;
        received_byte <= received_byte_next;
    end
end

//Finite State Machine with DATA (next state logic)
always @(*) begin
    state_next = state;
    o_rx_done = 1'b0;
    s_next = s;
    n_next = n;
    received_byte_next = received_byte;

    case (state)
        IDLE:
            if (~i_rx) 
            begin
               state_next = START;
               s_next = 0; 
            end
        
        START:
            if (i_tick) 
            begin
                if (s == 7) begin
                    state_next = DATA;
                    s_next = 0;
                    n_next = 0;
                end
                else begin
                    s_next = s + 1;
                end
                
            end

        DATA:
            if (i_tick) begin
                if (s == 15) begin
                    s_next = 0;
                    received_byte_next = {i_rx, received_byte[NB_DATA-1:1]};
                    if (n == (NB_DATA-1)) begin
                        state_next = STOP;
                    end
                    else begin
                        n_next = n + 1;
                    end

                end
                else begin 
                    s_next = s + 1;
                end
                
            end
        
        STOP:
            if (i_tick) begin
                if (s == (N_TICKS-1)) begin
                    state_next = IDLE;
                    if(i_rx) begin
                        o_rx_done = 1'b1;
                    end
                end 
                else begin
                    s_next = s + 1;
                end
            end

        default: 
            state_next = IDLE;   
    endcase
end

assign o_dout = received_byte;

endmodule