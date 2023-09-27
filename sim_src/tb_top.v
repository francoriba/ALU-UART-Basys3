`timescale 1ns / 1ps
/*
    Testbench general de todo el proyecto - 
    integra a todos los modulos: uart(Tx, Rx y baudrate), interfaz y ALU.
    Datos:
        - F = 50 MHz -> T = 20ns
        - baudrate = 19200
        - limite de cuenta -> 163
        - 1 tick cada 16 veces
   Entonces: 163*16*20 = 52160ns es la duracion de 1 bit
*/


module tb_top();

    //localparameters
    localparam  N_BITS = 8;
    localparam  N_TICKS = 16;
    localparam  LIMITE = 163;  //limite de cuenta del baudrate
    localparam  NB_CONTA = 8;  //cant de bits del contador baudrate
    localparam  N_BITS_OP = 6;
    localparam  ADD = 6'b100000;
    localparam  SUB = 6'b100010;
    localparam  AND = 6'b100100;
    localparam  OR  = 6'b100101;
    localparam  XOR = 6'b100110;
    localparam  SRA = 6'b000011;
    localparam  SRL = 6'b000010;
    localparam  NOR = 6'b100111;
    localparam  NO_VALID1 = 6'b000001;
    localparam  NO_VALID2 = 6'b111000;
    localparam  MAX = 2;//10
    
    //TB signals
    reg                         test_start;
    reg [N_BITS_OP * 10 -1:0]   codeOperacion;
    integer                     i;
    integer                     j;
    reg [N_BITS-1 : 0]          data;

    //INPUTS
    reg                         i_clock;
    reg                         i_reset;
    reg                         i_rx;
   
    //OUTPUTS
    wire                        o_tx;
    wire                        o_tx_done_tick;

    initial begin
    #0
    i_clock = 1'b0;
    test_start = 1'b0;
    i_reset = 1'b1;
    i_rx = 1'b1;  
    codeOperacion = {ADD, SUB, AND, OR, XOR, SRA, SRL, NOR, NO_VALID1, NO_VALID2};
    data = {N_BITS {1'b0}};

    #80
    i_reset = 1'b0;
    #20
    test_start = 1'b1;
    
    if(test_start)
    begin
        for(i = 0; i < MAX; i = i + 1)
        begin
             //--------------------Dato A-------------------------------------
            #15
            data = 8'b01010101; //se envian primero los menos significativos
            i_rx = 1'b0; //start 
            for(j = 0; j < N_BITS; j = j + 1)
            begin
                #52160
                i_rx = data[j];
            end
            #52160
            i_rx = 1'b1; //stop
            $display("El dato A es: %b (%h)", data, $signed(data)); 
        
            //--------------------Dato B-------------------------------------
            #90000  //minimo 52160
            data = 8'b01010111;
            i_rx = 1'b0; //start 
            for(j = 0; j < N_BITS; j = j + 1)
            begin
                #52160
                i_rx = data[j];
            end
            #52160
            i_rx = 1'b1; //stop
            $display("El dato B es: %b (%h)", data, $signed(data)); 
            
            //--------------------Operacion-------------------------------------
            #90000
            data = {2'b00, AND};
            i_rx = 1'b0; //start 
            for(j = 0; j < N_BITS; j = j + 1)
            begin
                #52160
                i_rx = data[j];
            end
            #52160
            i_rx = 1'b1; //stop
            #90000
            $display("La operacion es: %b (%h)", data, data);
                
        end
    end
    #1000
    $finish;
    end // initial

top
#(
    .LIMITE         (LIMITE),       //limite de cuenta del baudrate
    .NB_CONTA       (NB_CONTA),     //cant de bits del contador del baudrate
    .N_BITS         (N_BITS),       //cant de bits de datos
    .N_TICKS        (N_TICKS)       //cant de ticks para llegar al ancho de un bit
)
u_top
(
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .i_rx           (i_rx),
    .o_tx_done_tick (o_tx_done_tick),
    .o_tx           (o_tx)
);

always #10 i_clock = ~i_clock; //50 MHz


endmodule //tb_top
