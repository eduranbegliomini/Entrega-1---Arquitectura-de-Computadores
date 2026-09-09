module full_adder (
    input  a,
    input  b,
    input  cin,
    output s,
    output cout
);

    wire a_xor_b;   
    wire and1;      
    wire and2;      

    xor (a_xor_b, a, b);
    xor (s, a_xor_b, cin);

    and (and1, a, b);
    and (and2, cin, a_xor_b);
    or  (cout, and1, and2);

endmodule
