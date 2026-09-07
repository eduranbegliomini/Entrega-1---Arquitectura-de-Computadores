// bin_a_7seg_tb.v
// Probamos los 16 digitos contra la tabla de segmentos de Nandland
// (activo en alto). Guardamos el esperado como {a,b,c,d,e,f,g}.

`timescale 1ns/1ps

module bin_a_7seg_tb;

    reg  [3:0] n;
    wire a, b, c, d, e, f, g;
    wire [6:0] salida;

    integer i;
    reg [6:0] esperado; // {a,b,c,d,e,f,g}
    integer errores;

    bin_a_7seg dut (.n(n), .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g));
    assign salida = {a, b, c, d, e, f, g};

    // tabla sacada de la hoja de Nandland (0x7E, 0x30, ... para 0-F),
    // reescrita como {a,b,c,d,e,f,g}
    function [6:0] esperado_de(input [3:0] digito);
        case (digito)
            4'h0: esperado_de = 7'b1111110;
            4'h1: esperado_de = 7'b0110000;
            4'h2: esperado_de = 7'b1101101;
            4'h3: esperado_de = 7'b1111001;
            4'h4: esperado_de = 7'b0110011;
            4'h5: esperado_de = 7'b1011011;
            4'h6: esperado_de = 7'b1011111;
            4'h7: esperado_de = 7'b1110000;
            4'h8: esperado_de = 7'b1111111;
            4'h9: esperado_de = 7'b1111011;
            4'hA: esperado_de = 7'b1110111;
            4'hB: esperado_de = 7'b0011111;
            4'hC: esperado_de = 7'b1001110;
            4'hD: esperado_de = 7'b0111101;
            4'hE: esperado_de = 7'b1001111;
            4'hF: esperado_de = 7'b1000111;
        endcase
    endfunction

    initial begin
        $dumpfile("sim/bin_a_7seg_tb.vcd");
        $dumpvars(0, bin_a_7seg_tb);

        errores = 0;

        for (i = 0; i < 16; i = i + 1) begin
            n = i[3:0];
            #10;
            esperado = esperado_de(n);
            if (salida !== esperado) begin
                $display("FALLO: n=%h -> abcdefg=%b (esperado %b)", n, salida, esperado);
                errores = errores + 1;
            end else begin
                $display("OK: n=%h -> abcdefg=%b", n, salida);
            end
        end

        if (errores == 0)
            $display("bin_a_7seg_tb: TODOS LOS CASOS PASARON");
        else
            $display("bin_a_7seg_tb: %0d CASOS FALLARON", errores);

        $finish;
    end

endmodule
