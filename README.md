# Calculadora de 4 bits - Proyecto 1 Arquitectura de Computadores

Calculadora de 4 bits en Verilog para la FPGA Lattice iCE40 HX1K (Nandland Go Board).
Toda la logica combinacional esta hecha solo con compuertas primitivas de Verilog
(`and`, `or`, `not`, `xor`), sin usar `+`, `-`, comparadores, shifts de alto nivel
ni `if`/`case` para la logica de la ALU.

## Estructura

```
src/   modulos de Verilog (.v)
tb/    testbenches (.v)
sim/   salida de la simulacion (.vvp, .vcd) - no se sube al repo
docs/  notas de diseno (tablas de verdad, Karnaugh, ecuaciones)
fpga/  archivo de constraints (.pcf) para la Go Board
```

## Modulos

- `full_adder.v`: sumador completo de 1 bit.
- `adder4.v`: sumador/restador de 4 bits (4 full adders encadenados + complemento a 2).
- `mux2to1_4bit.v`: mux 2:1 de 4 bits.
- `shifter4.v`: shifter de 4 bits, izquierda y derecha.
- `mux8to1_4bit.v`: mux 8:1 de 4 bits (armado como arbol de mux2to1).
- `reg4.v`: registro de 4 bits con flip-flops D, carga habilitada por `ejecutar`.
- `calculadora_4bits.v`: modulo top, junta todo lo anterior.

Interfaz del modulo top (la que espera el testbench del curso):

```verilog
module calculadora_4bits (
  input  wire       clk,
  input  wire       ejecutar,
  input  wire [2:0] codigo,
  input  wire       sel_op2,
  input  wire [3:0] op1,
  input  wire [3:0] op2_ext,
  output wire [3:0] resultado
);
```

### Parte FPGA (botones, displays, LEDs)

Ademas del datapath, `src/fpga_top.v` conecta `calculadora_4bits` con los
4 botones y los 2 displays de 7 segmentos de la Go Board:

- `debounce.v`: filtra rebotes de un boton y devuelve un pulso por
  presionada.
- `contador_ud.v`: contador subir/bajar generico, para ir armando el
  codigo de operacion y los operandos con los botones.
- `bin_a_7seg.v`: decodifica un digito hex a los 7 segmentos (con
  compuertas).
- `magnitud4.v` + `signo_7seg.v`: convierten el numero en complemento a
  2 a signo + magnitud para mostrarlo (reutiliza `adder4`).
- `fpga_top.v`: la maquina de estados que junta todo.

**Esta parte esta simulada pero no probada en una placa fisica real**
(revisar `docs/diseno_fpga.md`, ahi estan documentados los supuestos que
hay que confirmar antes de la demo: polaridad de los botones, cual
switch es cual boton fisico, y el pinout usado).

## Como correr las simulaciones

Requisito: [Icarus Verilog](http://iverilog.icarus.com/) instalado (`iverilog` y `vvp` en el PATH).

Desde la raiz del proyecto, en la terminal de VS Code:

```bash
# ejemplo con el testbench del full adder
iverilog -g2012 -o sim/full_adder_tb.vvp src/full_adder.v tb/full_adder_tb.v
vvp sim/full_adder_tb.vvp
```

Cada testbench necesita los .v de los modulos que usa. Los comandos completos para
cada uno:

```bash
iverilog -g2012 -o sim/full_adder_tb.vvp src/full_adder.v tb/full_adder_tb.v
vvp sim/full_adder_tb.vvp

iverilog -g2012 -o sim/adder4_tb.vvp src/full_adder.v src/adder4.v tb/adder4_tb.v
vvp sim/adder4_tb.vvp

iverilog -g2012 -o sim/mux2to1_4bit_tb.vvp src/mux2to1_4bit.v tb/mux2to1_4bit_tb.v
vvp sim/mux2to1_4bit_tb.vvp

iverilog -g2012 -o sim/shifter4_tb.vvp src/mux2to1_4bit.v src/shifter4.v tb/shifter4_tb.v
vvp sim/shifter4_tb.vvp

iverilog -g2012 -o sim/mux8to1_4bit_tb.vvp src/mux2to1_4bit.v src/mux8to1_4bit.v tb/mux8to1_4bit_tb.v
vvp sim/mux8to1_4bit_tb.vvp

iverilog -g2012 -o sim/reg4_tb.vvp src/mux2to1_4bit.v src/reg4.v tb/reg4_tb.v
vvp sim/reg4_tb.vvp

iverilog -g2012 -o sim/calculadora_4bits_tb.vvp src/full_adder.v src/adder4.v src/mux2to1_4bit.v src/shifter4.v src/mux8to1_4bit.v src/reg4.v src/calculadora_4bits.v tb/calculadora_4bits_tb.v
vvp sim/calculadora_4bits_tb.vvp

# parte FPGA (botones, displays, LEDs)
iverilog -g2012 -o sim/bin_a_7seg_tb.vvp src/bin_a_7seg.v tb/bin_a_7seg_tb.v
vvp sim/bin_a_7seg_tb.vvp

iverilog -g2012 -o sim/magnitud4_tb.vvp src/full_adder.v src/adder4.v src/magnitud4.v tb/magnitud4_tb.v
vvp sim/magnitud4_tb.vvp

iverilog -g2012 -o sim/contador_ud_tb.vvp src/contador_ud.v tb/contador_ud_tb.v
vvp sim/contador_ud_tb.vvp

iverilog -g2012 -o sim/debounce_tb.vvp src/debounce.v tb/debounce_tb.v
vvp sim/debounce_tb.vvp

iverilog -g2012 -o sim/fpga_top_tb.vvp src/full_adder.v src/adder4.v src/mux2to1_4bit.v src/shifter4.v src/mux8to1_4bit.v src/reg4.v src/calculadora_4bits.v src/debounce.v src/contador_ud.v src/bin_a_7seg.v src/magnitud4.v src/signo_7seg.v src/fpga_top.v tb/fpga_top_tb.v
vvp sim/fpga_top_tb.vvp
```

Cada testbench va escribiendo por consola `OK` o `FALLO` por cada caso probado, y
genera un `.vcd` en `sim/` para abrir con GTKWave:

```bash
gtkwave sim/calculadora_4bits_tb.vcd
```

## Estado

Todos los testbenches (datapath + FPGA) pasan sin fallos al 2 de septiembre
de 2026. La parte de botones/displays/LEDs esta simulada pero **no probada
en la Go Board fisica todavia** - falta sintetizar (yosys/nextpnr/icepack,
ver `docs/diseno_fpga.md`) y validar en la placa antes de la demo.
