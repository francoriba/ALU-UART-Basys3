`timescale 1ns / 1ps


module test_interfaz();

    //local parameters
    localparam  NB_DATA = 8; 
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
    localparam  MAX = 10;
    
    //TB signals
    reg                         test_start;
    reg [N_BITS_OP * 10 -1:0]   codeOperacion;
    integer                     i;

    //INPUTS
    reg                         i_clock;
    reg                         i_reset;
    reg                         i_valid;
    reg [NB_DATA-1 : 0]         i_dato;
    
    //OUTPUTS
    wire [NB_DATA-1 : 0]         o_result;
    wire                         o_valid;

    initial begin
    #0
    i_clock = 1'b0;
    test_start = 1'b0;
    i_dato = {NB_DATA {1'b0}};
    i_valid = 1'b0;
    i_reset = 1'b1;
    
    codeOperacion = {ADD, SUB, AND, OR, XOR, SRA, SRL, NOR, NO_VALID1, NO_VALID2};
    
    #20
    i_reset = 1'b0;

    #80
    test_start = 1'b1;
    
    if(test_start)
    begin
        for(i = 0; i < MAX; i = i + 1)
        begin
            #40
            i_valid = 1'b1;
            i_dato = $urandom;  //dato A
            //i_dato = 8'b00000111; //7
            #20
            i_valid = 1'b0;
            #15
            $display("El dato A es: %b (%h)", i_dato, $signed(i_dato)); 
            
            i_valid = 1'b1;
            i_dato = $urandom % 20;  //dato B
            //i_dato = 8'b00000101; //5
            #20
            i_valid = 1'b0;
            #15
            $display("El dato B es: %b (%h)", i_dato, $signed(i_dato)); 
            
            i_valid = 1'b1;
            i_dato = (codeOperacion >> (($urandom%10) * N_BITS_OP)) & {{NB_DATA-N_BITS_OP {1'b0}}, {N_BITS_OP {1'b1}}}; //operacion
            //i_dato = ADD;
            #1
            $display("La operacion es: %b (%h)", i_dato, i_dato);
            #20
            i_valid = 1'b0;
         
          

        end
    end

    #1000
    $finish;
    end // initial
    
    interfaz
    #(
        .NB_DATA        (NB_DATA)
    )
    u_interfaz
    (
        .i_clock        (i_clock),
        .i_reset        (i_reset),
        .i_valid        (i_valid),
        .i_dato         (i_dato),
        .o_result       (o_result),
        .o_valid        (o_valid)
    );

    always #10 i_clock = ~i_clock;
    
    always @(*)
    begin
        if(o_valid)
        begin
            #2
            $display("El resultado es: %b (%h)", o_result, $signed(o_result));
            $display("----------------------------------------------------");
        end
    end


endmodule //test_interfaz
