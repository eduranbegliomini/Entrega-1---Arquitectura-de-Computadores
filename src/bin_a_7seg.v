// bin_a_7seg.v
// Decodificador de un digito de 4 bits (0-F) a los 7 segmentos de un
// display, con compuertas. Segmentos activos en alto (1 = segmento
// prendido), que es como esta armada la tabla de digitos que usa
// Nandland para la Go Board.
//
// Para no armar 16 terminos por segmento, para cada segmento se fijo en
// cual de los dos grupos (los digitos que lo prenden o los que lo
// apagan) hay menos casos, y se arma con ese grupo mas chico usando un
// nor (osea: prendido en todos los digitos MENOS esos). Por ejemplo el
// segmento "a" esta apagado solo en los digitos 1, 4, 11 y 13, entonces
// es mas corto armar "a = NOR(esos 4 minterminos)" que sumar los otros 12.

module bin_a_7seg (
    input  [3:0] n, // n[3]n[2]n[1]n[0], el digito a mostrar
    output a, b, c, d, e, f, g
);

    wire n3n, n2n, n1n, n0n;
    not (n3n, n[3]);
    not (n2n, n[2]);
    not (n1n, n[1]);
    not (n0n, n[0]);

    // un minterm por cada valor de 0 a 15
    wire m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;

    and (m0,  n3n,   n2n,   n1n,   n0n);
    and (m1,  n3n,   n2n,   n1n,   n[0]);
    and (m2,  n3n,   n2n,   n[1],  n0n);
    and (m3,  n3n,   n2n,   n[1],  n[0]);
    and (m4,  n3n,   n[2],  n1n,   n0n);
    and (m5,  n3n,   n[2],  n1n,   n[0]);
    and (m6,  n3n,   n[2],  n[1],  n0n);
    and (m7,  n3n,   n[2],  n[1],  n[0]);
    and (m8,  n[3],  n2n,   n1n,   n0n);
    and (m9,  n[3],  n2n,   n1n,   n[0]);
    and (m10, n[3],  n2n,   n[1],  n0n);
    and (m11, n[3],  n2n,   n[1],  n[0]);
    and (m12, n[3],  n[2],  n1n,   n0n);
    and (m13, n[3],  n[2],  n1n,   n[0]);
    and (m14, n[3],  n[2],  n[1],  n0n);
    and (m15, n[3],  n[2],  n[1],  n[0]);

    // digitos donde CADA segmento esta apagado (sacados de la tabla de
    // Nandland para digitos hex 0-F)
    nor (a, m1, m4, m11, m13);
    nor (b, m5, m6, m11, m12, m14, m15);
    nor (c, m2, m12, m14, m15);
    nor (d, m1, m4, m7, m10, m15);
    nor (e, m1, m3, m4, m5, m7, m9);
    nor (f, m1, m2, m3, m7, m13);
    nor (g, m0, m1, m7, m12);

endmodule
