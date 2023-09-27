`timescale 1ns / 1ps

module alu 
#(
    //PARAMETROS
    parameter           N_BITS_DATA = 8,
    parameter           N_BITS_OP = 6  
)
(
    //INPUTS
    input wire signed [N_BITS_DATA-1 : 0]  i_dato_A,
    input wire signed [N_BITS_DATA-1 : 0]  i_dato_B,
    input wire [N_BITS_OP-1 : 0]    i_operacion,
    //OUTPUTS
    output wire signed [N_BITS_DATA-1 : 0] o_resultado
);

//codigos de operaciones disponibles
localparam  ADD = 6'b100000;
localparam  SUB = 6'b100010;
localparam  AND = 6'b100100;
localparam  OR  = 6'b100101;
localparam  XOR = 6'b100110;
localparam  SRA = 6'b000011;
localparam  SRL = 6'b000010;
localparam  NOR = 6'b100111;

reg [N_BITS_DATA-1 : 0] result;
assign o_resultado = result;

always @(*)
begin
    case (i_operacion)
        ADD : result = i_dato_A + i_dato_B;    //ADD
        SUB : result = i_dato_A - i_dato_B;    //SUB
        AND : result = i_dato_A & i_dato_B;    //AND
        OR  : result = i_dato_A | i_dato_B;    //OR
        XOR : result = i_dato_A ^ i_dato_B;    //XOR
        SRA : result = i_dato_A >>> i_dato_B;  //SRA
        SRL : result = i_dato_A >> i_dato_B;   //SRL
        NOR : result = ~(i_dato_A | i_dato_B); //NOR
    default: result = {N_BITS_DATA {1'b0}}; //codigo de operacion invalido -> salida = 0
    endcase
end

endmodule //alu