module fifo#
(
    parameter NB_DATA = 8,
    parameter PTR_LEN = 4
)
(
    input wire i_clk,     
    input wire i_reset,
    input wire i_read_fifo,            
    input wire i_write_fifo,
    input wire [NB_DATA-1 : 0] i_data_to_write,
    output wire o_fifo_is_empty,
    output wire o_fifo_is_full,
    output wire [NB_DATA-1 : 0] o_data_to_read
);

//FIFO operations
localparam READ = 2'b01;
localparam WRITE = 2'b10;
localparam READWRITE = 2'b11;


//Signal declaration
reg [NB_DATA-1 : 0] array [(2**PTR_LEN)-1 : 0];
reg [PTR_LEN-1 : 0] write_ptr, write_ptr_next, write_ptr_ok;
reg [PTR_LEN-1 : 0] read_ptr, read_ptr_next, read_ptr_ok;

reg full;
reg full_next;
reg empty;
reg empty_next;

wire write_enable;

//Register file write operation
always @(posedge i_clk) begin
    if(write_enable) begin
        array[write_ptr] <= i_data_to_write;
    end
end

//Register file read operation
assign o_data_to_read = array[read_ptr];

//Write enable only when FIFO is not o_fifo_is_full
assign write_enable = i_write_fifo & ~full;

//Fifo control logic
//Register for read and write pointers
always @(posedge i_clk) begin
    if(i_reset) begin
        write_ptr <= 0;
        read_ptr <= 0;
        full <= 0;
        empty <= 1;
    end
    else begin
        write_ptr <= write_ptr_next;
        read_ptr <= read_ptr_next;
        full <= full_next;
        empty <= empty_next;
    end
end

//Next-state logic for read and write pointers
always @(*) begin
    //Successive pointer values
    write_ptr_ok = write_ptr + 1;
    read_ptr_ok = read_ptr + 1; 
    //Default: keep old values
    write_ptr_next = write_ptr;
    read_ptr_next = read_ptr;
    full_next = full;
    empty_next = empty;

    case ({i_write_fifo, i_read_fifo})
        READ:
            if (~empty) begin
                read_ptr_next = read_ptr_ok;   //desplazar puntero
                full_next = 1'b0;
                if (read_ptr_ok==write_ptr) begin //fifo esta vacia
                    empty_next = 1'b1;
                end
            end
        WRITE:
            if (~full) begin
                write_ptr_next = write_ptr_ok;
                empty_next = 1'b0;
                if (write_ptr_ok==read_ptr) begin //fifo esta llena
                    full_next = 1'b1;
                end
            end
        READWRITE:
            begin
                write_ptr_next = write_ptr_ok;
                read_ptr_next = read_ptr_ok; 
            end 
        default:
            begin
                write_ptr_next = write_ptr_next;
                read_ptr_next = read_ptr_next;
            end

    endcase
end

//Output
assign o_fifo_is_full = full;
assign o_fifo_is_empty = empty;

endmodule
