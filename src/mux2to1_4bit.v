// mux2to1_4bit.v
// Mux 2:1 de 4 bits. Si sel=0 pasa d0, si sel=1 pasa d1.
// Ecuacion de un mux 2:1 normal: y = (sel' and d0) or (sel and d1)
// Se repite la misma logica para cada uno de los 4 bits.

module mux2to1_4bit (
    input  [3:0] d0,
    input  [3:0] d1,
    input        sel,
    output [3:0] y
);

    wire sel_n;
    not (sel_n, sel);

    wire p0_0, p1_0;
    and (p0_0, d0[0], sel_n);
    and (p1_0, d1[0], sel);
    or  (y[0], p0_0, p1_0);

    wire p0_1, p1_1;
    and (p0_1, d0[1], sel_n);
    and (p1_1, d1[1], sel);
    or  (y[1], p0_1, p1_1);

    wire p0_2, p1_2;
    and (p0_2, d0[2], sel_n);
    and (p1_2, d1[2], sel);
    or  (y[2], p0_2, p1_2);

    wire p0_3, p1_3;
    and (p0_3, d0[3], sel_n);
    and (p1_3, d1[3], sel);
    or  (y[3], p0_3, p1_3);

endmodule
