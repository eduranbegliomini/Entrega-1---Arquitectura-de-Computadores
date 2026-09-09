module fpga_top #(
    parameter DEBOUNCE_LIMIT = 500000 // bajar este numero para simular rapido
) (
    input  i_Clk,
    input  i_Switch_1,
    input  i_Switch_2,
    input  i_Switch_3,
    input  i_Switch_4,

    output o_LED_1,
    output o_LED_2,
    output o_LED_3,
    output o_LED_4,

    output o_Segment1_A, o_Segment1_B, o_Segment1_C, o_Segment1_D,
    output o_Segment1_E, o_Segment1_F, o_Segment1_G,

    output o_Segment2_A, o_Segment2_B, o_Segment2_C, o_Segment2_D,
    output o_Segment2_E, o_Segment2_F, o_Segment2_G
);

    wire pulso_inc, pulso_dec, pulso_conf, pulso_usar_ant;

    debounce #(.LIMIT(DEBOUNCE_LIMIT)) db_inc  (.clk(i_Clk), .boton_crudo(~i_Switch_1), .pulso(pulso_inc));
    debounce #(.LIMIT(DEBOUNCE_LIMIT)) db_dec  (.clk(i_Clk), .boton_crudo(~i_Switch_2), .pulso(pulso_dec));
    debounce #(.LIMIT(DEBOUNCE_LIMIT)) db_conf (.clk(i_Clk), .boton_crudo(~i_Switch_3), .pulso(pulso_conf));
    debounce #(.LIMIT(DEBOUNCE_LIMIT)) db_ant  (.clk(i_Clk), .boton_crudo(~i_Switch_4), .pulso(pulso_usar_ant));

    localparam S_OP  = 2'b00;
    localparam S_OP1 = 2'b01;
    localparam S_OP2 = 2'b10;
    localparam S_RES = 2'b11;

    reg [1:0] estado;
    initial estado = S_OP;

    always @(posedge i_Clk) begin
        if (pulso_conf) begin
            case (estado)
                S_OP:  estado <= S_OP1;
                S_OP1: estado <= S_OP2;
                S_OP2: estado <= S_RES;
                S_RES: estado <= S_OP;
                default: estado <= S_OP;
            endcase
        end
    end

    wire ejecutar_calc = pulso_conf & (estado == S_OP2);

    reg sel_op2_reg;
    initial sel_op2_reg = 1'b0;

    always @(posedge i_Clk) begin
        if (pulso_conf && estado == S_OP1)
            sel_op2_reg <= 1'b0;
        else if (pulso_usar_ant && estado == S_OP2)
            sel_op2_reg <= ~sel_op2_reg;
    end

    // ---------- contadores de codigo, op1 y op2 ----------
    wire inc_codigo = pulso_inc & (estado == S_OP);
    wire dec_codigo = pulso_dec & (estado == S_OP);
    wire inc_op1    = pulso_inc & (estado == S_OP1);
    wire dec_op1    = pulso_dec & (estado == S_OP1);
    wire inc_op2    = pulso_inc & (estado == S_OP2) & (~sel_op2_reg);
    wire dec_op2    = pulso_dec & (estado == S_OP2) & (~sel_op2_reg);

    wire [2:0] codigo_reg;
    wire [3:0] op1_reg;
    wire [3:0] op2_reg;

    contador_ud #(.ANCHO(3)) cont_codigo (.clk(i_Clk), .inc_pulso(inc_codigo), .dec_pulso(dec_codigo), .valor(codigo_reg));
    contador_ud #(.ANCHO(4)) cont_op1    (.clk(i_Clk), .inc_pulso(inc_op1),    .dec_pulso(dec_op1),    .valor(op1_reg));
    contador_ud #(.ANCHO(4)) cont_op2    (.clk(i_Clk), .inc_pulso(inc_op2),    .dec_pulso(dec_op2),    .valor(op2_reg));

    // ---------- la calculadora en si ----------
    wire [3:0] resultado_calc;
    wire overflow_calc;

    calculadora_4bits calc (
        .clk       (i_Clk),
        .ejecutar  (ejecutar_calc),
        .codigo    (codigo_reg),
        .sel_op2   (sel_op2_reg),
        .op1       (op1_reg),
        .op2_ext   (op2_reg),
        .resultado (resultado_calc),
        .overflow  (overflow_calc) 
    );

    // ---------- LEDs: muestran el codigo de operacion actual ----------
    buf (o_LED_1, codigo_reg[0]);
    buf (o_LED_2, codigo_reg[1]);
    buf (o_LED_3, codigo_reg[2]);
    buf (o_LED_4, overflow_calc);

    // ---------- eleccion de que valor mostrar en los displays ----------

    wire [3:0] op2_a_mostrar;
    mux2to1_4bit mux_op2_disp (.d0(op2_reg), .d1(resultado_calc), .sel(sel_op2_reg), .y(op2_a_mostrar));

    wire [3:0] nivel1_a, nivel1_b;
    mux2to1_4bit mux_disp_a (.d0(4'b0000),       .d1(op1_reg),       .sel(estado[0]), .y(nivel1_a));
    mux2to1_4bit mux_disp_b (.d0(op2_a_mostrar), .d1(resultado_calc), .sel(estado[0]), .y(nivel1_b));

    wire [3:0] valor_mostrado;
    mux2to1_4bit mux_disp_final (.d0(nivel1_a), .d1(nivel1_b), .sel(estado[1]), .y(valor_mostrado));

    wire mostrar_valor;
    or (mostrar_valor, estado[1], estado[0]);

    wire [3:0] magnitud;
    wire       signo;
    magnitud4 mag_ext (.valor(valor_mostrado), .mag(magnitud), .signo(signo));

    wire s1_a, s1_b, s1_c, s1_d, s1_e, s1_f, s1_g;
    signo_7seg deco_signo (.signo(signo), .a(s1_a), .b(s1_b), .c(s1_c), .d(s1_d), .e(s1_e), .f(s1_f), .g(s1_g));

    wire s2_a, s2_b, s2_c, s2_d, s2_e, s2_f, s2_g;
    bin_a_7seg deco_mag (.n(magnitud), .a(s2_a), .b(s2_b), .c(s2_c), .d(s2_d), .e(s2_e), .f(s2_f), .g(s2_g));

    // ---------- salida final a los pines (logica invertida NAND para active-low) ----------
    nand (o_Segment1_A, s1_a, mostrar_valor);
    nand (o_Segment1_B, s1_b, mostrar_valor);
    nand (o_Segment1_C, s1_c, mostrar_valor);
    nand (o_Segment1_D, s1_d, mostrar_valor);
    nand (o_Segment1_E, s1_e, mostrar_valor);
    nand (o_Segment1_F, s1_f, mostrar_valor);
    nand (o_Segment1_G, s1_g, mostrar_valor);

    nand (o_Segment2_A, s2_a, mostrar_valor);
    nand (o_Segment2_B, s2_b, mostrar_valor);
    nand (o_Segment2_C, s2_c, mostrar_valor);
    nand (o_Segment2_D, s2_d, mostrar_valor);
    nand (o_Segment2_E, s2_e, mostrar_valor);
    nand (o_Segment2_F, s2_f, mostrar_valor);
    nand (o_Segment2_G, s2_g, mostrar_valor);

endmodule
