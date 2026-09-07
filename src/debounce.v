// debounce.v
// Filtra los rebotes de un boton fisico y avisa con un pulso de 1 ciclo
// de clk cada vez que se detecta una presionada nueva (ya estable).
//
// Asumimos boton activo en bajo (como es comun en estas placas): 1 =
// suelto, 0 = presionado. Si en la Go Board resulta ser al reves, basta
// con invertir la entrada al instanciar este modulo.
//
// LIMIT son los ciclos de clk que el boton tiene que mantenerse quieto
// antes de darlo por valido. Con el clk de 25MHz de la Go Board y
// LIMIT=500000 son unos 20ms, que es lo tipico para debounce. Se deja
// como parametro para poder simular rapido con un LIMIT chico.

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
        estable = 1;          // arrancamos asumiendo boton suelto
        estable_anterior = 1;
        pulso = 0;
    end

    always @(posedge clk) begin
        if (boton_crudo == estable) begin
            // no hay nada nuevo, seguimos como estabamos
            contador <= 0;
        end else begin
            // el boton se esta moviendo, contamos cuanto se mantiene asi
            contador <= contador + 1'b1;
            if (contador == LIMIT - 1) begin
                estable <= boton_crudo;
                contador <= 0;
            end
        end

        estable_anterior <= estable;
        pulso <= (~estable) & estable_anterior; // recien paso a "presionado"
    end

endmodule
