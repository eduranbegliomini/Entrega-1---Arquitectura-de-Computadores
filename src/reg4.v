module reg4 (
    input        clk,
    input        ejecutar,
    input  [3:0] d,
    output reg [3:0] q
);

    wire [3:0] d_real;

    mux2to1_4bit mux_carga (.d0(q), .d1(d), .sel(ejecutar), .y(d_real));

    always @(posedge clk) begin
        q <= d_real;
    end

endmodule
