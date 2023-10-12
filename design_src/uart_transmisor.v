`timescale 1ns / 1ps


module uart_transmisor
#(
    parameter N_BITS = 8,
    parameter N_TICKS = 16
)
(
    input   wire                i_clock,
    input   wire                i_reset,
    input   wire                i_ready,
    input   wire                i_s_tick,
    input   wire [N_BITS-1:0]   i_din,
    output  wire                o_tx_done_tick,
    output  wire                o_tx
);

localparam IDLE 	= 4'b0001;
localparam START 	= 4'b0010;
localparam DATA 	= 4'b0100;
localparam STOP 	= 4'b1000;

reg reg_tx_done_tick = 1'b0;
reg tx, tx_next;  //mapeado con o_tx que es la salida serial
reg [3:0] state = IDLE;
reg [3:0] next_state = IDLE;
reg [3:0] s, s_next; //para contar los ticks
reg [2:0] n, n_next; //para contar los bits
reg [N_BITS-1:0] b, b_next; //para buffer

assign o_tx = tx;
assign o_tx_done_tick = reg_tx_done_tick;

always @(posedge i_clock)
begin   
	if (i_reset)  
		begin  
			state <= IDLE;  
			s <= 4'b0;  
			n <= 3'b0;  
			b <= {N_BITS {1'b0}};  
			tx <= 1'b1;  
		end 
	else  
		begin  
			state <= next_state;
			s <= s_next;
            n <= n_next;
            b <= b_next;  
			tx <= tx_next;  
		end
end

always @(*)  
begin
    next_state = state;   
	s_next = s;
	n_next = n;  
	b_next = b;
	tx_next = tx;
    case(state)
        IDLE:
            begin
                tx_next = 1'b1; //despues verificar si hace falta
                if(i_ready == 1'b1)
                    begin
                        next_state = START;
                        s_next = 4'b0;
                        b_next = i_din; //guardo en el buffer el dato
                    end
            end
        START:
            begin
                tx_next = 1'b0;  //pongo en cero el tx para avisar q empieza la transmision
                if(i_s_tick == 1'b1)
                    if(s == (N_TICKS-1))
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
                tx_next = b[0];  //voy sacando uno por uno los bits del buffer por el tx
                if(i_s_tick == 1'b1)
                    if(s == (N_TICKS-1))
                        begin
                            s_next = 4'b0;
                            b_next = b >> 1; //desplazamiento del buffer a la derecha
                            if(n == (N_BITS-1))  
                                next_state = STOP;
                            else
                                n_next = n + 3'b1;
                        end
                    else
                        s_next = s + 4'b1;
            end
        STOP:
            begin
                tx_next = 1'b1;  //pongo el tx en uno como bit de stop
                if(i_s_tick == 1'b1)
                    if(s == (N_TICKS-1)) 
                        begin
                            next_state = IDLE;
                        end
                    else
                        s_next = s + 4'b1;
            end
            
    endcase
end

always @(posedge i_clock)
begin
    case(state)
        IDLE: reg_tx_done_tick <= 1'b0;
        START: reg_tx_done_tick <= 1'b0;
        DATA: reg_tx_done_tick <= 1'b0;
        STOP: 
            begin
            if(i_s_tick == 1'b1)
                if(s == (N_TICKS-1)) //1 bit de stop
                    reg_tx_done_tick <= 1'b1;
                else reg_tx_done_tick <= 1'b0;
            else reg_tx_done_tick <= 1'b0;
            end 
        default: reg_tx_done_tick <= 1'b0;
    endcase
end
  
endmodule
