`timescale 1ns / 1ps
/*
    Modulo UART que contiene al baudrate, Tx y Rx.
*/


module uart
#(
    parameter CLK_FREQ = 50000000, 
    parameter BAUD_RATE = 19200,
    parameter N_BITS = 8,       //cant de bits de datos
    parameter N_TICKS = 16      //cant de ticks para llegar al ancho de un bit
)
(
    input   wire                i_clock,
    input   wire                i_reset,
    input   wire                i_rx,
    input   wire                i_ready,
    input   wire [N_BITS-1:0]   i_din,
    output  wire                o_rx_done_tick,
    output  wire [N_BITS-1:0]   o_dout,
    output  wire                o_tx_done_tick,
    output  wire                o_tx
    
);

wire    tick;  //cable que une el baudrate generator con el Rx y el Tx


baudrate_generator
#(
    .CLK_FREQ       (CLK_FREQ),
    .BAUD_RATE       (BAUD_RATE)
)
u_baudrate_generator
(
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .o_ticks        (tick)
);

uart_receptor
#(
    .N_BITS         (N_BITS),
    .N_TICKS        (N_TICKS)
)
u_uart_receptor //Rx
(
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .i_rx           (i_rx),
    .i_s_tick       (tick),
    .o_rx_done_tick (o_rx_done_tick),
    .o_dout         (o_dout)
);

uart_transmisor //Tx
#(
    .N_BITS         (N_BITS),
    .N_TICKS        (N_TICKS)
)
u_uart_transmisor
(
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .i_ready        (i_ready),
    .i_s_tick       (tick),
    .i_din          (i_din),
    .o_tx_done_tick (o_tx_done_tick),
    .o_tx           (o_tx)
);

endmodule //uart
