module signo_7seg (
    input  signo,
    output a, b, c, d, e, f, g
);

    buf (a, 1'b0);
    buf (b, 1'b0);
    buf (c, 1'b0);
    buf (d, 1'b0);
    buf (e, 1'b0);
    buf (f, 1'b0);
    buf (g, signo);

endmodule
