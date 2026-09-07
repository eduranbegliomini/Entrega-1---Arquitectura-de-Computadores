// calculadora_4bits.v
// Modulo top de la calculadora. Junta todos los bloques:
//   1) mux2to1_4bit para elegir el segundo operando (op2_ext o resultado anterior)
//   2) todos los bloques de la ALU calculando en paralelo (suma, resta,
//      resta inversa, shift izq, shift der)
//   3) mux8to1_4bit que elige cual de esos resultados sale segun "codigo"
//   4) reg4 que guarda el resultado en el flanco de subida si ejecutar=1
//
// codigo:
//   000 reinicio        -> resultado = 0000
//   001 suma             -> A + B
//   010 resta            -> A - B
//   011 resta inversa     -> B - A
//   100 shift left        -> A << B[1:0]
//   101 shift right       -> A >> B[1:0]
//   110, 111 reservados   -> se dejan en 0000, igual que reinicio
//
// no hay pin de reset aparte: "reinicio" es una operacion mas que viaja
// por el datapath (el mux8to1 saca 0000) y se guarda en el registro
// cuando se pulsa ejecutar, igual que cualquier otra operacion.

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

    // segundo operando real: sel_op2=0 -> op2_ext, sel_op2=1 -> resultado anterior
    wire [3:0] op2;
    mux2to1_4bit mux_entrada (
        .d0  (op2_ext),
        .d1  (resultado),
        .sel (sel_op2),
        .y   (op2)
    );

    // bloques de la ALU, todos calculando al mismo tiempo
    wire [3:0] r_suma, r_resta, r_resta_inv, r_shl, r_shr;

    wire c_suma, c_resta, c_resta_inv;

    adder4 sumador      (.a(op1), .b(op2), .sub(1'b0), .s(r_suma),      .cout(c_suma));
    adder4 restador     (.a(op1), .b(op2), .sub(1'b1), .s(r_resta),     .cout(c_resta));
    adder4 restador_inv (.a(op2), .b(op1), .sub(1'b1), .s(r_resta_inv), .cout(c_resta_inv));

    shifter4 shift_izq (.a(op1), .b1(op2[1]), .b0(op2[0]), .dir(1'b0), .r(r_shl));
    shifter4 shift_der (.a(op1), .b1(op2[1]), .b0(op2[0]), .dir(1'b1), .r(r_shr));

    // mux final: elige el resultado segun el codigo de operacion
    wire [3:0] alu_out;
    mux8to1_4bit selector_salida (
        .in0 (4'b0000),      // reinicio
        .in1 (r_suma),
        .in2 (r_resta),
        .in3 (r_resta_inv),
        .in4 (r_shl),
        .in5 (r_shr),
        .in6 (4'b0000),      // reservado
        .in7 (4'b0000),      // reservado
        .sel (codigo),
        .y   (alu_out)
    );

    // registro de resultado, se carga solo si ejecutar=1 en el flanco
    reg4 registro (
        .clk      (clk),
        .ejecutar (ejecutar),
        .d        (alu_out),
        .q        (resultado)
    );

    buf (overflow, c_suma);

endmodule
