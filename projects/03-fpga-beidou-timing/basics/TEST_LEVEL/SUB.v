//子模块二  减法模块

module      SUB(
     input   wire      [8:0]SUB_in0 ,
     input   wire      [8:0]SUB_in1 ,
     output  wire      [9:0]SUB_out


);

assign     SUB_out = SUB_in0 - SUB_in1 ;

endmodule