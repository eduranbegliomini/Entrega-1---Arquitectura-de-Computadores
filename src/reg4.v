// reg4.v
// Registro de 4 bits con flip-flops tipo D. Guarda un valor nuevo solo
// cuando "ejecutar" esta en 1 al momento del flanco de subida de clk.
//
// Para no meter un if adentro del always (la idea es depender lo menos
// posible de logica de alto nivel), usamos un mux2to1 antes del flip-flop:
// si ejecutar=0 el mux vuelve a meter el valor que ya estaba guardado (q),
// asi el flip-flop "no cambia" aunque el clk siga andando. Si ejecutar=1
// entra el valor nuevo (d).

module reg4 (
    input        clk,
    input        ejecutar,
    input  [3:0] d,
    output reg [3:0] q
);

    wire [3:0] d_real;

    mux2to1_4bit mux_carga (.d0(q), .d1(d), .sel(ejecutar), .y(d_real));

    always @(posedge clk) begin
        q <= d_real;
    end

endmodule
