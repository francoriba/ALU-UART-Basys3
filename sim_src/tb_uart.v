`timescale 1ns / 1ps
//Testbench del modulo uart (baudrate, Tx y Rx)

module tb_uart();

    //localparameters
    localparam LIMITE = 163;     
    localparam NB_CONTA = 8;     
    localparam N_BITS = 8;   //bits de datos   
    localparam N_TICKS = 16;   
    localparam MASK = 8'b00001111;
    
    //Tb signals
    reg                 test_start;
    reg [N_BITS-1:0]    dato;
    integer             i;
    
    //INPUTS
    reg                 i_clk;
    reg                 i_reset;
    reg                 i_rx;
    reg                 i_ready;
    reg [N_BITS-1:0]    i_din;
        
    //OUTPUTS
    wire                o_tx;
    wire                o_tx_done_tick;
    wire                o_rx_done_tick;
    wire [N_BITS-1:0]   o_dout;

    initial begin
    #0
    i_clk = 1'b0;
    test_start = 1'b0;
    i_reset = 1'b1;
    i_rx = 1'b1;
    i_ready = 1'b0;
    i_din = {N_BITS {1'b0}};
    dato = {N_BITS {1'b0}};
    i = {32 {1'b0}};
    
    #60
    i_reset = 1'b0;

    #40
    test_start = 1'b1; //a los 100 arranca el test
    
    if(test_start)
    begin
        i_rx = 1'b0; //bit START
        #52160
        
        //bits de DATOS
        i_rx = 1'b1; //LSB
        #52160
        i_rx = 1'b0;
        #52160
        i_rx = 1'b1;
        #52160
        i_rx = 1'b0;
        #52160
        i_rx = 1'b1;
        #52160
        i_rx = 1'b0;
        #52160
        i_rx = 1'b1;
        #52160
        i_rx = 1'b0; //MSB
        #52160
      
        i_rx = 1'b1; //bit STOP
        #52160
 
        i_din = dato;
        i_ready = 1'b1;
        #521500
        i_ready = 1'b0;
        
        
    end
    #100000
    $finish;
    end // initial

uart
#(
    .LIMITE         (LIMITE),     
    .NB_CONTA       (NB_CONTA),     
    .N_BITS         (N_BITS),      
    .N_TICKS        (N_TICKS)      
)
u_uart
(
    .i_clock        (i_clk),
    .i_reset        (i_reset),
    .i_rx           (i_rx),
    .i_ready        (i_ready),
    .i_din          (i_din),
    .o_rx_done_tick (o_rx_done_tick),
    .o_dout         (o_dout),
    .o_tx_done_tick (o_tx_done_tick),
    .o_tx           (o_tx)
);

    always #10 i_clk = ~i_clk; //50MHz
 
    always @(*)
    begin
        if(o_rx_done_tick)
        begin
            dato = o_dout;
            #10000
            dato = dato & MASK; //se realiza operacion con el dato
        end
    end

endmodule //tb_uart
