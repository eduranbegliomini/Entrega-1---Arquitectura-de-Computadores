`timescale 1ns/1ps

module mux2to1_4bit_tb;

    reg  [3:0] d0, d1;
    reg        sel;
    wire [3:0] y;

    mux2to1_4bit dut (.d0(d0), .d1(d1), .sel(sel), .y(y));

    initial begin
        $dumpfile("sim/mux2to1_4bit_tb.vcd");
        $dumpvars(0, mux2to1_4bit_tb);

        d0 = 4'b1010; d1 = 4'b0101;

        sel = 0; #10;
        if (y !== d0) $display("FALLO: sel=0 deberia dar d0=%b, dio %b", d0, y);
        else $display("OK: sel=0 -> y=%b", y);

        sel = 1; #10;
        if (y !== d1) $display("FALLO: sel=1 deberia dar d1=%b, dio %b", d1, y);
        else $display("OK: sel=1 -> y=%b", y);

        d0 = 4'b1111; d1 = 4'b0000;
        sel = 0; #10;
        if (y !== d0) $display("FALLO: sel=0 deberia dar d0=%b, dio %b", d0, y);
        else $display("OK: sel=0 -> y=%b", y);

        sel = 1; #10;
        if (y !== d1) $display("FALLO: sel=1 deberia dar d1=%b, dio %b", d1, y);
        else $display("OK: sel=1 -> y=%b", y);

        $display("mux2to1_4bit_tb: fin de la simulacion");
        $finish;
    end

endmodule
