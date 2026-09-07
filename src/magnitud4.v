// magnitud4.v
// Convierte un numero de 4 bits en complemento a 2 a signo + magnitud,
// para mostrarlo en el display (un digito de signo y uno de magnitud en
// hexadecimal, como pide el enunciado).
//
// El truco es que no hace falta logica nueva: si el numero es negativo
// (bit mas significativo = 1), su magnitud es "negarlo" en complemento a
// 2, que es exactamente lo mismo que hace adder4 con sub=1 y A=0000:
// 0000 + NOT(valor) + 1 = -valor. Si es positivo, con sub=0 el mismo
// adder4 devuelve el valor tal cual (0000 + valor + 0 = valor).
// O sea reusamos el restador que ya teniamos.

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
