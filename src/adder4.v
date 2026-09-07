// adder4.v
// Sumador/restador de 4 bits, hecho encadenando 4 full_adder (ripple carry).
//
// La entrada "sub" sirve para hacer resta reusando el mismo sumador:
// si sub=0 se suma normal (b tal cual, cin=0).
// si sub=1 se invierte b bit a bit (xor con 1) y se mete un 1 por cin,
// que es el truco de complemento a 2: a - b = a + (not b) + 1
//
// Para hacer B - A en vez de A - B, no hace falta otra logica: en el
// modulo de arriba (calculadora_4bits) simplemente se conectan las
// entradas al reves (a=b, b=a) con sub=1.

module adder4 (
    input  [3:0] a,
    input  [3:0] b,
    input        sub,
    output [3:0] s,
    output       cout
);

    wire b0_real, b1_real, b2_real, b3_real; // b ya invertido si corresponde
    wire c1, c2, c3;                          // carries entre etapas

    xor (b0_real, b[0], sub);
    xor (b1_real, b[1], sub);
    xor (b2_real, b[2], sub);
    xor (b3_real, b[3], sub);

    // el cin de la primera etapa es "sub" directo: si estamos restando
    // necesitamos sumar 1 extra (complemento a 2), si no, parte en 0
    full_adder fa0 (.a(a[0]), .b(b0_real), .cin(sub), .s(s[0]), .cout(c1));
    full_adder fa1 (.a(a[1]), .b(b1_real), .cin(c1),  .s(s[1]), .cout(c2));
    full_adder fa2 (.a(a[2]), .b(b2_real), .cin(c2),  .s(s[2]), .cout(c3));
    full_adder fa3 (.a(a[3]), .b(b3_real), .cin(c3),  .s(s[3]), .cout(cout));

endmodule
