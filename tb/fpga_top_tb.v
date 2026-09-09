`timescale 1ns/1ps

module fpga_top_tb;

    localparam LIMIT_TB = 3;

    reg clk;
    reg sw1, sw2, sw3, sw4; 

    wire led1, led2, led3, led4;
    wire seg1_a, seg1_b, seg1_c, seg1_d, seg1_e, seg1_f, seg1_g;
    wire seg2_a, seg2_b, seg2_c, seg2_d, seg2_e, seg2_f, seg2_g;

    fpga_top #(.DEBOUNCE_LIMIT(LIMIT_TB)) dut (
        .i_Clk       (clk),
        .i_Switch_1  (sw1),
        .i_Switch_2  (sw2),
        .i_Switch_3  (sw3),
        .i_Switch_4  (sw4),
        .o_LED_1     (led1),
        .o_LED_2     (led2),
        .o_LED_3     (led3),
        .o_LED_4     (led4),
        .o_Segment1_A(seg1_a), .o_Segment1_B(seg1_b), .o_Segment1_C(seg1_c), .o_Segment1_D(seg1_d),
        .o_Segment1_E(seg1_e), .o_Segment1_F(seg1_f), .o_Segment1_G(seg1_g),
        .o_Segment2_A(seg2_a), .o_Segment2_B(seg2_b), .o_Segment2_C(seg2_c), .o_Segment2_D(seg2_d),
        .o_Segment2_E(seg2_e), .o_Segment2_F(seg2_f), .o_Segment2_G(seg2_g)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task presionar_sw1;
        begin
            sw1 = 0; repeat (LIMIT_TB + 3) @(posedge clk);
            sw1 = 1; repeat (LIMIT_TB + 3) @(posedge clk);
        end
    endtask

    task presionar_sw2;
        begin
            sw2 = 0; repeat (LIMIT_TB + 3) @(posedge clk);
            sw2 = 1; repeat (LIMIT_TB + 3) @(posedge clk);
        end
    endtask

    task presionar_sw3;
        begin
            sw3 = 0; repeat (LIMIT_TB + 3) @(posedge clk);
            sw3 = 1; repeat (LIMIT_TB + 3) @(posedge clk);
        end
    endtask

    task presionar_sw4;
        begin
            sw4 = 0; repeat (LIMIT_TB + 3) @(posedge clk);
            sw4 = 1; repeat (LIMIT_TB + 3) @(posedge clk);
        end
    endtask

    integer i;

    task reset_codigo;
        begin
            while (dut.codigo_reg !== 3'd0) presionar_sw2;
        end
    endtask

    task reset_op1;
        begin
            while (dut.op1_reg !== 4'd0) presionar_sw2;
        end
    endtask

    task reset_op2;
        begin
            while (dut.op2_reg !== 4'd0) presionar_sw2;
        end
    endtask

    initial begin
        $dumpfile("sim/fpga_top_tb.vcd");
        $dumpvars(0, fpga_top_tb);

        sw1 = 1; sw2 = 1; sw3 = 1; sw4 = 1;
        repeat (LIMIT_TB + 3) @(posedge clk);

        presionar_sw1;
        if (dut.codigo_reg !== 3'b001) $display("FALLO: codigo deberia ser 001, es %b", dut.codigo_reg);
        else $display("OK: codigo=001 (suma)");

        presionar_sw3; 
        if (dut.estado !== 2'b01) $display("FALLO: deberia estar en S_OP1");

        for (i = 0; i < 3; i = i + 1) presionar_sw1;
        if (dut.op1_reg !== 4'd3) $display("FALLO: op1 deberia ser 3, es %d", dut.op1_reg);

        presionar_sw3; 
        if (dut.estado !== 2'b10) $display("FALLO: deberia estar en S_OP2");

        for (i = 0; i < 4; i = i + 1) presionar_sw1;
        if (dut.op2_reg !== 4'd4) $display("FALLO: op2 deberia ser 4, es %d", dut.op2_reg);

        presionar_sw3;
        if (dut.estado !== 2'b11) $display("FALLO: deberia estar en S_RES");

        if (dut.resultado_calc !== 4'd7)
            $display("FALLO: 3+4 deberia dar 7, dio %d", dut.resultado_calc);
        else
            $display("OK: 3+4 = %d, mostrado en display (signo=%b)", dut.resultado_calc, dut.signo);

        if (dut.mostrar_valor !== 1'b1)
            $display("FALLO: en S_RES el display deberia estar prendido");

        presionar_sw3; 
        if (dut.estado !== 2'b00) $display("FALLO: deberia volver a S_OP");
        if (dut.mostrar_valor !== 1'b0) $display("FALLO: en S_OP el display deberia estar apagado");
        else $display("OK: volvio a S_OP y el display se apago");

        reset_codigo;
        for (i = 0; i < 2; i = i + 1) presionar_sw1; 
        if (dut.codigo_reg !== 3'b010) $display("FALLO: codigo deberia ser 010, es %b", dut.codigo_reg);
        presionar_sw3;

        reset_op1;
        for (i = 0; i < 3; i = i + 1) presionar_sw1; 
        presionar_sw3;

        reset_op2;
        for (i = 0; i < 9; i = i + 1) presionar_sw1; 
        presionar_sw3; 

        if (dut.resultado_calc !== 4'b1010)
            $display("FALLO: 3-9 deberia dar 1010 (-6), dio %b", dut.resultado_calc);
        else if (dut.signo !== 1'b1)
            $display("FALLO: 3-9 es negativo, signo deberia ser 1");
        else
            $display("OK: 3-9 = %b, signo=%b magnitud=%d", dut.resultado_calc, dut.signo, dut.magnitud);

        presionar_sw3; 

        reset_codigo;
        presionar_sw1; 
        presionar_sw3;

        reset_op1;
        for (i = 0; i < 2; i = i + 1) presionar_sw1;
        presionar_sw3; 

        presionar_sw4; 
        if (dut.sel_op2_reg !== 1'b1) $display("FALLO: sel_op2_reg deberia quedar en 1");

        presionar_sw3;

        if (dut.resultado_calc !== 4'b1100)
            $display("FALLO: 2+(-6) deberia dar 1100 (-4), dio %b", dut.resultado_calc);
        else
            $display("OK: encadenamiento 2+(-6) = %b (-4)", dut.resultado_calc);

        $display("fpga_top_tb: fin de la simulacion");
        $finish;
    end

endmodule
