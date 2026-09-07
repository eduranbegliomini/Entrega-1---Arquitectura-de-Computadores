// adder4_tb.v
// Probamos suma normal, resta A-B y resta B-A (con las entradas invertidas
// a mano, como se va a usar en calculadora_4bits). Casos borde: overflow
// en la suma (se pierde el carry, quedan solo 4 bits) y restas que dan
// negativo (representado en complemento a 2).

`timescale 1ns/1ps

module adder4_tb;

    reg  [3:0] a, b;
    reg        sub;
    wire [3:0] s;
    wire       cout;

    adder4 dut (.a(a), .b(b), .sub(sub), .s(s), .cout(cout));

    task check(input [3:0] esperado_s);
        begin
            #10;
            if (s !== esperado_s)
                $display("FALLO: a=%d b=%d sub=%b -> s=%d (esperado %d)", a, b, sub, s, esperado_s);
            else
                $display("OK: a=%d b=%d sub=%b -> s=%d cout=%b", a, b, sub, s, cout);
        end
    endtask

    initial begin
        $dumpfile("sim/adder4_tb.vcd");
        $dumpvars(0, adder4_tb);

        // suma normal, sin overflow
        a = 4'd3; b = 4'd4; sub = 0; check(4'd7);

        // suma con overflow (3 + 15 = 18, se guardan solo los 4 bits bajos = 2)
        a = 4'd3; b = 4'd15; sub = 0; check(4'd2);

        // resta A-B, resultado positivo: 9 - 3 = 6
        a = 4'd9; b = 4'd3; sub = 1; check(4'd6);

        // resta A-B, resultado negativo: 3 - 9 = -6 -> en complemento a 2 (4 bits) es 1010
        a = 4'd3; b = 4'd9; sub = 1; check(4'b1010);

        // resta B-A (invertimos las entradas del modulo a mano): A=2, B=9 -> B-A = 9-2 = 7
        // aca "a" del dut recibe B y "b" del dut recibe A
        a = 4'd9; b = 4'd2; sub = 1; check(4'd7);

        $display("adder4_tb: fin de la simulacion");
        $finish;
    end

endmodule
