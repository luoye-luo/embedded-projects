`timescale 1ns/1ps
module TX_tb ();

    reg sys_clk;
    reg sys_rst_n;

//    reg [7:0] data_in;
//    reg start;

    wire data_tx;
    wire over;

initial begin
    sys_clk = 0;
    sys_rst_n = 0;
//    start = 0;
//    data_in = 8'b0000_0000;
    #200
    sys_rst_n = 1;
//    start = 1;
//    data_in = 8'b0001_1001;
//   #20
//    start = 0;
end

always #10 sys_clk = ~sys_clk;

TX TX_0 (

.sys_clk    (sys_clk),
.sys_rst_n  (sys_rst_n),

//.data_in  (data_in),
//.start    (start),

.data_tx    (data_tx),
.over       (over)
);


    
endmodule