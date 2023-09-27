`timescale 1ns / 1ps

module uart_receptor
#(
    parameter N_BITS = 8,
    parameter N_TICKS = 16
)
(
    input   wire    i_clock,
    input   wire    i_reset,
    input   wire    i_rx,
    input   wire    i_s_tick,
    output  wire    o_rx_done_tick,
    output  wire [N_BITS-1:0] o_dout
);

localparam IDLE 	= 4'b0001;
localparam START 	= 4'b0010;
localparam DATA 	= 4'b0100;
localparam STOP 	= 4'b1000;

reg reg_rx_done_tick = 1'b0;
reg [3:0] state = IDLE;
reg [3:0] next_state = IDLE;
reg [3:0] s, s_next; //para contar los ticks
reg [2:0] n, n_next; //para contar los bits
reg [N_BITS-1:0] b, b_next; //para buffer

assign o_dout = b;
assign o_rx_done_tick = reg_rx_done_tick;

always @(posedge i_clock) //Memory
begin
    if(i_reset)
        begin
            state <= IDLE;
            s <= 4'b0;
            n <= 3'b0;
            b <= {N_BITS {1'b0}};
        end
    else
        begin
            state <= next_state;
            s <= s_next;
            n <= n_next;
            b <= b_next;
        end
end

always @(*) //Next-state logic
begin
    next_state = state;   
	s_next = s;
	n_next = n;  
	b_next = b;
    case(state)
        IDLE:
            begin
                if(i_rx == 1'b0) //si llego el bit de start paso al estado START
                    begin
                        next_state = START;
                        s_next = 4'b0;
                    end
            end
        START:
            begin
                if(i_s_tick == 1'b1)
                    if(s == 7) //si llegue a la mitad del bit de START paso al estado DATA y debo contar 16 ticks
                        begin
                            next_state = DATA;
                            s_next = 4'b0;
                            n_next = 3'b0;
                        end
                    else
                        s_next = s + 4'b1;
            end
        DATA:
            begin
                if(i_s_tick == 1'b1)
                    if(s == (N_TICKS-1))
                        begin
                            s_next = 4'b0;
                            b_next = {i_rx, b[N_BITS-1:1]};
                            if(n == (N_BITS-1))  //si ya lei todos los bits del dato paso al sig estado
                                next_state = STOP;
                            else
                                n_next = n + 3'b1;
                        end
                    else
                        s_next = s + 4'b1;
            end
        STOP:
            begin
                if(i_s_tick == 1'b1)
                    if(s == (N_TICKS-1)) //1 bit de stop
                        begin
                            next_state = IDLE;
                        end
                    else
                        begin
                            s_next = s + 4'b1;
                        end
            end
        default:
            begin
                next_state = IDLE;
            end
    endcase
end

always @(posedge i_clock)
begin
    case(state)
        IDLE: reg_rx_done_tick <= 1'b0;
        START: reg_rx_done_tick <= 1'b0;
        DATA: reg_rx_done_tick <= 1'b0;
        STOP: 
            begin
            if(i_s_tick == 1'b1)
                if(s == (N_TICKS-1)) //1 bit de stop
                    reg_rx_done_tick <= 1'b1;
                else reg_rx_done_tick <= 1'b0;
            else reg_rx_done_tick <= 1'b0;
            end 
        default: reg_rx_done_tick <= 1'b0;
    endcase
end
           
endmodule
