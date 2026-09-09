`timescale 1ns/1ps

module contador_ud_tb;

    reg clk, inc, dec;
    wire [3:0] valor;

    contador_ud #(.ANCHO(4)) dut (.clk(clk), .inc_pulso(inc), .dec_pulso(dec), .valor(valor));

    initial clk = 0;
    always #5 clk = ~clk;

    task pulso_inc;
        begin
            inc = 1; @(posedge clk); #1; inc = 0; @(negedge clk);
        end
    endtask

    task pulso_dec;
        begin
            dec = 1; @(posedge clk); #1; dec = 0; @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("sim/contador_ud_tb.vcd");
        $dumpvars(0, contador_ud_tb);

        inc = 0; dec = 0;

        pulso_inc; 
        if (valor !== 4'd1) $display("FALLO: esperaba 1, valor=%d", valor);
        else $display("OK: incremento -> valor=%d", valor);

        pulso_inc; pulso_inc; 
        if (valor !== 4'd3) $display("FALLO: esperaba 3, valor=%d", valor);
        else $display("OK: incrementos -> valor=%d", valor);

        pulso_dec; 
        if (valor !== 4'd2) $display("FALLO: esperaba 2, valor=%d", valor);
        else $display("OK: decremento -> valor=%d", valor);

        pulso_dec; pulso_dec; 
        if (valor !== 4'd0) $display("FALLO: esperaba 0, valor=%d", valor);
        pulso_dec; 
        if (valor !== 4'd15) $display("FALLO: esperaba 15 (wraparound), valor=%d", valor);
        else $display("OK: wraparound bajando -> valor=%d", valor);

        pulso_inc;
        if (valor !== 4'd0) $display("FALLO: esperaba 0 (wraparound), valor=%d", valor);
        else $display("OK: wraparound subiendo -> valor=%d", valor);

        $display("contador_ud_tb: fin de la simulacion");
        $finish;
    end

endmodule
