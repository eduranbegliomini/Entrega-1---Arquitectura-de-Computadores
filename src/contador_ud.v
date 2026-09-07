// contador_ud.v
// Contador arriba/abajo genérico, de ANCHO bits, con vuelta ciclica
// (wraparound): si esta en el maximo y sube, vuelve a 0; si esta en 0 y
// baja, vuelve al maximo. Eso sale solo, sin logica extra, porque el
// registro tiene un ancho fijo y el overflow se trunca.
//
// Se usa para ir cambiando el codigo de operacion y los operandos con
// los botones de subir/bajar.

module contador_ud #(
    parameter ANCHO = 4
)(
    input clk,
    input inc_pulso,
    input dec_pulso,
    output reg [ANCHO-1:0] valor
);

    initial valor = 0;

    always @(posedge clk) begin
        if (inc_pulso)
            valor <= valor + 1'b1;
        else if (dec_pulso)
            valor <= valor - 1'b1;
    end

endmodule
