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
