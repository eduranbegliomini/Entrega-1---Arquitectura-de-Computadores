`timescale 1ns/1ps

module shifter4_tb;

    reg  [3:0] a;
    reg        b1, b0, dir;
    wire [3:0] r;

    shifter4 dut (.a(a), .b1(b1), .b0(b0), .dir(dir), .r(r));

    task check(input [3:0] esperado);
        begin
            #10;
            if (r !== esperado)
                $display("FALLO: a=%b b1b0=%b%b dir=%b -> r=%b (esperado %b)", a, b1, b0, dir, r, esperado);
            else
                $display("OK: a=%b b1b0=%b%b dir=%b -> r=%b", a, b1, b0, dir, r);
        end
    endtask

    initial begin
        $dumpfile("sim/shifter4_tb.vcd");
        $dumpvars(0, shifter4_tb);

        a = 4'b1101; // A3 A2 A1 A0 = 1,1,0,1

        // shift left
        dir = 0;
        b1 = 0; b0 = 0; check(4'b1101); // shift 0, queda igual
        b1 = 0; b0 = 1; check(4'b1010); // shift 1
        b1 = 1; b0 = 0; check(4'b0100); // shift 2
        b1 = 1; b0 = 1; check(4'b1000); // shift 3

        // shift right
        dir = 1;
        b1 = 0; b0 = 0; check(4'b1101); // shift 0, queda igual
        b1 = 0; b0 = 1; check(4'b0110); // shift 1
        b1 = 1; b0 = 0; check(4'b0011); // shift 2
        b1 = 1; b0 = 1; check(4'b0001); // shift 3

        $display("shifter4_tb: fin de la simulacion");
        $finish;
    end

endmodule
