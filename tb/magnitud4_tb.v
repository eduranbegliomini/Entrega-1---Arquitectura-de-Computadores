`timescale 1ns/1ps

module magnitud4_tb;

    reg  [3:0] valor;
    wire [3:0] mag;
    wire       signo;

    magnitud4 dut (.valor(valor), .mag(mag), .signo(signo));

    task check(input [3:0] esperado_mag, input esperado_signo);
        begin
            #10;
            if (mag !== esperado_mag || signo !== esperado_signo)
                $display("FALLO: valor=%b -> mag=%d signo=%b (esperado mag=%d signo=%b)",
                          valor, mag, signo, esperado_mag, esperado_signo);
            else
                $display("OK: valor=%b -> signo=%b mag=%d", valor, signo, mag);
        end
    endtask

    initial begin
        $dumpfile("sim/magnitud4_tb.vcd");
        $dumpvars(0, magnitud4_tb);

        valor = 4'b0000; check(4'd0, 1'b0); // 0
        valor = 4'b0101; check(4'd5, 1'b0); // 5
        valor = 4'b0111; check(4'd7, 1'b0); // 7 (maximo positivo)
        valor = 4'b1111; check(4'd1, 1'b1); // -1
        valor = 4'b1110; check(4'd2, 1'b1); // -2 (el ejemplo que dio el profe)
        valor = 4'b1000; check(4'd8, 1'b1); // -8 (minimo, caso borde)

        $display("magnitud4_tb: fin de la simulacion");
        $finish;
    end

endmodule
