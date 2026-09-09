module adder4 (
    input  [3:0] a,
    input  [3:0] b,
    input        sub,
    output [3:0] s,
    output       cout
);

    wire b0_real, b1_real, b2_real, b3_real; 
    wire c1, c2, c3;                          

    xor (b0_real, b[0], sub);
    xor (b1_real, b[1], sub);
    xor (b2_real, b[2], sub);
    xor (b3_real, b[3], sub);

    full_adder fa0 (.a(a[0]), .b(b0_real), .cin(sub), .s(s[0]), .cout(c1));
    full_adder fa1 (.a(a[1]), .b(b1_real), .cin(c1),  .s(s[1]), .cout(c2));
    full_adder fa2 (.a(a[2]), .b(b2_real), .cin(c2),  .s(s[2]), .cout(c3));
    full_adder fa3 (.a(a[3]), .b(b3_real), .cin(c3),  .s(s[3]), .cout(cout));

endmodule
