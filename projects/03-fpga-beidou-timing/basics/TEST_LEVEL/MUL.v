//子模块三  乘法模块

module      MUL(
     input     wire     [9:0]MUL_in0 ,
     input     wire     [9:0]MUL_in1 ,
     output    wire     [19:0]MUL_out


);

assign     MUL_out = MUL_in0 * MUL_in1 ;

endmodule