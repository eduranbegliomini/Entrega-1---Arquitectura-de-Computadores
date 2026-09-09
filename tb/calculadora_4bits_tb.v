`timescale 1ns/1ps

module calculadora_4bits_tb;

    reg        clk, ejecutar, sel_op2;
    reg  [2:0] codigo;
    reg  [3:0] op1, op2_ext;
    wire [3:0] resultado;

    calculadora_4bits dut (
        .clk       (clk),
        .ejecutar  (ejecutar),
        .codigo    (codigo),
        .sel_op2   (sel_op2),
        .op1       (op1),
        .op2_ext   (op2_ext),
        .resultado (resultado)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task ejecutar_op(
        input [2:0] cod,
        input       sel2,
        input [3:0] a,
        input [3:0] b,
        input [3:0] esperado
    );
        begin
            codigo = cod; sel_op2 = sel2; op1 = a; op2_ext = b; ejecutar = 1;
            @(posedge clk); #1;
            if (resultado !== esperado)
                $display("FALLO: codigo=%b sel_op2=%b op1=%d op2_ext=%d -> resultado=%b (esperado %b)",
                          cod, sel2, a, b, resultado, esperado);
            else
                $display("OK: codigo=%b sel_op2=%b op1=%d op2_ext=%d -> resultado=%b",
                          cod, sel2, a, b, resultado);
            ejecutar = 0;
            @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("sim/calculadora_4bits_tb.vcd");
        $dumpvars(0, calculadora_4bits_tb);

        // partir de un estado conocido
        ejecutar_op(3'b000, 0, 4'd0, 4'd0, 4'b0000);

        // suma
        ejecutar_op(3'b001, 0, 4'd3, 4'd4, 4'd7);
        ejecutar_op(3'b001, 0, 4'd15, 4'd1, 4'b0000); // overflow: 15+1=16, se pierde el carry

        // resta (A-B)
        ejecutar_op(3'b010, 0, 4'd9, 4'd3, 4'd6);
        ejecutar_op(3'b010, 0, 4'd3, 4'd9, 4'b1010); // 3-9=-6 -> complemento a 2

        // resta inversa (B-A)
        ejecutar_op(3'b011, 0, 4'd3, 4'd9, 4'd6);     // B-A = 9-3 = 6
        ejecutar_op(3'b011, 0, 4'd9, 4'd2, 4'b1001);  // B-A = 2-9 = -7 -> complemento a 2

        // shift left
        ejecutar_op(3'b100, 0, 4'b1101, 4'b0001, 4'b1010); // shift 1
        ejecutar_op(3'b100, 0, 4'b1101, 4'b0011, 4'b1000); // shift 3

        // shift right
        ejecutar_op(3'b101, 0, 4'b1101, 4'b0001, 4'b0110); // shift 1
        ejecutar_op(3'b101, 0, 4'b1101, 4'b0011, 4'b0001); // shift 3

        // reinicio de nuevo, desde un resultado que no es cero
        ejecutar_op(3'b000, 0, 4'd0, 4'd0, 4'b0000);

        // encadenamiento: sel_op2=1 usa el resultado guardado como B
        ejecutar_op(3'b001, 0, 4'd5, 4'd0, 4'd5);        // resultado = 5
        ejecutar_op(3'b001, 1, 4'd2, 4'd0, 4'd7);        // 2 + resultado_anterior(5) = 7

        // codigos reservados, deben comportarse como reinicio
        ejecutar_op(3'b110, 0, 4'd5, 4'd5, 4'b0000);
        ejecutar_op(3'b111, 0, 4'd5, 4'd5, 4'b0000);

        $display("calculadora_4bits_tb: fin de la simulacion");
        $finish;
    end

endmodule
