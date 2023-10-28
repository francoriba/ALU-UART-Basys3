module interface#
(
    parameter NB_DATA = 8,
    parameter NB_OPCODE = 6     
)
(
    input wire i_clk,
    input wire i_reset,
    input wire [NB_DATA-1:0] i_alu_result,
    input wire [NB_DATA-1:0] i_data_to_read,
    input wire i_fifo_rx_empty,
    input wire i_fifo_tx_full,

    output wire o_fifo_rx_read,
    output wire o_fifo_tx_write,
    output wire [NB_DATA-1:0] o_data_to_write,
    output wire [NB_OPCODE-1:0] o_alu_opcode,
    output wire [NB_DATA-1:0] o_alu_op_A,
    output wire [NB_DATA-1:0] o_alu_op_B,
    output wire o_is_valid
);

//STM Interface
localparam [3:0] IDLE = 4'b0000;
localparam [3:0] OPCODE = 4'b0001;
localparam [3:0] OPERAND_A = 4'b0010;
localparam [3:0] OPERAND_B = 4'b0011;
localparam [3:0] CRC = 4'b0100;
localparam [3:0] CRC_CHECK= 4'b0101;
localparam [3:0] RESULT = 4'b0110;
localparam [3:0] CRC_RESULT = 4'b0111;
localparam [3:0] WAIT = 4'b1000;


reg [3:0] state, state_next;
reg fifo_rx_read, fifo_rx_read_next;
reg fifo_tx_write, fifo_tx_write_next;

reg [NB_OPCODE-1:0] opcode_sel, opcode_sel_next;
reg [NB_DATA-1:0] operand_a_sel, operand_a_sel_next;
reg [NB_DATA-1:0] operand_b_sel, operand_b_sel_next;
reg [NB_DATA-1:0] result, result_next;
reg [NB_DATA-1:0] crc_reg, crc_next;
reg [3:0] wait_reg, wait_next;

wire [NB_DATA-1:0] crc;


always @(posedge i_clk) begin
    if(i_reset) begin
        state <= IDLE;
        fifo_rx_read <= 1'b0;
        fifo_tx_write <= 1'b0;
        opcode_sel <= {NB_OPCODE{1'b0}};
        operand_a_sel <= {NB_DATA{1'b0}};
        operand_b_sel <= {NB_DATA{1'b0}};
        result <= {NB_DATA{1'b0}};
        crc_reg <= {NB_DATA{1'b0}};
        wait_reg <= 4'b0000;
    end
    else begin
        state <= state_next;
        fifo_rx_read <= fifo_rx_read_next;
        fifo_tx_write <= fifo_tx_write_next;
        opcode_sel <= opcode_sel_next;
        operand_a_sel <= operand_a_sel_next;
        operand_b_sel <= operand_b_sel_next;
        result <= result_next;
        crc_reg <= crc_next;
        wait_reg <= wait_next;
    end
end

always @(*) begin
    state_next = state;
    fifo_rx_read_next = fifo_rx_read;
    fifo_tx_write_next = fifo_tx_write;
    opcode_sel_next = opcode_sel;
    operand_a_sel_next = operand_a_sel;
    operand_b_sel_next = operand_b_sel;
    result_next = result;
    crc_next = crc;
    wait_next = wait_reg;

    case (state)
        IDLE: begin
            fifo_tx_write_next = 1'b0;    
            if(~i_fifo_rx_empty) begin
                state_next = OPCODE;
                fifo_rx_read_next = 1'b1;
            end
        end
        
        WAIT: begin
            if(~i_fifo_rx_empty) begin
                state_next = wait_reg;
                fifo_rx_read_next = 1'b1;
            end
        end
        
        OPCODE: begin
            if(i_fifo_rx_empty) begin
                fifo_rx_read_next = 1'b0;
                state_next = WAIT;
                wait_next = OPCODE;
            end
            else begin
                state_next = OPERAND_A;
                opcode_sel_next = i_data_to_read[NB_OPCODE-1:0];
                fifo_rx_read_next = 1'b1;
            end
        end 

        OPERAND_A: begin
            if(i_fifo_rx_empty) begin
                fifo_rx_read_next = 1'b0;
                state_next = WAIT;
                wait_next = OPERAND_A;
            end
            else begin
                state_next = OPERAND_B;
                operand_a_sel_next = i_data_to_read;
                fifo_rx_read_next = 1'b1;
            end
        end

        OPERAND_B: begin
            if(i_fifo_rx_empty) begin
                fifo_rx_read_next = 1'b0;
                state_next = WAIT;
                wait_next = OPERAND_B;
            end
            else begin
                state_next = CRC;
                operand_b_sel_next = i_data_to_read;
                fifo_rx_read_next = 1'b1;
            end
        end

        CRC: begin
            if(i_fifo_rx_empty) begin
                fifo_rx_read_next = 1'b0;
                state_next = WAIT;
                wait_next = CRC;
            end
            else begin
                state_next = CRC_CHECK;
                crc_next = i_data_to_read;
                fifo_rx_read_next = 1'b0;
            end
        end

        CRC_CHECK: begin
            fifo_rx_read_next = 1'b0;
            if(o_is_valid) begin
                state_next = RESULT;
            end
            else begin
                state_next = IDLE;
            end
        end

        RESULT: begin
            if(~i_fifo_tx_full) begin
                state_next = CRC_RESULT;
                result_next = i_alu_result;
                fifo_tx_write_next = 1'b1;
            end
        end

        CRC_RESULT: begin
            if(~i_fifo_tx_full) begin
                state_next = IDLE;
                result_next = result ^ 8'hff;
                fifo_tx_write_next = 1'b1;
            end
        end

        default: begin
            state_next = IDLE;
            fifo_rx_read_next = 1'b0;
            fifo_tx_write_next = 1'b0;
        end

    endcase
end

assign crc = opcode_sel ^ operand_a_sel ^ operand_b_sel ^ 8'hff;
assign o_is_valid = (crc == crc_reg) ? 1 : 0;
assign o_alu_op_A = operand_a_sel;
assign o_alu_op_B = operand_b_sel;
assign o_alu_opcode = opcode_sel;
assign o_data_to_write = result;
assign o_fifo_tx_write = fifo_tx_write;
assign o_fifo_rx_read = fifo_rx_read;


endmodule
