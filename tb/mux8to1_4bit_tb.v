// mux8to1_4bit_tb.v
// Recorremos los 8 valores de sel (000 a 111) y chequeamos que salga
// la entrada correspondiente. A cada entrada le damos un valor distinto
// (0 a 7) para que sea facil ver si se mezclaron canales.

`timescale 1ns/1ps

module mux8to1_4bit_tb;

    reg  [3:0] in0, in1, in2, in3, in4, in5, in6, in7;
    reg  [2:0] sel;
    wire [3:0] y;

    integer i;
    reg [3:0] esperado;

    mux8to1_4bit dut (
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .in4(in4), .in5(in5), .in6(in6), .in7(in7),
        .sel(sel), .y(y)
    );

    initial begin
        $dumpfile("sim/mux8to1_4bit_tb.vcd");
        $dumpvars(0, mux8to1_4bit_tb);

        in0 = 4'd0; in1 = 4'd1; in2 = 4'd2; in3 = 4'd3;
        in4 = 4'd4; in5 = 4'd5; in6 = 4'd6; in7 = 4'd7;

        for (i = 0; i < 8; i = i + 1) begin
            sel = i[2:0];
            esperado = i[3:0];
            #10;
            if (y !== esperado)
                $display("FALLO: sel=%b -> y=%d (esperado %d)", sel, y, esperado);
            else
                $display("OK: sel=%b -> y=%d", sel, y);
        end

        $display("mux8to1_4bit_tb: fin de la simulacion");
        $finish;
    end

endmodule
