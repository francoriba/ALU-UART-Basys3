// //CLK_FREQ / (BAUD_RATE * 16);
//COUNTER_MOD = 326 for f = 100MHz and  Baudrate = 19200
//COUNTER_MOD = 651 for f = 100MHz and Baudrate = 9600

module baudrateGenerator#
(
    parameter NB_COUNTER = 5,       //Number of bits for counter
    parameter COUNTER_LIMIT = 20    //Limit for counter
)
(
    input wire i_clk,
    input wire i_reset,
    output wire o_tick_ovf
);

reg [NB_COUNTER-1 : 0] counter;
wire [NB_COUNTER-1 : 0] counter_next;

always @(posedge i_clk) begin
    if (i_reset) begin
        counter <= 0;
    end
    else begin
        counter <= counter_next;
    end
end

//Next-state control
assign counter_next = (counter == (COUNTER_LIMIT-1)) ? 0 : counter + 1;
assign o_tick_ovf = (counter == (COUNTER_LIMIT-1)) ? 1'b1 : 1'b0;

endmodule
