`timescale 1ns / 1ps
/*
    Modulo Interfaz: es una maquina de estados que retiene los datos A, B y el 
    codigo de operacion para que la ALU calcule el resultado.
    Consiste de 4 estados e instancia al modulo ALU.
    La secuencia de datos es la siguiente: 
        1) esperar dato A
        2) esperar dato B
        3) esperar opCode
        4) enviar resultado
    Cuando se haya completado el calculo, el modulo interfaz pondra la señal de 
    valid en 1.
*/

module interfaz
#(
    parameter NB_DATA = 8
)
(
    input   wire    i_clock,
    input   wire    i_reset,
    input   wire    i_valid,
    input   wire [NB_DATA-1 : 0]  i_dato,
    output  wire [NB_DATA-1 : 0] o_result,
    output  wire    o_valid
);

localparam WAIT_OP_A        = 4'b0001;
localparam WAIT_OP_B        = 4'b0010;
localparam WAIT_OPCODE    = 4'b0100;
localparam SEND_RESULT    = 4'b1000;
localparam NB_OP = 6;

reg [3:0] state = WAIT_OP_A ;
reg [3:0] next_state = WAIT_OP_A;
reg [NB_DATA-1 : 0] dato_A;
reg [NB_DATA-1 : 0] dato_B;
reg [NB_OP-1 : 0] operacion;
reg [NB_DATA-1 : 0] dato_A_reg;
reg [NB_DATA-1 : 0] dato_B_reg;
reg [NB_OP-1 : 0] operacion_reg;
reg resultado_listo = 1'b0;

assign o_valid = resultado_listo;

always @(posedge i_clock) //State register
begin
    if(i_reset)
    begin
        state <= WAIT_OP_A;
        dato_A <= {NB_DATA {1'b0}};
        dato_B <= {NB_DATA {1'b0}};
        operacion <= {NB_OP {1'b0}};
    end
    else
    begin
        state <= next_state;
        dato_A <= dato_A_reg;
        dato_B <= dato_B_reg;
        operacion <= operacion_reg;
    end
end

always @(*) // Next-state logic
begin
    next_state = state;
    dato_A_reg = dato_A;
    dato_B_reg = dato_B;
    operacion_reg = operacion;
    
    case(state)
        WAIT_OP_A: 
        begin
        if(i_valid)
            begin
                next_state = WAIT_OP_B;
                dato_A_reg = i_dato;
            end
        end
        WAIT_OP_B:
        begin
        if(i_valid)
            begin
                next_state = WAIT_OPCODE;
                dato_B_reg = i_dato; 
            end           
        end
        WAIT_OPCODE:
        begin
        if(i_valid)
            begin
                next_state = SEND_RESULT;
                operacion_reg = i_dato[0 +: NB_OP];
            end
        end
        SEND_RESULT:
        begin
            next_state = WAIT_OP_A;       
        end
    default: 
    begin
        next_state = WAIT_OP_A; // Fault Recovery -> vuelve al estado inicial
        dato_A_reg = {NB_DATA {1'b0}};
        dato_B_reg = {NB_DATA {1'b0}};
        operacion_reg = {NB_OP {1'b0}};          
    end
endcase
end

always @(posedge i_clock)
begin
    case(state)
        WAIT_OP_A: resultado_listo <= 1'b0;
        WAIT_OP_B: resultado_listo <= 1'b0;
        WAIT_OPCODE: resultado_listo <= 1'b0;
        SEND_RESULT: resultado_listo <= 1'b1;
        default: resultado_listo <= 1'b0;
    endcase

end

//Instancia a la ALU
alu
#(
    .N_BITS_DATA    (NB_DATA),
    .N_BITS_OP      (NB_OP)
)
u_alu
(
    .i_dato_A       (dato_A),
    .i_dato_B       (dato_B),
    .i_operacion    (operacion),
    .o_resultado    (o_result)
);

endmodule //interfaz
