`timescale 1ns/1ps

module reg4_tb;

    reg        clk, ejecutar;
    reg  [3:0] d;
    wire [3:0] q;

    reg4 dut (.clk(clk), .ejecutar(ejecutar), .d(d), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/reg4_tb.vcd");
        $dumpvars(0, reg4_tb);

        ejecutar = 1; d = 4'b1010;
        @(posedge clk); #1;
        if (q !== 4'b1010) $display("FALLO: deberia haber cargado 1010, q=%b", q);
        else $display("OK: cargo 1010 -> q=%b", q);

        ejecutar = 0; d = 4'b0101;
        @(posedge clk); #1;
        if (q !== 4'b1010) $display("FALLO: con ejecutar=0 no deberia cambiar, q=%b", q);
        else $display("OK: con ejecutar=0 se mantuvo q=%b", q);

        @(posedge clk); #1;
        if (q !== 4'b1010) $display("FALLO: deberia seguir en 1010, q=%b", q);
        else $display("OK: sigue en q=%b", q);

        ejecutar = 1;
        @(posedge clk); #1;
        if (q !== 4'b0101) $display("FALLO: deberia haber cargado 0101, q=%b", q);
        else $display("OK: cargo 0101 -> q=%b", q);

        $display("reg4_tb: fin de la simulacion");
        $finish;
    end

endmodule
