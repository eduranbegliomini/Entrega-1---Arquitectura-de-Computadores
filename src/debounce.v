module debounce #(
    parameter LIMIT = 500000
)(
    input  clk,
    input  boton_crudo,
    output reg pulso
);

    localparam ANCHO = $clog2(LIMIT + 1);

    reg [ANCHO-1:0] contador;
    reg estable;
    reg estable_anterior;

    initial begin
        contador = 0;
        estable = 1;          
        estable_anterior = 1;
        pulso = 0;
    end

    always @(posedge clk) begin
        if (boton_crudo == estable) begin
            contador <= 0;
        end else begin
            contador <= contador + 1'b1;
            if (contador == LIMIT - 1) begin
                estable <= boton_crudo;
                contador <= 0;
            end
        end

        estable_anterior <= estable;
        pulso <= (~estable) & estable_anterior; 
    end

endmodule
