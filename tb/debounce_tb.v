`timescale 1ns/1ps

module debounce_tb;

    reg clk, boton;
    wire pulso;

    integer cuenta_pulsos;

    debounce #(.LIMIT(5)) dut (.clk(clk), .boton_crudo(boton), .pulso(pulso));

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (pulso) cuenta_pulsos = cuenta_pulsos + 1;
    end

    initial begin
        $dumpfile("sim/debounce_tb.vcd");
        $dumpvars(0, debounce_tb);

        boton = 1; // suelto
        cuenta_pulsos = 0;
        repeat (10) @(posedge clk);

        boton = 0; repeat (2) @(posedge clk);
        boton = 1; repeat (10) @(posedge clk);

        if (cuenta_pulsos != 0)
            $display("FALLO: un rebote corto no deberia generar pulso (iban %0d)", cuenta_pulsos);
        else
            $display("OK: rebote corto ignorado, pulsos=%0d", cuenta_pulsos);

        boton = 0; @(posedge clk);
        boton = 1; @(posedge clk);
        boton = 0; repeat (8) @(posedge clk); 

        if (cuenta_pulsos != 1)
            $display("FALLO: deberia haber exactamente 1 pulso, hubo %0d", cuenta_pulsos);
        else
            $display("OK: presionada real genero 1 pulso");

        boton = 1; repeat (10) @(posedge clk);
        if (cuenta_pulsos != 1)
            $display("FALLO: al soltar no deberia sumar otro pulso, van %0d", cuenta_pulsos);
        else
            $display("OK: al soltar no genero pulso nuevo");

        $display("debounce_tb: fin de la simulacion");
        $finish;
    end

endmodule
