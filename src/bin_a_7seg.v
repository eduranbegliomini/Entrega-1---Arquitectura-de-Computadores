module bin_a_7seg (
    input  [3:0] n, 
    output a, b, c, d, e, f, g
);

    wire n3n, n2n, n1n, n0n;
    not (n3n, n[3]);
    not (n2n, n[2]);
    not (n1n, n[1]);
    not (n0n, n[0]);

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

    nor (a, m1, m4, m11, m13);
    nor (b, m5, m6, m11, m12, m14, m15);
    nor (c, m2, m12, m14, m15);
    nor (d, m1, m4, m7, m10, m15);
    nor (e, m1, m3, m4, m5, m7, m9);
    nor (f, m1, m2, m3, m7, m13);
    nor (g, m0, m1, m7, m12);

endmodule
