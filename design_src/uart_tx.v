module uart_tx#
(
    parameter NB_DATA = 8,
    parameter N_TICKS = 16
)
(
    input wire i_clk,
    input wire i_reset,
    input wire i_tx_ready,
    input wire i_tick,
    input wire [NB_DATA-1 : 0] i_din,
    output reg o_tx_done,
    output wire o_tx
);

//FSM stages
localparam [1:0] IDLE = 2'b00, START = 2'b01, DATA = 2'b10, STOP = 2'b11;

//signal declaration
reg [1:0] state, state_next;
reg [3:0] s, s_next;
reg [2:0] n, n_next;
reg [NB_DATA-1:0] send_byte, send_byte_next;
reg tx,tx_next;

//Finite State Machine with Data (state and DATA registers)
always @(posedge i_clk) begin
    if(i_reset) begin
        state <= IDLE;
        s <= 0;
        n <= 0;
        send_byte <= 0;
        tx <= 1'b1;
    end
    else begin
        state <= state_next;
        s <= s_next;
        n <= n_next;
        send_byte <= send_byte_next;
        tx <= tx_next;
    end
end

//Finite State Machine with Data (next state logic and functional units)
always @(*) begin
    state_next = state;
    o_tx_done = 1'b0;
    s_next = s;
    n_next = n;
    send_byte_next = send_byte;
    tx_next = tx;

    case (state)
        IDLE: begin
            tx_next = 1'b1;
            if(i_tx_ready) begin
                state_next = START;
                s_next = 0;
                send_byte_next = i_din;
            end
        end
        
        START: begin
            tx_next = 1'b0;
            if (i_tick) begin
                if (s == 15) begin
                    state_next = DATA;
                    s_next = 0;
                    n_next = 0;
                end
                else begin
                    s_next = s + 1;
                end
            end
        end

        DATA: begin
            tx_next = send_byte[0];
            if (i_tick) begin
                if(s==15) begin
                    s_next = 0;
                    send_byte_next = send_byte >> 1;
                    if (n==(NB_DATA-1)) begin
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
        end

        STOP: begin
            tx_next = 1'b1;
            if (i_tick) begin
                if (s==(N_TICKS-1)) begin
                    state_next = IDLE;
                    o_tx_done = 1'b1;
                end
                else begin
                    s_next = s + 1;
                end
            end
        end
        default: begin
            state_next = IDLE;
        end
    endcase
end

assign o_tx = tx;

endmodule
