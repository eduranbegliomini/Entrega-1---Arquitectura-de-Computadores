// mux8to1_4bit.v
// Mux 8:1 de 4 bits, para elegir la salida de la ALU segun el selector
// de operacion (codigo). in0 corresponde a codigo=000, in1 a codigo=001,
// ..., in7 a codigo=111.
//
// En vez de armar la tabla de verdad completa de 4 bits x 8 entradas (son
// hartas filas), lo armamos como arbol de muxes 2:1: primero se elige con
// el bit menos significativo del selector, despues con el del medio, y al
// final con el mas significativo. Es logicamente equivalente a la suma de
// productos pero mas facil de armar y de revisar.

module mux8to1_4bit (
    input  [3:0] in0,
    input  [3:0] in1,
    input  [3:0] in2,
    input  [3:0] in3,
    input  [3:0] in4,
    input  [3:0] in5,
    input  [3:0] in6,
    input  [3:0] in7,
    input  [2:0] sel,
    output [3:0] y
);

    // primer nivel: elegimos entre pares consecutivos con sel[0]
    wire [3:0] m0, m1, m2, m3;
    mux2to1_4bit mux_a (.d0(in0), .d1(in1), .sel(sel[0]), .y(m0));
    mux2to1_4bit mux_b (.d0(in2), .d1(in3), .sel(sel[0]), .y(m1));
    mux2to1_4bit mux_c (.d0(in4), .d1(in5), .sel(sel[0]), .y(m2));
    mux2to1_4bit mux_d (.d0(in6), .d1(in7), .sel(sel[0]), .y(m3));

    // segundo nivel: con sel[1]
    wire [3:0] n0, n1;
    mux2to1_4bit mux_e (.d0(m0), .d1(m1), .sel(sel[1]), .y(n0));
    mux2to1_4bit mux_f (.d0(m2), .d1(m3), .sel(sel[1]), .y(n1));

    // tercer nivel: con sel[2], el mas significativo
    mux2to1_4bit mux_g (.d0(n0), .d1(n1), .sel(sel[2]), .y(y));

endmodule
