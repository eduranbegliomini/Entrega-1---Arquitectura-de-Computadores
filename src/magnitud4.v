module magnitud4 (
    input  [3:0] valor, // numero en complemento a 2
    output [3:0] mag,   // magnitud (0 a 8, sin signo)
    output       signo  // 1 = negativo, 0 = positivo o cero
);

    buf (signo, valor[3]);

    adder4 negador (
        .a    (4'b0000),
        .b    (valor),
        .sub  (signo),
        .s    (mag),
        .cout ()
    );

endmodule
