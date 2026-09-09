module calculadora_4bits (
    input        clk,
    input        ejecutar,
    input  [2:0] codigo,
    input        sel_op2,
    input  [3:0] op1,
    input  [3:0] op2_ext,
    output [3:0] resultado,
    output       overflow   
);

    wire [3:0] op2;
    mux2to1_4bit mux_entrada (
        .d0  (op2_ext),
        .d1  (resultado),
        .sel (sel_op2),
        .y   (op2)
    );

    wire [3:0] r_suma, r_resta, r_resta_inv, r_shl, r_shr;

    wire c_suma, c_resta, c_resta_inv;

    adder4 sumador      (.a(op1), .b(op2), .sub(1'b0), .s(r_suma),      .cout(c_suma));
    adder4 restador     (.a(op1), .b(op2), .sub(1'b1), .s(r_resta),     .cout(c_resta));
    adder4 restador_inv (.a(op2), .b(op1), .sub(1'b1), .s(r_resta_inv), .cout(c_resta_inv));

    shifter4 shift_izq (.a(op1), .b1(op2[1]), .b0(op2[0]), .dir(1'b0), .r(r_shl));
    shifter4 shift_der (.a(op1), .b1(op2[1]), .b0(op2[0]), .dir(1'b1), .r(r_shr));

    wire [3:0] alu_out;
    mux8to1_4bit selector_salida (
        .in0 (4'b0000),     
        .in1 (r_suma),
        .in2 (r_resta),
        .in3 (r_resta_inv),
        .in4 (r_shl),
        .in5 (r_shr),
        .in6 (4'b0000),      
        .in7 (4'b0000),      
        .sel (codigo),
        .y   (alu_out)
    );

    reg4 registro (
        .clk      (clk),
        .ejecutar (ejecutar),
        .d        (alu_out),
        .q        (resultado)
    );

    buf (overflow, c_suma);

endmodule
