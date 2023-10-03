`timescale 1ns / 1ps
/*
    Modulo Top que conecta la UART con la interfaz y ALU
*/


module top
#(
    parameter LIMITE = 163,     //limite de cuenta del baudrate
    parameter NB_CONTA = 8,     //cant de bits del contador del baudrate
    parameter N_BITS = 8,       //cant de bits de datos
    parameter N_TICKS = 16      //cant de ticks para llegar al ancho de un bit
)
(
    input   wire                i_clock,
    input   wire                i_reset,
    input   wire                i_rx,
    output  wire                o_tx_done_tick,
    output  wire                o_tx
);

wire    [N_BITS-1:0]    argumentos; //bus que une o_dout(Rx) con i_dato(interfaz)
wire                    input_valid; //cable que une o_rx_done_tick(Rx) con i_valid(interfaz)
wire    [N_BITS-1:0]    resultado; //bus que une o_result(interfaz) con i_din(Tx)
wire                    output_valid; //cable que une o_valid(interfaz) con i_ready(Tx)



uart
#(
    .LIMITE             (LIMITE),    
    .NB_CONTA           (NB_CONTA),     
    .N_BITS             (N_BITS),      
    .N_TICKS            (N_TICKS)      
)
u_uart
(
    .i_clock            (i_clock),
    .i_reset            (i_reset),
    .i_rx               (i_rx),
    .i_ready            (output_valid),
    .i_din              (resultado),
    .o_rx_done_tick     (input_valid),
    .o_dout             (argumentos),
    .o_tx_done_tick     (o_tx_done_tick),
    .o_tx               (o_tx)
);

interfaz
#(
    .NB_DATA            (N_BITS)
)
u_interfaz
(
    .i_clock            (i_clock),
    .i_reset            (i_reset),
    .i_valid            (input_valid),
    .i_dato             (argumentos),
    .o_result           (resultado),
    .o_valid            (output_valid)
);




endmodule //top