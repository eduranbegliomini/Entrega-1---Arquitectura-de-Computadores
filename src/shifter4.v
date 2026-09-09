module shifter4 (
    input  [3:0] a,
    input        b1,
    input        b0,
    input        dir,
    output [3:0] r
);

    wire b1n, b0n;
    not (b1n, b1);
    not (b0n, b0);

    // ---------- shift left ----------

    wire [3:0] shl;

    wire l0_t0;
    and (l0_t0, b1n, b0n, a[0]);
    or  (shl[0], l0_t0);

    wire l1_t0, l1_t1;
    and (l1_t0, b1n, b0n, a[1]);
    and (l1_t1, b1n, b0,  a[0]);
    or  (shl[1], l1_t0, l1_t1);

    wire l2_t0, l2_t1, l2_t2;
    and (l2_t0, b1n, b0n, a[2]);
    and (l2_t1, b1n, b0,  a[1]);
    and (l2_t2, b1,  b0n, a[0]);
    or  (shl[2], l2_t0, l2_t1, l2_t2);

    wire l3_t0, l3_t1, l3_t2, l3_t3;
    and (l3_t0, b1n, b0n, a[3]);
    and (l3_t1, b1n, b0,  a[2]);
    and (l3_t2, b1,  b0n, a[1]);
    and (l3_t3, b1,  b0,  a[0]);
    or  (shl[3], l3_t0, l3_t1, l3_t2, l3_t3);

    // ---------- shift right (espejo del left) ----------

    wire [3:0] shr;

    wire r3_t0;
    and (r3_t0, b1n, b0n, a[3]);
    or  (shr[3], r3_t0);

    wire r2_t0, r2_t1;
    and (r2_t0, b1n, b0n, a[2]);
    and (r2_t1, b1n, b0,  a[3]);
    or  (shr[2], r2_t0, r2_t1);

    wire r1_t0, r1_t1, r1_t2;
    and (r1_t0, b1n, b0n, a[1]);
    and (r1_t1, b1n, b0,  a[2]);
    and (r1_t2, b1,  b0n, a[3]);
    or  (shr[1], r1_t0, r1_t1, r1_t2);

    wire r0_t0, r0_t1, r0_t2, r0_t3;
    and (r0_t0, b1n, b0n, a[0]);
    and (r0_t1, b1n, b0,  a[1]);
    and (r0_t2, b1,  b0n, a[2]);
    and (r0_t3, b1,  b0,  a[3]);
    or  (shr[0], r0_t0, r0_t1, r0_t2, r0_t3);

    // ---------- eleccion final segun direccion ----------
    mux2to1_4bit mux_dir (.d0(shl), .d1(shr), .sel(dir), .y(r));

endmodule
