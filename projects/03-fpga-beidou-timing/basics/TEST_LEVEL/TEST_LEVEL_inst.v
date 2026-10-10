//顶层模块

module     TEST_LEVEL_inst(
    input       wire    [8:0] A ,
    input       wire    [8:0] B ,
    input       wire    [8:0] C ,
    input       wire    [8:0] D ,
 
    output      wire    [19:0]P
);
//内部中间变量需先声明，再调用
    wire        [9:0]ADD_out ;
	wire        [9:0]SUB_out ;
	wire         [19:0]MUL_out ;
	
//子模块调用
//模块名    实例化名
   ADD       ADD_inst(
 .ADD_in0    (A),
 .ADD_in1    (B),
 .ADD_out    (ADD_out)
   );
   SUB       SUB_inst(
 .SUB_in0    (C),
 .SUB_in1    (D),
 .SUB_out    (SUB_out)
   );
   MUL       MUL_inst(
 .MUL_in0    (ADD_out),
 .MUL_in1    (SUB_out),
 .MUL_out    (P)
   );
endmodule