`timescale 1ns / 1ps
/*
    Genera un tick 16 veces por baudrate
*/

module baudrate_generator
#(
    parameter LIMITE = 163,
    parameter NB_CONTA = 8
)
(
    input   wire    i_clock,
    input   wire    i_reset,
    output  wire    o_ticks
);

reg [NB_CONTA-1 : 0] conta;

assign o_ticks = (conta == LIMITE);

always @(posedge i_clock)
begin
    if(i_reset)
        conta <= {NB_CONTA {1'b0}};
    else if(conta == LIMITE)
        conta <= {{NB_CONTA-1 {1'b0}}, 1'b1}; //conta = 1
    else
        conta <= conta + {{NB_CONTA-1 {1'b0}}, 1'b1}; //conta++
    
end

endmodule //baudrate_generator