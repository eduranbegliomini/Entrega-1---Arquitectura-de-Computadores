// full_adder_tb.v
// Testbench del full adder. Como son solo 3 entradas, probamos las 8
// combinaciones posibles (exhaustivo) y comparamos contra el resultado
// esperado calculado "a mano" con + (aca si se puede, es testbench, no diseno).

`timescale 1ns/1ps

module full_adder_tb;

    reg  a, b, cin;
    wire s, cout;

    integer i;
    reg [1:0] esperado; // {cout_esperado, s_esperado}
    integer errores;

    full_adder dut (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .s    (s),
        .cout (cout)
    );

    initial begin
        $dumpfile("sim/full_adder_tb.vcd");
        $dumpvars(0, full_adder_tb);

        errores = 0;

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #10; // esperamos que se propague la logica combinacional

            esperado = a + b + cin; // suma normal de 1 bit, esto da 2 bits: {cout, s}

            if (s !== esperado[0] || cout !== esperado[1]) begin
                $display("FALLO: a=%b b=%b cin=%b -> s=%b cout=%b (esperado s=%b cout=%b)",
                          a, b, cin, s, cout, esperado[0], esperado[1]);
                errores = errores + 1;
            end else begin
                $display("OK: a=%b b=%b cin=%b -> s=%b cout=%b", a, b, cin, s, cout);
            end
        end

        if (errores == 0)
            $display("full_adder_tb: TODOS LOS CASOS PASARON");
        else
            $display("full_adder_tb: %0d CASOS FALLARON", errores);

        $finish;
    end

endmodule
