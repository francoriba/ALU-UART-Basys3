`timescale 1ns / 1ps
/*
    Genera un pulso (tick) cada vez que el contador llega a COUNT_MAX_VALUE (contador modulo 163)
    COUNT_MAX_VALUE = 163 para f = 50MHz y Baudrate = 19200
    COUNT_MAX_VALUE = 651 para f = 100MHz y Baudrate = 9600
*/

module baudrate_generator
#(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 19200
)
(
    input   wire    i_clock,
    input   wire    i_reset,
    output  wire    o_ticks //pulso cada 16 ciclos de clock
);

localparam COUNT_MAX_VALUE  = CLK_FREQ / (BAUD_RATE * 16);
localparam NB_COUNTER = $clog2(COUNT_MAX_VALUE);

reg [NB_COUNTER-1 : 0] conta; //leva la cuenta de los ciclos de reloj

assign o_ticks = (conta == COUNT_MAX_VALUE);

always @(posedge i_clock)
begin
    if(i_reset)
        conta <= {NB_COUNTER {1'b0}};
    else if(conta == COUNT_MAX_VALUE)
        conta <= {{NB_COUNTER-1 {1'b0}}, 1'b1}; //conta = 1 -> porque no se resta 1 en COUNT_MAX_VALUE
    else
        conta <= conta + {{NB_COUNTER-1 {1'b0}}, 1'b1}; //conta++
    
end

endmodule //baudrate_generator