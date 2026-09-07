// full_adder.v
// Sumador completo de 1 bit, hecho solo con compuertas primitivas.
// Ecuaciones (de la tabla de verdad / Karnaugh del informe):
//   Si   = Ai xor Bi xor Cin
//   Cout = (Ai and Bi) or (Cin and (Ai xor Bi))

module full_adder (
    input  a,
    input  b,
    input  cin,
    output s,
    output cout
);

    wire a_xor_b;   // Ai xor Bi, se usa dos veces (para Si y para Cout)
    wire and1;      // Ai and Bi
    wire and2;      // Cin and (Ai xor Bi)

    xor (a_xor_b, a, b);
    xor (s, a_xor_b, cin);

    and (and1, a, b);
    and (and2, cin, a_xor_b);
    or  (cout, and1, and2);

endmodule
